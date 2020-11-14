import 'package:args/args.dart';
import 'package:blake/src/utils.dart';
import 'package:yaml/yaml.dart';

class ServeConfig {
  ServeConfig({
    String address = 'http://127.0.0.1',
    this.port = 80,
    this.websocketPort = 4041,
  }) : baseUrl = _parseAddress(address, port);

  ServeConfig.fromArgResult(ArgResults results)
      : this(
          address: results.get<String>('address'),
          port: results.get<int>('port'),
          websocketPort: results.get<int>('websocket-port'),
        );

  ServeConfig.fromYaml(YamlMap yaml)
      : this(
          address: yaml['address'] as String,
          port: yaml['port'] as int,
          websocketPort: yaml['websocket_port'] as int,
        );

  Uri baseUrl;
  int port;
  int websocketPort;

  @override
  String toString() {
    return 'ServeConfig{baseUrl: $baseUrl, port: $port, websocketPort: $websocketPort}';
  }
}

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
