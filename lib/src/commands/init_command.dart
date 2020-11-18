import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:blake/src/log.dart';
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
    final name = argResults.rest.isEmpty ? '' : argResults.rest.first;

    if (name.isEmpty) {
      log.info('Initializing project in current directory...');
    } else {
      log.info('Initializing project in $name directory');
    }

    try {
      await _initConfig(name);

      await Directory('$name/content').create();
      await Directory('$name/templates').create();
      await Directory('$name/static').create();
    } catch (e) {
      log.severe('Init failed', e);
      return 1;
    }

    log.info('Site initialized successfully');
    return 0;
  }

  Future<void> _initConfig(String root) async {
    final configFile = await File('$root/config.yaml').create(recursive: true);
    final config = await configFile.readAsString();

    if (config.trim().isNotEmpty) {
      log.warning('WARNING: config.yaml file already exists.');
      return;
    }

    log.info('Populating with default values...');

    final defaultConfig = <String, dynamic>{
      'title': 'Static Site',
      'author': 'William Blake',
    };

    final yaml = jsonToYaml(defaultConfig);
    log.debug(yaml);

    try {
      await configFile.writeAsString(yaml);
    } catch (e) {
      log.severe(e);
    }
  }
}

const _description = '''
Setup new project. 

Use `blake init` to initialize project in current repository.
If you want to initialize project in subdirectory call `blake init folder_name`.
''';
