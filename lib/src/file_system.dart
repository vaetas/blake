import 'dart:io';

import 'package:blake/src/build/build_config.dart';
import 'package:blake/src/config.dart';
import 'package:yaml/yaml.dart';

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

Future<Directory> getBuildDirectory(Config config) async {
  return Directory(config.build.buildFolder).create();
}

Future<Directory> getContentDirectory(Config config) async {
  return Directory(config.build.contentFolder).create();
}

Future<Directory> getTemplatesDirectory(Config config) async {
  return Directory(config.build.templatesFolder).create();
}

Future<Directory> getStaticDirectory(Config config) async {
  return Directory(config.build.staticFolder).create();
}

Future<File> getConfigFile() async {
  return File('config.yaml').create();
}

Future<Config> getConfig() async {
  final file = await getConfigFile();
  final config = await file.readAsString();
  final yaml = loadYaml(config) as YamlMap;
  return Config.fromYaml(yaml);
}
