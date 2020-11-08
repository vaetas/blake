import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:blake/src/assets/reload_js.dart';
import 'package:blake/src/build/build.dart';
import 'package:blake/src/build/build_config.dart';

class BuildCommand extends Command<int> {
  BuildCommand() {
    argParser
      ..addOption(
        'build_folder',
        abbr: 'f',
        defaultsTo: 'public',
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Show more logs.',
        defaultsTo: false,
        negatable: false,
      );
  }

  @override
  final name = 'build';

  @override
  final description = 'Build static files.';

  BuildConfig config = const BuildConfig();

  @override
  FutureOr<int> run() async {
    config = BuildConfig.fromArgResult(argResults);
    await _setupReloadScript();
    return build(config);
  }

  Future<void> _setupReloadScript() async {
    // TODO: Use optional configuration.
    await File('${config.buildFolder}/reload.js')
        .writeAsString(getReloadScript(4041));
  }
}
