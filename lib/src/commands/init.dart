import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:blake/src/cli.dart';
import 'package:blake/src/yaml.dart';

class InitCommand extends Command<int> {
  @override
  final name = 'init';

  @override
  String get summary => 'Setup new project.';

  @override
  final description = _description;

  @override
  FutureOr<int> run() async {
    final name = argResults.rest.isEmpty ? '' : argResults.rest.first + '/';

    if (name.isEmpty) {
      print(bluePen('Initializing project in current directory...'));
    } else {
      printInfo('Initializing project in $name directory');
    }

    try {
      await _initConfig(name);
      final contentDir = await Directory(name + 'content').create(
        recursive: true,
      );
    } catch (e) {
      print('Error: $e');
      return 1;
    }

    return 0;
  }

  Future<void> _initConfig(String root) async {
    final configFile = await File(root + 'config.yaml').create(recursive: true);
    final config = await configFile.readAsString();

    if (config.trim().isNotEmpty) {
      printWarning('WARNING: Config is not empty and will be rewritten.');
    }

    printInfo('Populating with default values...');

    final defaultConfig = <String, dynamic>{
      'title': 'Static Site',
      'author': 'William Blake',
    };

    final yaml = jsonToYaml(defaultConfig);
    print(yaml);

    try {
      await configFile.writeAsString(yaml);
    } catch (e) {
      printError(e);
    }
  }
}

final _description = '''
Setup new project. 

Use `blake init` to initialize project in current repository.
If you want to initialize project in subdirectory call `blake init folder_name`.
''';