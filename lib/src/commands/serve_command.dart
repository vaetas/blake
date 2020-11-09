import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:blake/src/build/build_config.dart';
import 'package:blake/src/cli.dart';
import 'package:blake/src/serve/serve.dart';
import 'package:blake/src/serve/serve_config.dart';

class ServeCommand extends Command<int> {
  ServeCommand() {
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

  @override
  FutureOr<int> run() async {
    printInfo('Serving...');
    final serveConfig = ServeConfig.fromArgResult(argResults);
    final buildConfig = const BuildConfig();

    return serve(
      serveConfig: serveConfig,
      buildConfig: buildConfig,
    );
  }
}

final _description = '''Starts local web server and watches for file changes. 
After every change the website will be rebuilt.''';
