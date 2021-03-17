import 'package:blake/src/errors.dart';
import 'package:yaml/yaml.dart';

/// Configuration specific to `build serve` command.
class ServeConfig {
  ServeConfig({
    this.port = 4040,
    this.websocketPort = 4041,
    this.verbose = false,
  }) : baseUrl = Uri(host: '127.0.0.1', scheme: 'http', port: port);

  factory ServeConfig.fromYaml(YamlMap? map) {
    if (map == null) {
      return ServeConfig();
    }

    return ServeConfig(
      port: map[_kPort] as int? ?? 4040,
      websocketPort: map[_kWebsocketPort] as int? ?? 4041,
      verbose: map[_kVerbose] as bool? ?? false,
    );
  }

  late final Uri baseUrl;
  late final int port;
  late final int websocketPort;
  late final bool verbose;

  @override
  String toString() => 'ServeConfig${toMap()}';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      _kPort: port,
      _kWebsocketPort: websocketPort,
      _kVerbose: verbose,
    };
  }
}

const _kPort = 'port';
const _kWebsocketPort = 'websocket_port';
const _kVerbose = 'verbose';

/// Parse configured base_url.
///
/// This will extract address properties from both `127.0.0.1` or `http://127.0.0.1/`
/// and configuration is more permissive.
Uri parseAddress(String address, int port) {
  if (_addressPattern.hasMatch(address)) {
    final match = _hostPattern.firstMatch(address);
    final host = address.substring(match!.start, match.end);
    return Uri(scheme: 'http', host: host, port: port);
  } else {
    throw ConfigError('Invalid address format: $address');
  }
}

final _hostPattern = RegExp(r'(?:[0-9]{1,3}\.){3}[0-9]{1,3}');
final _addressPattern =
    RegExp(r'^(http\:\/\/)?(?:[0-9]{1,3}\.){3}[0-9]{1,3}(\/)?$');
