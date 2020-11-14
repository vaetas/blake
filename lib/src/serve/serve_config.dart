import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

class ServeConfig {
  ServeConfig({
    String address,
    int port,
    int websocketPort,
  }) {
    this.port = port ?? 4040;
    this.websocketPort = websocketPort ?? 4041;
    baseUrl = _parseAddress(address ?? '127.0.0.1', this.port);
  }

  factory ServeConfig.fromYaml(YamlMap map) {
    assert(map != null);
    return ServeConfig(
      address: map.get('address'),
      port: map.get(_kPort),
      websocketPort: map.get(_kWebsocketPort),
    );
  }

  Uri baseUrl;
  int port;
  int websocketPort;

  @override
  String toString() => 'ServeConfig${toMap()}';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'base_url': baseUrl.toString(),
      _kPort: port,
      _kWebsocketPort: websocketPort,
    };
  }
}

const _kPort = 'port';
const _kWebsocketPort = 'websocket_port';

/// Parse configured base_url.
///
/// This will extract address properties from both `127.0.0.1` or `http://127.0.0.1/`
/// and configuration is more permissive.
Uri _parseAddress(String address, int port) {
  if (_ipv4Pattern.hasMatch(address)) {
    return Uri(scheme: 'http', host: address, port: port);
  } else if (_httpPattern.hasMatch(address)) {
    final match = _httpPattern.firstMatch(address);
    final _url = address.substring(match.start, match.end);
    return Uri(scheme: 'http', host: _url, port: port);
  } else {
    throw ArgumentError('Invalid base_url');
  }
}

final _ipv4Pattern = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
final _httpPattern = RegExp(r'(?:[0-9]{1,3}\.){3}[0-9]{1,3}');
