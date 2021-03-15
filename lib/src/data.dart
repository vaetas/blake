import 'dart:convert';

import 'package:blake/src/config.dart';
import 'package:blake/src/errors.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

/// Parse all YAML and JSON files inside `data_dir` and create data Map which
/// you can access inside templates.
///
/// Each subfolder inside `data_dir` becomes a key inside the returned
/// Map<String, dynamic>. Therefore it does not matter if you use single file
/// with deeply nested data or split the data into more files (data tree will
/// be the same).
///
/// See `example` directory for reference.
Future<Map<String, dynamic>> parseDataTree(
  Config config, {
  String? path,
}) async {
  final data = <String, dynamic>{};
  path ??= config.build.dataDir;
  final nodes = await fs.directory(path).list().toList();

  for (final e in nodes) {
    await e.when(
      directory: (directory) async {
        final name = Path.basename(directory.path);
        data[name] = await parseDataTree(config, path: directory.path);
      },
      file: (file) async {
        final name = Path.basenameWithoutExtension(file.path);
        try {
          final dynamic content = await _parseData(file) as dynamic;
          data[name] = content;
        } catch (e) {
          log.error(e);
        }
      },
    );
  }

  return data;
}

dynamic _parseData(File file) async {
  final extension =
      Path.extension(file.path).toLowerCase().replaceFirst('.', '');
  final content = await file.readAsString();

  switch (extension) {
    case 'yaml':
      final dynamic yaml = loadYaml(content);
      if (yaml is YamlList) {
        return yaml.value;
      }

      return (yaml as YamlMap).value;
    case 'json':
      return jsonDecode(content);
    default:
      throw BuildError('Invalid data format: $extension');
  }
}
