import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

class ServeConfig {
  ServeConfig({
    String address = '127.0.0.1',
    this.port = 4040,
    this.websocketPort = 4041,
  }) : baseUrl = _parseAddress(address, port);

  factory ServeConfig.fromYaml(YamlMap yaml) {
    return ServeConfig(
      address: yaml.get('address', '127.0.0.1'),
      port: yaml.get(_kPort, 4040),
      websocketPort: yaml.get(_kWebsocketPort, 4041),
    );
  }

  final Uri baseUrl;
  final int port;
  final int websocketPort;

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
