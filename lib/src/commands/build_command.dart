import 'dart:async';
import 'dart:convert';
import 'dart:io' show exit;

import 'package:args/command_runner.dart';
import 'package:blake/src/build/content_parser.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/data.dart';
import 'package:blake/src/errors.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/search.dart';
import 'package:blake/src/shortcode.dart';
import 'package:blake/src/sitemap_builder.dart';
import 'package:blake/src/util/either.dart';
import 'package:blake/src/utils.dart';
import 'package:mustache_template/mustache_template.dart';

class BuildCommand extends Command<int> {
  BuildCommand(this.config) {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Show more logs.',
      defaultsTo: false,
      negatable: false,
    );
  }

  final Config config;

  @override
  final name = 'build';

  @override
  final description = 'Build static files.';

  final _stopwatch = Stopwatch();

  @override
  FutureOr<int> run() async {
    return build(config);
  }

  Future<int> build(Config config) async {
    log.info('Building');
    _stopwatch.start();

    final contentDir = (await getContentDirectory(config)).when<Directory>(
      _exit,
      (value) => value,
    );

    final content = (await _parseContent(contentDir)).when(
      (error) => _exit<Content>(error),
      (value) => value,
    );
    await _generateContent(content);
    await _copyStaticFiles();

    final sitemapBuilder = SitemapBuilder(
      config: config,
      pages: content.getPages(),
    );
    await sitemapBuilder.build();

    if (config.build.generateSearchIndex) {
      final index = SearchIndexBuilder(
        config: config,
        pages: content.getPages(),
      ).build();

      final indexFilePath = Path.join(
        config.build.publicDir,
        'search_index.json',
      );

      final indexFile = await fs.file(indexFilePath).create();
      await indexFile.writeAsString(json.encode(index));
      log.debug('Search index generated');

      final size = await indexFile.length();
      if (size >= 1000000) {
        log.warning('Search index file is over 1MB');
      }
    }
    _stopwatch.stop();
    log.info('Build done in ${_stopwatch.elapsedMilliseconds}ms');
    return 0;
  }

  Future<Either<BuildError, Content>> _parseContent(
    Directory contentDir,
  ) async {
    try {
      final shortcodesDirPath = Path.join(
        config.build.templatesDir,
        'shortcodes',
      );
      final shortcodesDir = fs.directory(shortcodesDirPath);

      // TODO: Create shortcodes dir during initialization.
      List<ShortcodeTemplate> shortcodes;
      if (await shortcodesDir.exists()) {
        final shortcodeFiles = await shortcodesDir.list().toList();

        shortcodes =
            await shortcodeFiles.whereType<File>().asyncMap<ShortcodeTemplate>(
          (e) async {
            return ShortcodeTemplate(
              name: Path.basenameWithoutExtension(e.path),
              template: await e.readAsString(),
            );
          },
        );
      } else {
        shortcodes = [];
      }

      final parser = ContentParser(
        shortcodeTemplates: shortcodes,
        config: config,
      );
      final content = await parser.parse(contentDir);
      return Right(content);
    } on BuildError catch (e) {
      return Left(e);
    }
  }

  /// Generate static files from content tree.
  Future<void> _generateContent(Content content) async {
    try {
      await content.when(
        section: (section) => _buildSection(section, config),
        page: (page) => _buildPage(page, config),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _buildSection(Section section, Config config) async {
    if (section.index != null) {
      await _buildPage(
        section.index!,
        config,
        extraData: <dynamic, dynamic>{
          'children': section.children
              .whereType<Page>()
              .map((e) => e.toMap(config))
              .toList(),
        },
      );
    }

    try {
      for (final child in section.children) {
        await child.when(
          section: (section) => _buildSection(section, config),
          page: (page) => _buildPage(page, config),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _buildPage(
    Page page,
    Config config, {
    Map<dynamic, dynamic> extraData = const <dynamic, dynamic>{},
  }) async {
    log.debug('Build: $page');

    // Abort on non-public pages (i.e. data only page).
    final public = page.metadata['public'] as bool? ?? true;
    if (!public) {
      log.debug('Page ${page.path} is not public');
      return;
    }

    final template = await _getTemplate(page, config);
    final data = await parseDataTree(config);

    final metadata = <dynamic, dynamic>{
      'title': page.title,
      'content': page.content,
      'site': config.toMap(),
      'template': template.name,
      'data': data,
    }
      ..addAll(page.metadata)
      ..addAll(extraData);

    final output = template.renderString(metadata);
    final path = page.getBuildPath(config);
    final file = await fs.file(path).create(recursive: true);
    await file.writeAsString(output);
  }

  /// Move all files from static folder into public folder.
  Future<void> _copyStaticFiles() async {
    try {
      final staticDir = await getStaticDirectory(config);

      final staticContent = await staticDir.list(recursive: true).toList();
      final directories = staticContent.whereType<Directory>();
      final files = staticContent.whereType<File>();

      for (final directory in directories) {
        final path = directory.path.replaceFirst(
          config.build.staticDir,
          config.build.publicDir,
        );
        await fs.directory(path).create(recursive: true);
      }

      for (final file in files) {
        await file.copy(
          file.path.replaceFirst(
            config.build.staticDir,
            config.build.publicDir,
          ),
        );
      }

      log.debug('Static files copied');
    } catch (e) {
      log.info('Skipping static directory.');
    }
  }

  /// Get template to render given [page]. If there is a `template` field in
  /// page front-matter it is used. Otherwise default template will used.
  Future<Template> _getTemplate(Page page, Config config) async {
    // Template set in front matter has precedence.
    var templateName = page.metadata['template'] as String?;
    templateName ??=
        page.isIndex ? config.templates.section : config.templates.page;

    final path = Path.join(config.build.templatesDir, templateName);
    final file = fs.file(path);

    if (!await file.exists()) {
      throw BuildError('Template $templateName does not exists');
    }

    return Template(await file.readAsString(), name: templateName);
  }

  /// When error occurs, show log and exit program.
  R _exit<R>(Exception reason) {
    log.error(reason);
    exit(1);
  }
}
