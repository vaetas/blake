class ConfigError extends BlakeError {
  const ConfigError(String message) : super(message);

  @override
  String get name => 'ConfigError';
}

class BuildError extends BlakeError {
  const BuildError(String message, [String? help]) : super(message, help);

  @override
  String get name => 'BuildError';
}

class CommandError extends BlakeError {
  const CommandError(String message) : super(message);

  @override
  String get name => 'CommandError';
}

abstract class BlakeError implements Exception {
  const BlakeError([this.message, this.help]);

  final Object? message;

  final String? help;

  String get name;

  @override
  String toString() => message == null ? name : '$name: $message';
}
