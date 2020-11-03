import 'package:args/command_runner.dart';
import 'package:blake/src/build.dart';
import 'package:blake/src/init.dart';

export 'src/markdown/parser.dart';

class Blake {
  final _runner = CommandRunner<int>('blake', 'Blake Static Site Generator')
    ..addCommand(BuildCommand())
    ..addCommand(InitCommand());

  void call(List<String> args) => _runner.run(args);
}
