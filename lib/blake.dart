import 'package:args/command_runner.dart';
import 'package:blake/src/commands/build.dart';
import 'package:blake/src/commands/init.dart';
import 'package:blake/src/commands/serve.dart';

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
