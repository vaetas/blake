import 'dart:async';
import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:blake/src/build/content_parser.dart';
import 'package:blake/src/commands/serve_command.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/redirect_page.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/data.dart';
import 'package:blake/src/errors.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/search.dart';
import 'package:blake/src/shortcode.dart';
import 'package:blake/src/sitemap_builder.dart';
import 'package:blake/src/taxonomy.dart';
import 'package:blake/src/util/either.dart';
import 'package:blake/src/util/maybe.dart';
import 'package:blake/src/utils.dart';
import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;
import 'package:jinja/jinja.dart';

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

  bool isServe = false;

  late Map<String, Object?> data;

  /// Reload script is included when build is triggered using [ServeCommand].
  ///
  /// This needs to generate new instance on each access. HTML library probably
  /// works with references and mutates the node after usage. Therefore, when
  /// settings this field as `late final`, it will be inserted into DOM only
  /// once and subsequent uses fail.
  html_dom.DocumentFragment get script {
    return html_parser.parseFragment(
      '<script src="http://127.0.0.1:${config.serve.port}/reload.js"></script>',
    );
  }

  @override
  FutureOr<int> run() async {
    final result = await build(config);
    return result.when(
      () => 0,
      (value) {
        log.error(value);
        return 1;
      },
    );
  }

  Future<Maybe<BuildError>> build(
    Config config, {
    bool isServe = false,
  }) async {
    log.info('Building');
    _stopwatch.start();
    this.isServe = isServe;

    final contentDir = await getContentDirectory(config);
    if (contentDir.isError) {
      return Just(contentDir.error);
    }

    final content = await _parseContent(contentDir.value);
    if (content.isError) {
      return Just(content.error);
    }

    final pages = content.value.getPages();
    final tags = _buildTaxonomy(pages);
    data = await parseDataTree(config);
    data['tags'] = tags;

    await _buildAliases(pages);

    try {
      await _generateContent(content.value);
    } on BuildError catch (e) {
      return Just(e);
    }

    await _copyStaticFiles();

    await SitemapBuilder(
      config: config,
      pages: pages,
    ).build();

    if (config.build.generateSearchIndex) {
      await _generateSearchIndex(pages);
    }

    _stopwatch.stop();
    log.info(
      'Build done in ${_stopwatch.elapsedMilliseconds}ms '
      '(${pages.length} pages)',
    );
    _stopwatch.reset();
    return const Nothing();
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
        section: _buildSection,
        page: _buildPage,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _buildSection(Section section) async {
    if (section.index != null) {
      final children = section.children.map((e) => e.toMap()).toList();
      final pages = section.children
          .whereType<Page>()
          .map((content) => content.toMap())
          .toList();

      final sections = section.children
          .whereType<Section>()
          .map((content) => content.toMap())
          .toList();

      await _buildPage(
        section.index!,
        extraData: <String, Object?>{
          'children': children,
          'pages': pages,
          'sections': sections,
        },
      );
    }

    try {
      for (final child in section.children) {
        await child.when(
          section: _buildSection,
          page: _buildPage,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _buildPage(
    Page page, {
    Map<String, Object?> extraData = const <String, Object>{},
  }) async {
    // log.debug('Build: $page');

    // Abort on non-public pages (i.e. data only page).
    if (!page.public) {
      log.debug('Page ${page.path} is not public');
      return;
    }

    final template = await _getTemplate(page, config);
    final baseUrl = config.getBaseUrl(isServe: isServe);
    final metadata = <String, Object?>{
      'title': page.title,
      'site': config.toMap()..set('baseUrl', baseUrl),
      'template': template!.path,
      'data': data,
    }
      ..addAll(page.metadata)
      ..addAll(extraData);

    final content = Template(page.content ?? '').renderMap(metadata);
    metadata['content'] = content;

    var output = template.renderMap(metadata);

    if (isServe) {
      final parsedHtml = html_parser.parse(output);
      if (parsedHtml.body != null) {
        parsedHtml.body!.nodes.add(script);
        output = parsedHtml.outerHtml;
      } else {
        log.warning('Could not include reload script into ${page.path}');
      }
    }
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
  Future<Template?> _getTemplate(
    Page page,
    Config config,
  ) async {
    // Template set in front matter has precedence.
    var templateName = page.metadata['template'] as String?;
    templateName ??=
        page.isIndex ? config.templates.section : config.templates.page;

    final path = Path.join(config.build.templatesDir, templateName);
    final file = fs.file(path);

    if (!await file.exists()) {
      throw BuildError(
        "Template '$templateName' used in '${page.path}' does not exist.",
      );
    }

    try {
      return config.environment.getTemplate(templateName);
    } on ArgumentError catch (e) {
      _abortBuild(BuildError(e.toString()));
      return null;
    }
  }

  Future<void> _generateSearchIndex(List<Page> pages) async {
    final index = SearchIndexBuilder(
      config: config,
      pages: pages.where((element) => element.public).toList(),
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

  List<Map<String, dynamic>> _buildTaxonomy(List<Page> pages) {
    final tags = <String, List<Page>>{};
    for (final page in pages) {
      for (final tag in page.tags) {
        tags[tag as String] ??= [];
        tags[tag]!.add(page);
      }
    }

    final result = List.generate(tags.length, (index) {
      final key = tags.keys.elementAt(index);
      return Tag(
        name: key,
        pages: tags[key]!,
      ).toMap(config);
    });

    log.debug('Tags: ${result.map((e) => '${e['name']}').toList()}');
    return result;
  }

  Future<void> _buildAliases(List<Page> pages) async {
    for (final page in pages) {
      if (page.aliases.isNotEmpty) {
        for (final alias in page.aliases) {
          final _alias = alias as String;
          final path = _alias.startsWith('/') ? _alias.substring(1) : _alias;
          final redirectPage = RedirectPage(
            path: path,
            destinationUrl: page.getPublicUrl(config, isServe: isServe),
          );
          await _buildPage(redirectPage);
        }
      }
    }
  }

  /// When error occurs, show log and exit program.
  // R _exit<R>(Exception reason) {
  //   log.error(reason);
  //   // exit(1);
  // }

  void _abortBuild(BlakeError error) {
    log.error(error, help: error.help);
  }
}

extension MapExtension<K, V> on Map<K, V> {
  void set(K key, V value) {
    this[key] = value;
  }
}
