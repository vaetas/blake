import 'dart:async';
import 'dart:io';

import 'package:blake/src/build/build_config.dart';
import 'package:blake/src/content.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/markdown/parser.dart';
import 'package:blake/src/utils.dart';
import 'package:html/dom.dart' as html;
import 'package:html/parser.dart' as html;
import 'package:mustache_template/mustache_template.dart';
import 'package:path/path.dart' as p;

Future<int> build(BuildConfig config) async {
  log.fine('Building');
  final stopwatch = Stopwatch()..start();
  final contentDir = await getContentDirectory(config);
  final tree = await parseFileTree(contentDir);

  if (config.verbose) {
    log.fine('Files: $tree');
  }

  await generateContent(tree, config);
  await copyStaticFiles(config);

  stopwatch.stop();
  log.info('Build done in ${stopwatch.elapsedMilliseconds}ms');
  return 0;
}

/// Recursively parse file tree starting from [entity].
Future<Content> parseFileTree(FileSystemEntity entity) async {
  if (entity is File) {
    final content = await entity.readAsString();
    final parsed = parse(content);

    final name = parsed.metadata?.get('title') as String;

    return Page(
      name: name ?? p.basename(entity.path),
      path: entity.path,
      content: parsed.content,
    );
  }

  if (entity is Directory) {
    final children = await entity.list().toList();

    return Section(
      name: p.basename(entity.path),
      children: (await children.asyncMap(parseFileTree)).toList(),
    );
  }

  // TODO: Handle `Link` object.
  throw 'Invalid file tree';
}

Future<void> generateContent(Content content, BuildConfig config) async {
  await content.when(
    section: (section) => _buildSection(section, config),
    page: (page) => _buildPage(page, config),
  );
}

Future<void> _buildSection(Section section, BuildConfig config) async {
  for (var child in section.children) {
    await child.when(
      section: (section) => _buildSection(section, config),
      page: (page) => _buildPage(
        page,
        config,
        index: page.path.endsWith('index.md'),
      ),
    );
  }
}

Future<void> _buildPage(
  Page page,
  BuildConfig config, {
  bool index = false,
  List<Page> subpages = const [],
}) async {
  final templatesDir = await getTemplatesDirectory(config);
  final template = await File(
          '${templatesDir.path}/${index ? 'section.mustache' : 'page.mustache'}')
      .readAsString();
  final mustache = Template(template);

  final output = mustache.renderString(
    <dynamic, dynamic>{
      'title': page.name,
      'content': page.content,
      'children': subpages.map((e) {
        return e.toMap();
      }).toList(),
    },
  );

  final path = page.path
      .replaceFirst(_contentDirPattern, 'public${Platform.pathSeparator}');

  final file = File(path.replaceFirst('.md', '.html'));

  final canonicalPath =
      '${config.baseUrl}:4040/${file.path.replaceFirst('.html', '/').substring(7)}';

  final canonicalTag = '<link rel="canonical" href="$canonicalPath"/>';
  final refreshTag =
      '<meta http-equiv="refresh" content="0; url=$canonicalPath" />';
  final noIndexTag = '<meta name="robots" content="noindex">';

  final alteredOutput = html.parse(output);

  if (!file.isIndex) {
    alteredOutput.head
      ..append(html.Element.html(canonicalTag))
      ..append(html.Element.html(refreshTag))
      ..append(html.Element.html(noIndexTag));
  }

  if (!await file.exists()) {
    await file.create(recursive: true);
  }

  await file.writeAsString(alteredOutput.outerHtml, mode: FileMode.write);

  // For each post like /hello.html create /hello/index.html page which will
  // redirect user.
  if (!file.isIndex) {
    // TODO: Redirect user.
    final canonicalFile = await File(
      file.path.replaceFirst(
        '.html',
        '${Platform.pathSeparator}index.html',
      ),
    ).create(recursive: true);
    await canonicalFile.writeAsString(output);
  }
}

Future<void> copyStaticFiles(BuildConfig config) async {
  final staticDir = await getStaticDirectory(config);

  final staticContent = await staticDir.list(recursive: true).toList();
  final directories = staticContent.whereType<Directory>();
  final files = staticContent.whereType<File>();

  for (var directory in directories) {
    final path = directory.path.replaceFirst('static', config.buildFolder);
    print(path);
    await Directory(path).create(
      recursive: true,
    );
  }

  for (var file in files) {
    await file.copy(file.path.replaceFirst('static', config.buildFolder));
  }

  if (config.verbose) {
    print('Static files copied');
  }
}

final _contentDirPattern = RegExp(r'^(\.\\|\.\/|\\|\/)?content[\\\/]{1}');

extension on FileSystemEntity {
  String get basename {
    return p.basename(path);
  }

  bool get isIndex {
    return basename == 'index.html';
  }
}
