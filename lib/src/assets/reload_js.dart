import 'package:mustache_template/mustache_template.dart';

const _reloadScript = '''
var socket = new WebSocket('ws://localhost:{{ websocket_port }}');
socket.onmessage = function(event) {
  location.reload();
};
''';

String getReloadScript(int websocketPort) {
  return Template(_reloadScript).renderString(
    <String, dynamic>{
      'websocket_port': websocketPort,
    },
  );
}
