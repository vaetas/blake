import 'dart:async';

import 'package:blake/src/assets/reload_js.dart';
import 'package:blake/src/build/build.dart';
import 'package:blake/src/config.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/serve/local_server.dart';
import 'package:blake/src/serve/watch.dart';

Future<int> serve(Config config) async {
  // Build once before starting server to ensure there is something to show.
  await build(config);

  log.info('Copy reload.js script');
  await setupReloadScript(config);

  final _onReload = StreamController<void>();

  await watch('.').listen((event) async {
    final stopwatch = Stopwatch()..start();
    await build(config);
    stopwatch.stop();
    _onReload.add(null);
  });

  log.info('Serve config: ${config.serve}');

  await LocalServer(
    config.build.buildFolder,
    address: config.serve.address,
    port: config.serve.port,
    onReload: _onReload.stream.asBroadcastStream(),
  ).start();

  return 0;
}
