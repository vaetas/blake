import 'package:args/command_runner.dart';
import 'package:blake/src/commands/build_command.dart';
import 'package:blake/src/commands/init_command.dart';
import 'package:blake/src/commands/serve_command.dart';

export 'src/build/build.dart';
export 'src/content.dart';
export 'src/file_system.dart';

class Blake {
  final runner = CommandRunner<int>('blake', 'Blake Static Site Generator')
    ..addCommand(BuildCommand())
    ..addCommand(ServeCommand())
    ..addCommand(InitCommand());

  Future<int> call(List<String> args) {
    return runner.run(args);
  }
}

final blake = Blake();
