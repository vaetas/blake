import 'package:file/file.dart';
import 'package:process_run/shell.dart';

class GitUtil {
  GitUtil._();

  static final _shell = Shell(verbose: false);

  static bool _isGitDirectory = false;
  static bool _isGitInstalled = false;

  static Future<DateTime?> getModified(File file) async {
    if (!await isGitInstalled()) {
      return null;
    }
    if (!await isGitDir()) {
      return null;
    }

    // For already tracked files git returns date.
    // When file does not exists or is not yet tracked this returns empty string
    final result = await _shell.run(
      'git log --follow --format=%aI -1 -- ${file.path}',
    );

    return _parseOutput(result.outText);
  }

  /// Get date when [file] was first tracked in git history.
  static Future<DateTime?> getCreated(File file) async {
    if (!await isGitInstalled()) {
      return null;
    }
    if (!await isGitDir()) {
      return null;
    }

    final result = await _shell.run(
      'git log --diff-filter=A --follow --format=%aI -1 -- ${file.path}',
    );

    return _parseOutput(result.outText);
  }

  static DateTime? _parseOutput(String output) {
    if (output.trim().isEmpty) {
      return null;
    } else {
      return DateTime.parse(output);
    }
  }

  /// Checks if GIT is installed on current system and the command is available.
  static Future<bool> isGitInstalled() async {
    try {
      final result = await which('git');
      if (result == null) {
        _isGitInstalled = false;
      } else {
        _isGitInstalled = true;
      }
    } catch (e) {
      _isGitInstalled = false;
    }

    return _isGitInstalled;
  }

  /// Checks if current dir is git repository.
  ///
  /// The result value is cached after first invocation. However, when the users
  /// starts local server and then runs `git init` this will not update its
  /// result. We might change this in the future.
  static Future<bool> isGitDir() async {
    try {
      final result = await _shell.run('git status');
      _isGitDirectory = result.errText.isEmpty;
    } catch (e) {
      _isGitDirectory = false;
    }
    return _isGitDirectory;
  }
}
