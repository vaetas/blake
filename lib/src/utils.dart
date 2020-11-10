import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

extension IterableExtension<E> on Iterable<E> {
  /// Allows mapping list with async [mapper]. All mapped elements are run at the
  /// same time and returned `Future` ends when last element is finished.
  Future<List<T>> asyncMap<T>(Future<T> Function(E e) mapper) async {
    return Future.wait<T>(map((i) async => mapper(i)));
  }
}

extension ArgResultsExtension on ArgResults {
  T get<T>(String name) {
    return this[name] as T;
  }
}

extension YamlMapExtension on YamlMap {
  T get<T>(String key) {
    return this[key] as T;
  }
}

extension MapExtension on Map<String, dynamic> {
  T get<T>(String key) {
    return this[key] as T;
  }
}
