import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:blake/blake.dart';
import 'package:blake/src/cli.dart';
import 'package:blake/src/content.dart';
import 'package:blake/src/utils.dart';
import 'package:mustache_template/mustache_template.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart' as yaml;

class BuildCommand extends Command<int> {
  @override
  final name = 'build';

  @override
  final description = 'Build static files.';

  @override
  FutureOr<int> run() async {
    print(bluePen('Building in...'));

    Directory publicDir;
    Directory contentDir;

    try {
      publicDir = await Directory('public');
      await publicDir.create();

      contentDir = await Directory('content');
    } catch (e) {
      printError(e);
      return 1;
    }

    try {
      final config = await File('config.yaml').readAsString();
      print(yaml.loadYaml(config));
    } on FileSystemException catch (e) {
      switch (e.osError.errorCode) {
        case 2:
          print(errorPen('Error: config.yaml does not exists.'));
          break;
        default:
          print(errorPen('Error: $e'));
          break;
      }
      return 1;
    }

    final content = await _generateTree(contentDir.path);
    printInfo('Content tree parsed: $content');

    await _renderSection(content, 'public');
    printInfo('Files generated.');

    return 0;
  }

  Future<Section> _generateTree(String root) async {
    final rootDirectory = Directory(root);
    final content = await rootDirectory.list().toList();

    final children = await _mapFileSystem(content);

    return Section(
      name: '.',
      children: children,
    );
  }

  Future<List<Content>> _mapFileSystem(List<FileSystemEntity> entities) async {
    return entities.asyncMap<Content>((e) async {
      if (e is Directory) {
        final _children = await e.list().toList();

        return Section(
          name: basename(e.path),
          children: await _mapFileSystem(_children),
        );
      } else {
        return Page(
          name: basename(e.path),
          content: await (e as File).readAsString(),
        );
      }
    });
  }

  Future<void> _renderSection(Section section, String path) async {
    for (var x in section.children) {
      final _path = '$path/${x.name}';

      if (x is Section) {
        await Directory(_path).create();

        await _renderSection(x, _path);
      } else {
        final file = await File(_path.replaceAll('.md', '.html')).create();

        final template = await File('templates/index.mustache').readAsString();
        final mustache = Template(template);

        final markdown = parse((x as Page).content);

        final output = mustache.renderString(
          <dynamic, dynamic>{
            'title': x.name,
            'content': markdown,
          },
        );

        await file.writeAsString(output);
      }
    }
  }
}
