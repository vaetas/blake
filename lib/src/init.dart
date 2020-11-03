import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:blake/src/cli.dart';
import 'package:blake/src/yaml.dart';

class InitCommand extends Command<int> {
  @override
  final name = 'init';

  @override
  final description = 'Setup new project.';

  @override
  FutureOr<int> run() async {
    print(bluePen('Initing project...'));

    try {
      await _initConfig();
      final contentDir = await Directory('content').create();
    } catch (e) {
      print('Error: $e');
      return 1;
    }

    return 0;
  }

  Future<void> _initConfig() async {
    final configFile = await File('config.yaml').create();
    final config = await configFile.readAsString();

    if (config.trim().isEmpty) {
      printWarning('Config file is empty. Populating with default values...');

      final m = <String, String>{
        'title': '',
        'author': '',
      };

      try {
        await configFile.writeAsString(jsonToYaml(m));
      } catch (e) {
        printError(e);
      }
    } else {
      printWarning('Config file already exists');
    }
  }
}
