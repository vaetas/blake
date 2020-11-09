import 'package:args/args.dart';

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

  final String address;
  final int port;
  final int websocketPort;

  @override
  String toString() {
    return 'ServeConfig{address: $address, port: $port, websocketPort: $websocketPort}';
  }
}
