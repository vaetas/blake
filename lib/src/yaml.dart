String jsonToYaml(dynamic json) {
  final buffer = StringBuffer();

  if (json is Map<String, dynamic>) {
    _writeMap(json, buffer: buffer);
  } else if (json is List<dynamic>) {
    _writeList(json, buffer: buffer);
  } else {
    throw ArgumentError();
  }

  return buffer.toString();
}

void _writeMap(
  Map<String, dynamic> map, {
  int indentation = 0,
  required StringBuffer buffer,
}) {
  map.forEach((String key, dynamic value) {
    if (value is Map<String, dynamic>) {
      buffer.write('$key:\n');
      _writeMap(value, indentation: indentation + 2, buffer: buffer);
    } else if (value is List<dynamic>) {
      _writeList(value, indentation: indentation + 2, buffer: buffer);
    } else {
      buffer.write('$key: $value\n'.indent(indentation));
    }
  });
}

void _writeList(
  List<dynamic> list, {
  int indentation = 0,
  required StringBuffer buffer,
}) {
  for (final element in list) {
    if (element is Map<String, dynamic>) {
      buffer.write('-'.indent(indentation));
      _writeMap(element, buffer: buffer, indentation: 1);
    } else {
      buffer.write('.- $element\n'.indent(indentation));
    }
  }
}

extension on String {
  String indent(int indentation) {
    return List.generate(indentation, (index) => ' ').join() + this;
  }
}
