import 'dart:async';

import 'package:blake/src/assets/reload_js.dart';
import 'package:blake/src/build/build.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/serve/local_server.dart';
import 'package:blake/src/serve/watch.dart';

/// Build and serve static files on local server with live-reload support.
Future<int> serve(Config config) async {
  // Build once before starting server to ensure there is something to show.
  await build(config);

  log.info('Copy reload.js script');
  await setupReloadScript(config);

  final _onReload = StreamController<void>();

  watch('.').listen((event) async {
    final stopwatch = Stopwatch()..start();
    await build(config);
    stopwatch.stop();
    _onReload.add(null);
  });

  log.info(config.serve);

  await LocalServer(
    config.build.publicFolder,
    address: config.serve.baseUrl.host,
    port: config.serve.baseUrl.port,
    websocketPort: config.serve.websocketPort,
    onReload: _onReload.stream.asBroadcastStream(),
  ).start();

  return 0;
}
