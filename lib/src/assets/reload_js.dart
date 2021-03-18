import 'package:blake/src/config.dart';
import 'package:blake/src/file_system.dart';
import 'package:jinja/jinja.dart';

Future<void> setupReloadScript(Config config) async {
  final publicDir = await getPublicDirectory(config);

  await publicDir
      .childFile('reload.js')
      .writeAsString(_getReloadScript(config));
}

String _getReloadScript(Config config) {
  return Template(_reloadScript).renderMap(
    <String, dynamic>{
      'port': config.serve.websocketPort,
    },
  );
}

const _reloadScript = r'''
const address = 'ws://localhost:{{ port }}';

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
