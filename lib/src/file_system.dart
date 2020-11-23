import 'dart:io';

import 'package:blake/src/config.dart';
import 'package:blake/src/errors.dart';
import 'package:blake/src/util/either.dart';
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

Future<Directory> _getOrThrow(Directory directory) async {
  if (await directory.exists()) {
    return directory;
  }

  throw BuildError('Directory ${directory.path} does not exists');
}

/// Public directory contains generated static files suitable for publishing.
///
/// Config: `build.public_dir`
Future<Directory> getPublicDirectory(Config config) async {
  return _getOrThrow(
    Directory(config.build.publicDir),
  );
}

/// Content directory contains Markdown files.
///
/// Config: `build.content_dir`
Future<Directory> getContentDirectory(Config config) async {
  return _getOrThrow(
    Directory(config.build.contentDir),
  );
}

/// Templates folder contains Mustache templates for rendering Markdown files
/// inside content folder.
///
/// Config: `build.templates_dir`
Future<Directory> getTemplatesDirectory(Config config) async {
  return _getOrThrow(
    Directory(config.build.templatesDir),
  );
}

/// Static folder contains files to be copied into public folder like CSS or JS.
///
/// Config: `build.static_dir`
Future<Directory> getStaticDirectory(Config config) async {
  return _getOrThrow(
    Directory(config.build.staticDir),
  );
}

Future<Directory> getDataDirectory(Config config) async {
  return _getOrThrow(
    Directory(config.build.dataDir),
  );
}

/// Returns content of `config.yaml` file or throws when the file does
/// not exists.
Future<Either<ConfigError, Config>> getConfig() async {
  if (await isProjectDirectory()) {
    final file = await _getConfigFile();
    final config = await file.readAsString();
    final yaml = loadYaml(config) as YamlMap;
    return Right(Config.fromYaml(yaml));
  }

  return const Left(
    ConfigError('Config file does not exists in current location'),
  );
}

Future<bool> isProjectDirectory() {
  return File(_kConfigFile).exists();
}

Future<File> _getConfigFile() async {
  return File(_kConfigFile).create();
}

const _kConfigFile = 'config.yaml';
