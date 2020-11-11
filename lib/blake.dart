import 'package:args/command_runner.dart';
import 'package:blake/src/commands/build_command.dart';
import 'package:blake/src/commands/init_command.dart';
import 'package:blake/src/commands/serve_command.dart';
import 'package:blake/src/file_system.dart';
import 'package:blake/src/log.dart';

export 'src/build/build.dart';
export 'src/content/content.dart';
export 'src/file_system.dart';

class Blake {
  final runner = CommandRunner<int>('blake', 'Blake Static Site Generator');

  Future<int> call(List<String> args) async {
    final config = await getConfig();
    setupLogging(verbose: true);

    runner
      ..addCommand(BuildCommand(config))
      ..addCommand(ServeCommand(config))
      ..addCommand(InitCommand());

    return runner.run(args);
  }
}

final blake = Blake();
