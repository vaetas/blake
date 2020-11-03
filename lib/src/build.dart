import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:blake/src/cli.dart';
import 'package:yaml/yaml.dart' as yaml;

class BuildCommand extends Command<int> {
  @override
  final name = 'build';

  @override
  final description = 'Build static files.';

  @override
  FutureOr<int> run() async {
    print(bluePen('Building...'));

    try {
      final publicDir = await Directory('public').create();
    } catch (e) {
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

    return 0;
  }
}
