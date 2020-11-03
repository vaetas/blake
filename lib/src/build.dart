import 'dart:async';

import 'package:args/command_runner.dart';

class BuildCommand extends Command<int> {
  @override
  final name = 'build';

  @override
  final description = 'Build static files.';

  @override
  FutureOr<int> run() {
    print('Running...');
    return 0;
  }
}
