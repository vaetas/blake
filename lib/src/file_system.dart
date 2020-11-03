import 'dart:io';

Future<List<FileSystemEntity>> listDirectory(String path) {
  return Directory(path).list().toList();
}
