import 'package:args/command_runner.dart';
import 'package:blake/src/commands/serve.dart';

import 'file:///C:/Users/vojtech/dev/blake/lib/src/commands/build.dart';
import 'file:///C:/Users/vojtech/dev/blake/lib/src/commands/init.dart';

export 'src/markdown/parser.dart';

class Blake {
  final _runner = CommandRunner<int>('blake', 'Blake Static Site Generator')
    ..addCommand(BuildCommand())
    ..addCommand(ServeCommand())
    ..addCommand(InitCommand());

  Future<int> call(List<String> args) async {
    final stopwatch = Stopwatch()..start();
    final exitCode = await _runner.run(args);
    stopwatch.stop();

    print('Done in ${stopwatch.elapsed.inMilliseconds} milliseconds.');
    return exitCode;
  }
}
