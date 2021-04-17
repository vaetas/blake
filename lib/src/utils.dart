import 'dart:convert';

import 'package:path/path.dart' as p;

class Path {
  Path._();

  /// Join path elements with '/' separator.
  static String join(
    String part1, [
    String? part2,
    String? part3,
    String? part4,
  ]) {
    return normalize(p.join(part1, part2, part3, part4));
  }

  static String basenameWithoutExtension(String path) {
    return p.basenameWithoutExtension(path);
  }

  static String basename(String path) {
    return p.basename(path);
  }

  static String extension(String path) {
    return p.extension(path);
  }

  static String dirname(String path) {
    return p.dirname(path);
  }

  static String normalize(String path) {
    return p.normalize(path).replaceAll(r'\', '/');
  }
}

extension IterableExtension<E> on Iterable<E> {
  /// Allows mapping list with async [mapper]. All mapped elements are run at
  /// the same time and returned `Future` ends when last element is finished.
  Future<List<T>> asyncMap<T>(Future<T> Function(E e) mapper) async {
    return Future.wait<T>(map((i) async => mapper(i)));
  }
}

String prettyJson(Object json) {
  return const JsonEncoder.withIndent(' ').convert(json);
}
