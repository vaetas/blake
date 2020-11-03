import 'dart:async';

import 'package:args/command_runner.dart';

class InitCommand extends Command<int> {
  @override
  final name = 'init';

  @override
  final description = 'Setup new project.';

  @override
  FutureOr<int> run() {
    print('Initing...');
    return 0;
  }
}
