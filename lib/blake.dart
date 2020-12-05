import 'package:ansicolor/ansicolor.dart';
import 'package:args/command_runner.dart';
import 'package:blake/src/commands/new_command.dart';
import 'package:blake/src/commands/build_command.dart';
import 'package:blake/src/commands/init_command.dart';
import 'package:blake/src/commands/serve_command.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/log.dart';

export 'src/build/build.dart';
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
            ..addCommand(NewCommand(config)); // :)

          return runner.run(args);
        },
      );
    }
  }
}
