import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

class ServeConfig {
  const ServeConfig({
    this.address = 'http://127.0.0.1',
    this.port = 80,
    this.websocketPort = 4041,
  });

  ServeConfig.fromArgResult(ArgResults results)
      : this(
          address: results['address'] as String,
          port: int.parse(results['port'] as String),
          websocketPort: int.parse(results['websocket-port'] as String),
        );

  ServeConfig.fromYaml(YamlMap yaml)
      : this(
          address: yaml['address'] as String,
          port: yaml['port'] as int,
          websocketPort: yaml['websocket_port'] as int,
        );

  final String address;
  final int port;
  final int websocketPort;

  @override
  String toString() {
    return 'ServeConfig{address: $address, port: $port, websocketPort: $websocketPort}';
  }
}
