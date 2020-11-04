extension IterableExtension<E> on Iterable<E> {
  /// Allows mapping list with async [mapper]. All mapped elements are run at the
  /// same time and returned `Future` ends when last element is finished.
  Future<List<T>> asyncMap<T>(Future<T> Function(E e) mapper) async {
    return Future.wait<T>(map((i) async => mapper(i)));
  }
}
