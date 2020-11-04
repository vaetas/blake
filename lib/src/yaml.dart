import 'package:meta/meta.dart';

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
  Map<dynamic, dynamic> map, {
  int indentation = 0,
  @required StringBuffer buffer,
}) {
  assert(buffer != null);

  map.forEach((dynamic key, dynamic value) {
    if (value is Map<dynamic, dynamic>) {
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
  @required StringBuffer buffer,
}) {
  assert(buffer != null);

  list.forEach((dynamic e) {
    if (e is Map<dynamic, dynamic>) {
      buffer.write('-'.indent(indentation));
      _writeMap(e, buffer: buffer, indentation: 1);
    } else {
      buffer.write('.- $e\n'.indent(indentation));
    }
  });
}

extension on String {
  String indent(int indentation) {
    return List.generate(indentation, (index) => ' ').join() + this;
  }
}
