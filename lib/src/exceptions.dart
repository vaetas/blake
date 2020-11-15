class ConfigException implements Exception {
  ConfigException([this.message = '']);

  final String message;

  @override
  String toString() {
    return message.isEmpty ? 'ConfigException' : 'ConfigException: $message';
  }
}
