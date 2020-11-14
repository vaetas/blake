import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:blake/src/build/build.dart';
import 'package:blake/src/config.dart';

class BuildCommand extends Command<int> {
  BuildCommand(this.config) {
    argParser
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Show more logs.',
        defaultsTo: false,
        negatable: false,
      );
  }

  final Config config;

  @override
  final name = 'build';

  @override
  final description = 'Build static files.';

  @override
  FutureOr<int> run() async {
    return build(config);
  }
}
