import 'dart:async';
import 'dart:io';

import 'package:blake/src/build/content_tree.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/content/content.dart';
import 'package:blake/src/content/page.dart';
import 'package:blake/src/content/section.dart';
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

  log.debug('Files: $tree');

  await generateContent(tree, config);
  await copyStaticFiles(config);

  stopwatch.stop();
  log.info('Build done in ${stopwatch.elapsedMilliseconds}ms');
  return 0;
}

Future<void> generateContent(Content content, Config config) async {
  await content.when(
    section: (section) => _buildSection(section, config),
    page: (page) => _buildPage(page, config),
  );
}

Future<void> _buildSection(Section section, Config config) async {
  if (section.index != null) {
    await _buildIndexPage(
      section.index,
      config,
      children: section.children,
    );
  }

  for (var child in section.children) {
    await child.when(
      section: (section) => _buildSection(section, config),
      page: (page) => _buildPage(page, config),
    );
  }
}

Future<void> _buildPage(Page page, Config config) async {
  log.debug('Build: $page');

  final templatesDir = await getTemplatesDirectory(config);
  final template = await File(
    '${templatesDir.path}/page.mustache',
  ).readAsString();

  final mustache = Template(template);

  final metadata = <dynamic, dynamic>{
    'title': page.name,
    'content': page.content,
    'base_url': config.baseUrl,
  };

  log.debug(metadata);

  final output = mustache.renderString(metadata);

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

  final templatesDir = await getTemplatesDirectory(config);
  final template = await File(
    '${templatesDir.path}/section.mustache',
  ).readAsString();

  final mustache = Template(template);

  final output = mustache.renderString(
    <dynamic, dynamic>{
      'title': page.name,
      'content': page.content,
      'children': children.whereType<Page>().map((e) => e.toMap(config)),
    },
  );

  final path = page.getCanonicalPath(config);

  final file = await File(path).create(recursive: true);
  await file.writeAsString(output);
}

Future<void> copyStaticFiles(Config config) async {
  final staticDir = await getStaticDirectory(config);

  final staticContent = await staticDir.list(recursive: true).toList();
  final directories = staticContent.whereType<Directory>();
  final files = staticContent.whereType<File>();

  for (var directory in directories) {
    final path =
        directory.path.replaceFirst('static', config.build.buildFolder);
    await Directory(path).create(
      recursive: true,
    );
  }

  for (var file in files) {
    await file.copy(file.path.replaceFirst('static', config.build.buildFolder));
  }

  log.info('Static files copied');
}
