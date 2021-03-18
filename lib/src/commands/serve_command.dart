import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:blake/src/assets/reload_js.dart';
import 'package:blake/src/commands/build_command.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/serve/local_server.dart';
import 'package:blake/src/serve/watch.dart';
import 'package:glob/glob.dart';

/// Build and serve static files on local server with live-reload support.
///
/// Only following files and folders are watched:
///   config.yaml
///   content/
///   data/
///   static/
///   templates/
///
/// Changing other files will not trigger rebuild.
class ServeCommand extends Command<int> {
  ServeCommand(this.config) {
    argParser
      ..addOption('address', abbr: 'a', defaultsTo: '127.0.0.1')
      ..addOption('port', abbr: 'p', defaultsTo: '4040')
      ..addOption('websocket-port', defaultsTo: '4041');

    log.verbose = config.serve.verbose;
  }

  @override
  final String name = 'serve';

  @override
  final String summary = 'Start local server.';

  @override
  final String description = _description;

  final Config config;

  late BuildCommand buildCommand;

  @override
  FutureOr<int> run() async => _serve();

  Future<int> _rebuild() async {
    return buildCommand.build(
      config,
      isServe: true,
    );
  }

  Future<int> _serve() async {
    buildCommand = BuildCommand(config);
    // Build once before starting server to ensure there is something to show.
    await _rebuild();

    try {
      await setupReloadScript(config);
      log.debug('Reload script copied');
    } catch (e) {
      log.error('Failed to copy reload script', error: e);
      return 1;
    }

    final _onReload = StreamController<void>();

    final glob = Glob(
      '{'
      'config.yaml,'
      '${config.build.contentDir}/**,'
      '${config.build.dataDir}/**,'
      '${config.build.staticDir}/**,'
      '${config.build.templatesDir}/**'
      '}',
    );

    watch('.', files: glob).listen((event) async {
      // ignore: avoid_print
      print('');
      log.info('Event: $event');
      await _rebuild();
      _onReload.add(null);
    });

    log.debug(config.serve);

    await LocalServer(
      config.build.publicDir,
      address: config.serve.baseUrl.host,
      port: config.serve.baseUrl.port,
      websocketPort: config.serve.websocketPort,
      onReload: _onReload.stream.asBroadcastStream(),
    ).start();

    return 0;
  }
}

const _description = '''Starts local web server and watches for file changes. 
After every change the website will be rebuilt.''';
