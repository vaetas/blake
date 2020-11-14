import 'dart:io';

import 'package:blake/src/config.dart';
import 'package:mustache_template/mustache_template.dart';

Future<void> setupReloadScript(Config config) async {
  await File(
    '${config.build.buildFolder}/reload.js',
  ).writeAsString(_getReloadScript(config));
}

String _getReloadScript(Config config) {
  return Template(_reloadScript).renderString(
    <String, dynamic>{
      'websocket_port': config.serve.websocketPort,
    },
  );
}

const _reloadScript = r'''
const address = 'ws://localhost:{{ websocket_port }}';

function connect() {
  try {
    const socket = new WebSocket(address);

    socket.onmessage = function() {
      location.reload();
    };
    socket.onclose = function() {
      console.log('Connection closed.')
      connect();
    }
  } catch (error) {
    console.log(`Error ${error}`);
    setInterval(() => {
      connect();
    }, 1000);
  }
}

connect();
''';
