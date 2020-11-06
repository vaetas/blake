import 'dart:async';
import 'dart:io';

import 'package:blake/src/cli.dart';
import 'package:http_server/http_server.dart';

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

  var _websocketListened = false;

  Future<void> start() async {
    final directory = VirtualDirectory(path);

    directory
      ..allowDirectoryListing = true
      ..directoryHandler = (dir, request) {
        final indexUri = Uri.file(dir.path).resolve('index.html');
        directory.serveFile(File(indexUri.toFilePath()), request);
      };

    // ignore: unawaited_futures
    _startWebsocket();

    server = await HttpServer.bind(address, port);
    print('Server started on http://$address:$port');
    await server.forEach(directory.serveRequest);
  }

  // TODO: Set websocket port as a CLI option.
  Future<void> _startWebsocket() async {
    StreamSubscription<void> _sub;
    final websocket = await HttpServer.bind(address, websocketPort);
    await websocket.transform(WebSocketTransformer()).listen(
      (WebSocket socket) async {
        _websocketListened = true;
        await _sub?.cancel();
        _sub = onReload.listen((event) {
          socket.add('reload_event');
        });
      },
    );

    onReload.listen((event) {
      if (!_websocketListened) {
        printWarning(
          'No WebSocket client is connected. Please refresh your browser.',
        );
      }
    });
  }
}
