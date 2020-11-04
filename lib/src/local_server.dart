import 'dart:io';

import 'package:blake/src/cli.dart';

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
    server = await HttpServer.bind(address, port);
    printInfo('Server started on $address:$port');

    await server.listen((request) async {
      print('Request: ${request.uri}');

      try {
        final file = await File('$path/${request.uri}').readAsString();
        request.response.write(file);
      } catch (e) {
        printError(e);
      }

      await request.response.close();
    });
  }
}
