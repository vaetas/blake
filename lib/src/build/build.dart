import 'dart:async';
import 'dart:io';

import 'package:blake/src/build/content_tree.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
import 'package:blake/src/data.dart';
import 'package:blake/src/errors.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/log.dart';
import 'package:mustache_template/mustache_template.dart';

/// Build static site
Future<int> build(Config config) async {
  log.info('Building content');
  final stopwatch = Stopwatch()..start();
  final contentDir = await getContentDirectory(config);

  Content tree;
  try {
    tree = await parseContentTree(contentDir);
  } catch (e) {
    log.severe('Build failed: Could not parse content tree');
    return 1;
  }

  try {
    await Directory(config.build.publicDir).create();
    await generateContent(tree, config);
  } catch (e) {
    log.severe(e);
    return 1;
    // throw BuildException(e);
  }

  await copyStaticFiles(config);

  stopwatch.stop();
  log.info('Build done in ${stopwatch.elapsedMilliseconds}ms');
  return 0;
}

/// Generate static files from content tree.
Future<void> generateContent(Content content, Config config) async {
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
    await _buildIndexPage(
      section.index,
      config,
      children: section.children,
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

Future<void> _buildPage(Page page, Config config) async {
  log.debug('Build: $page');

  final template = await getTemplate(page, config);
  final data = await parseDataTree(config);

  final metadata = <dynamic, dynamic>{
    'title': page.name,
    'content': page.content,
    'site': config.toMap(),
    'template': template.name,
    'data': data,
  }..addAll(page.metadata);

  final output = template.renderString(metadata);

  final path = page.getCanonicalPath(config);

  final file = await File(path).create(recursive: true);
  await file.writeAsString(output);
}

Future<void> _buildIndexPage(
  Page page,
  Config config, {
  List<Content> children = const [],
}) async {
  log.debug('Build: $page (index)');

  final template = await getTemplate(page, config);

  final output = template.renderString(
    <dynamic, dynamic>{
      'site': config.toMap(),
      'title': page.name,
      'content': page.content,
      'children': children.whereType<Page>().map((e) => e.toMap(config)),
      'template': template.name,
    }..addAll(page.metadata),
  );

  final path = page.getCanonicalPath(config);

  final file = await File(path).create(recursive: true);
  await file.writeAsString(output);
}

/// Move all files from static folder into public folder.
Future<void> copyStaticFiles(Config config) async {
  final staticDir = await getStaticDirectory(config);

  final staticContent = await staticDir.list(recursive: true).toList();
  final directories = staticContent.whereType<Directory>();
  final files = staticContent.whereType<File>();

  for (final directory in directories) {
    final path = directory.path.replaceFirst(
      config.build.staticDir,
      config.build.publicDir,
    );
    await Directory(path).create(recursive: true);
  }

  for (final file in files) {
    await file.copy(
      file.path.replaceFirst(
        config.build.staticDir,
        config.build.publicDir,
      ),
    );
  }

  log.info('Static files copied');
}

/// Get template to render given [page]. If there is a `template` field in page
/// front-matter it is used. Otherwise default template will used.
Future<Template> getTemplate(Page page, Config config) async {
  // Template set in front matter has precedence.
  var templateName = page.metadata['template'] as String;
  templateName ??=
      page.isIndex ? config.templates.section : config.templates.page;

  final file = File('${config.build.templatesDir}/$templateName');

  if (!await file.exists()) {
    throw BuildError('Template $templateName does not exists');
  }

  return Template(await file.readAsString(), name: templateName);
}
