import 'dart:io';

import 'package:blake/src/config.dart';
import 'package:yaml/yaml.dart';

/// List all files and directories inside folder with given [path].
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
  /// Handle every possible FS entity.
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

/// Public directory contains generated static files suitable for publishing.
///
/// Config: `build.public_folder`
Future<Directory> getPublicDirectory(Config config) async {
  return Directory(config.build.publicFolder).create();
}

/// Content directory contains Markdown files.
///
/// Config: `build.content_folder`
Future<Directory> getContentDirectory(Config config) async {
  return Directory(config.build.contentFolder).create();
}

/// Templates folder contains Mustache templates for rendering Markdown files
/// inside content folder.
///
/// Config: `build.templates_folder`
Future<Directory> getTemplatesDirectory(Config config) async {
  return Directory(config.build.templatesFolder).create();
}

/// Static folder contains files to be copied into public folder, like CSS or JS.
///
/// Config: `build.static_folder`
Future<Directory> getStaticDirectory(Config config) async {
  return Directory(config.build.staticFolder).create();
}

/// Returns content of `config.yaml` file or throws when the file does not exists.
Future<Config> getConfig() async {
  if (await File('config.yaml').exists()) {
    final file = await _getConfigFile();
    final config = await file.readAsString();
    final yaml = loadYaml(config) as YamlMap;
    return Config.fromYaml(yaml);
  }

  throw 'Config file does not exists in current location\n';
}

Future<File> _getConfigFile() async {
  return File('config.yaml').create();
}
