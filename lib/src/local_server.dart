import 'dart:io';

import 'package:http_server/http_server.dart';

class LocalServer {
  LocalServer(
    this.path, {
    this.address = '127.0.0.1',
    this.port = 4040,
  });

  /// Directory where should the [LocalServer] be started.
  final String path;

  /// Server address.
  final String address;

  final int port;

  HttpServer server;

  Future<void> start() async {
    final directory = VirtualDirectory(path);

    directory
      ..allowDirectoryListing = false
      ..directoryHandler = (dir, request) {
        final indexUri = Uri.file(dir.path).resolve('index.html');

        directory.serveFile(File(indexUri.toFilePath()), request);
      };

    server = await HttpServer.bind(address, port);
    print('Server started on $address:$port');

    await server.forEach(directory.serveRequest);
  }
}
