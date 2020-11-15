class ConfigError extends _Error {
  const ConfigError([this.message = '']);

  @override
  final Object message;

  @override
  String get name => 'ConfigError';
}

class BuildError extends _Error {
  const BuildError([this.message]);

  @override
  final Object message;

  @override
  String get name => 'BuildError';
}

abstract class _Error {
  const _Error([this.message]);

  final Object message;

  String get name;

  @override
  String toString() => message == null ? name : '$name: $message';
}
