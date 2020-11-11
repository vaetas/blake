import 'dart:async';

import 'package:blake/src/build/build.dart';
import 'package:blake/src/build/build_config.dart';
import 'package:blake/src/log.dart';
import 'package:blake/src/serve/local_server.dart';
import 'package:blake/src/serve/serve_config.dart';
import 'package:blake/src/serve/watch.dart';
import 'package:meta/meta.dart';

Future<int> serve({
  @required ServeConfig serveConfig,
  @required BuildConfig buildConfig,
}) async {
  // Build once before starting server to ensure there is something to show.
  await build(buildConfig);

  final _onReload = StreamController<void>();

  await watch('.').listen((event) async {
    final stopwatch = Stopwatch()..start();
    await build(buildConfig);
    stopwatch.stop();
    _onReload.add(null);
  });

  log.warning('Serve config: ${serveConfig}');

  await LocalServer(
    buildConfig.buildFolder,
    address: serveConfig.address,
    port: serveConfig.port,
    onReload: _onReload.stream.asBroadcastStream(),
  ).start();

  return 0;
}
