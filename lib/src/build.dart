import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:blake/src/cli.dart';

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

    return 0;
  }
}
