import 'package:blake/src/exceptions.dart';
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
    baseUrl = parseAddress(address ?? '127.0.0.1', this.port);
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
Uri parseAddress(String address, int port) {
  if (_addressPattern.hasMatch(address)) {
    final match = _hostPattern.firstMatch(address);
    final host = address.substring(match.start, match.end);
    return Uri(scheme: 'http', host: host, port: port);
  } else {
    throw ConfigException('Invalid address format: $address');
  }
}

final _hostPattern = RegExp(r'(?:[0-9]{1,3}\.){3}[0-9]{1,3}');
final _addressPattern =
    RegExp(r'^(http\:\/\/)?(?:[0-9]{1,3}\.){3}[0-9]{1,3}(\/)?$');
