import 'package:blake/src/errors.dart';
import 'package:file/file.dart';
import 'package:process_run/shell.dart';

class GitUtil {
  GitUtil._();

  static final _shell = Shell(verbose: false);

  static bool _isGitAvailable;

  static Future<DateTime> getModified(File file) async {
    await _ensureGitAvailable();

    // For already tracked files git returns date.
    // When file does not exists or is not yet tracked this returns empty string
    final result = await _shell.run(
      'git log --follow --format=%aI -1 -- ${file.path}',
    );

    return _parseOutput(result.outText);
  }

  /// Get date when [file] was first tracked in git history.
  static Future<DateTime> getCreated(File file) async {
    await _ensureGitAvailable();

    final result = await _shell.run(
      'git log --diff-filter=A --follow --format=%aI -1 -- file.txt',
    );

    return _parseOutput(result.outText);
  }

  static DateTime _parseOutput(String output) {
    if (output.trim().isEmpty) {
      return null;
    } else {
      return DateTime.parse(output);
    }
  }

  static Future<bool> isGitInstalled() async {
    try {
      await _ensureGitAvailable();
      return _isGitAvailable;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _ensureGitAvailable() async {
    if (_isGitAvailable == true) return;

    final result = await which('git');

    if (result == null) {
      _isGitAvailable = false;
      throw const BuildError('Git must be available to use git methods');
    } else {
      _isGitAvailable = true;
    }
  }

  static Future<bool> isGitDir() async {
    try {
      final result = await _shell.run('git status');
      return result.errText != null;
    } catch (e) {
      return false;
    }
  }
}
