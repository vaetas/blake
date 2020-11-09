import 'package:args/args.dart';

class ServeConfig {
  ServeConfig({
    this.address = 'http://127.0.0.1',
    this.port = 4040,
  });

  ServeConfig.fromArgResult(ArgResults results)
      : this(
          address: results['address'] as String,
          port: int.parse(results['port'] as String),
        );

  final String address;
  final int port;

  @override
  String toString() => 'ServeConfig{address: $address, port: $port}';
}
