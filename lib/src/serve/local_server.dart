import 'dart:async';
import 'dart:io' show HttpServer, WebSocket, WebSocketTransformer;

import 'package:blake/blake.dart';
import 'package:blake/src/log.dart';
import 'package:http_server/http_server.dart';

/// Local web server used for `blake serve` command.
///
/// This server binds to [address] and starts both HTTP and WebSocket (for
/// live-reload) handler.
class LocalServer {
  LocalServer(
    this.path, {
    this.address = '127.0.0.1',
    this.port = 4040,
    this.websocketPort = 4041,
    this.onReload,
  });

  /// Directory where should the [LocalServer] be started.
  final String path;

  /// Server address.
  final String address;

  final int port;

  final int websocketPort;

  final Stream<void> onReload;

  HttpServer server;

  Future<void> start() async {
    final directory = VirtualDirectory(path);

    directory
      ..allowDirectoryListing = true
      ..directoryHandler = (dir, request) {
        final indexUri = Uri.file(dir.path).resolve('index.html');
        directory.serveFile(fs.file(indexUri.toFilePath()), request);
      };

    try {
      // ignore: unawaited_futures
      _startWebsocket();
    } catch (e) {
      log.error('Failed to start WebSocket server.');
      return;
    }

    server = await HttpServer.bind(address, port);
    log.info('Server started on http://$address:$port');
    await server.forEach(directory.serveRequest);
  }

  Future<void> _startWebsocket() async {
    StreamSubscription<void> _sub;
    final websocket = await HttpServer.bind(address, websocketPort);
    websocket.transform(WebSocketTransformer()).listen(
      (WebSocket socket) async {
        await _sub?.cancel();
        _sub = onReload.listen((event) {
          socket.add('reload_event');
        });
      },
    );
  }
}
