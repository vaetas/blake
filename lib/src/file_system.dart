import 'dart:io';

Future<List<FileSystemEntity>> listDirectory(String path) {
  return Directory(path).list().toList();
}

extension DirectoryExtension on Directory {
  /// If [Directory] already exists delete all its contents and create it again.
  Future<Directory> reset({bool recursive = true}) async {
    if (await exists()) {
      await delete(recursive: recursive);
    }
    return create(recursive: recursive);
  }
}
