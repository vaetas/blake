String jsonToYaml(Map<String, dynamic> json) {
  final buffer = StringBuffer();
  json.forEach((key, dynamic value) {
    buffer..write('$key: $value\n');
  });
  return buffer.toString();
}
