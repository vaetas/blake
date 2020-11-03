import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:blake/src/cli.dart';

class InitCommand extends Command<int> {
  @override
  final name = 'init';

  @override
  final description = 'Setup new project.';

  @override
  FutureOr<int> run() async {
    print(bluePen('Initing project...'));

    try {
      final configFile = await File('config.yaml').create();
      final contentDir = await Directory('content').create();
    } catch (e) {
      print('Error: $e');
      return 1;
    }

    return 0;
  }
}
