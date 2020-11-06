import 'dart:async';
import 'dart:io';

import 'package:http_server/http_server.dart';

class LocalServer {
  LocalServer(
    this.path, {
    this.address = '127.0.0.1',
    this.port = 4040,
    this.onReload,
  });

  /// Directory where should the [LocalServer] be started.
  final String path;

  /// Server address.
  final String address;

  final int port;

  final Stream<void> onReload;

  HttpServer server;

  Future<void> start() async {
    final directory = VirtualDirectory(path);

    directory
      ..allowDirectoryListing = false
      ..directoryHandler = (dir, request) {
        final indexUri = Uri.file(dir.path).resolve('index.html');

        directory.serveFile(File(indexUri.toFilePath()), request);
      };

    final websocket = await HttpServer.bind('127.0.0.1', 4041);
    await websocket
        .transform(WebSocketTransformer())
        .listen((WebSocket socket) async {
      print('Request: ${socket}');

      onReload.listen((event) {
        print('[LocalServer] Sending reload request to WebSocket.');
        socket.add('Reloaded');
      });

      await socket.listen(
        (dynamic msg) {
          print('got $msg');
        },
        onDone: () => print('Done'),
        onError: (dynamic e) => print('Error $e'),
      );
    });

    server = await HttpServer.bind(address, port);

    print('Server started on $address:$port');

    await server.forEach(directory.serveRequest);
  }
}
