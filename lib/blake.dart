import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:args/command_runner.dart';
import 'package:blake/src/commands/build_command.dart';
import 'package:blake/src/commands/init_command.dart';
import 'package:blake/src/commands/new_command.dart';
import 'package:blake/src/commands/serve_command.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/git_util.dart';
import 'package:blake/src/log.dart';

export 'src/build/build_config.dart';
export 'src/content/content.dart';
export 'src/file_system.dart';
export 'src/serve/local_server.dart';
export 'src/serve/serve_config.dart';

/// [Blake] class ties together all commands and exports callable method for
/// running this program.
class Blake {
  final runner = CommandRunner<int>('blake', 'Blake Static Site Generator');

  Future<int> call(List<String> args) async {
    runner.addCommand(InitCommand());
    ansiColorDisabled = false;

    if (!await isProjectDirectory()) {
      return runner.run(args);
    } else {
      await _ensureGit();

      final config = await getConfig();
      return config.when(
        (error) {
          log.error(error.message);
          return 1;
        },
        (config) {
          runner
            ..addCommand(BuildCommand(config))
            ..addCommand(ServeCommand(config))
            ..addCommand(NewCommand(config));

          return runner.run(args);
        },
      );
    }
  }

  Future<void> _ensureGit() async {
    if (!await GitUtil.isGitInstalled()) {
      log.error('Git must be installed on the system to use Blake.');
      exit(1);
    }

    if (!await GitUtil.isGitDir()) {
      log.error(
        'Project is not a git repository.',
        help: 'Use `git init` to initialize a repository.',
      );
      exit(1);
    }
  }
}
