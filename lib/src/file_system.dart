import 'dart:io';

import 'package:blake/src/build/build_config.dart';

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

extension FileSystemEntityExtension on FileSystemEntity {
  R when<R>({
    R Function(File file) file,
    R Function(Directory directory) directory,
    R Function(Link link) link,
  }) {
    if (FileSystemEntity.isFileSync(path)) {
      return file?.call(this as File);
    } else if (FileSystemEntity.isDirectorySync(path)) {
      return directory?.call(this as Directory);
    } else {
      return link?.call(this as Link);
    }
  }
}

Future<Directory> getBuildDirectory(BuildConfig config) async {
  return Directory(config.buildFolder).create();
}

Future<Directory> getContentDirectory(BuildConfig config) async {
  return Directory(config.contentFolder).create();
}

Future<Directory> getTemplatesDirectory(BuildConfig config) async {
  return Directory(config.templatesFolder).create();
}

Future<Directory> getStaticDirectory(BuildConfig config) async {
  return Directory(config.staticFolder).create();
}

Future<File> getConfigFile() async {
  return File('config.yaml').create();
}
