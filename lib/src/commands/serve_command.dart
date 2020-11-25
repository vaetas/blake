import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/serve/serve.dart';

class ServeCommand extends Command<int> {
  ServeCommand(this.config) {
    argParser
      ..addOption('address', abbr: 'a', defaultsTo: '127.0.0.1')
      ..addOption('port', abbr: 'p', defaultsTo: '4040')
      ..addOption('websocket-port', defaultsTo: '4041');
  }

  @override
  final String name = 'serve';

  @override
  final String summary = 'Start local server.';

  @override
  final String description = _description;

  final Config config;

  @override
  FutureOr<int> run() async {
    // TODO: Merge CLI options with config.
    return serve(config);
  }
}

const _description = '''Starts local web server and watches for file changes. 
After every change the website will be rebuilt.''';
