class ConfigError extends _Error {
  const ConfigError(String message) : super(message);

  @override
  String get name => 'ConfigError';
}

class BuildError extends _Error {
  const BuildError(String message) : super(message);

  @override
  String get name => 'BuildError';
}

class CommandError extends _Error {
  const CommandError(String message) : super(message);

  @override
  String get name => 'CommandError';
}

abstract class _Error implements Exception {
  const _Error([this.message]);

  final Object message;

  String get name;

  @override
  String toString() => message == null ? name : '$name: $message';
}
