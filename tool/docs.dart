// ignore_for_file: avoid_print

part of 'grind.dart';

class ProcessEvent {
  ProcessEvent({
    required this.stdout,
    required this.stderr,
  });

  final List<int> stdout;
  final List<int> stderr;
}

/// Start docs website.
///
/// `grind docs` defaults to `grind docs --serve`
///
/// grind docs --serve
/// grind docs --deploy
/// grind docs --build
@Task()
Future<void> docs() async {
  final args = context.invocation.arguments;
  final buildFlag = args.getFlag('build');
  final serveFlag = args.getFlag('serve');
  final deployFlag = args.getFlag('deploy');

  const workingDirectory = 'docs';

  void printEvent(List<int> event) {
    print(utf8.decode(event).trim());
  }

  Future<void> runBlake(String mode) async {
    final process = await io.Process.start(
      'blake',
      [mode],
      workingDirectory: workingDirectory,
    );
    await for (final event in process.stdout) {
      printEvent(event);
    }
    await for (final event in process.stderr) {
      printEvent(event);
      io.exit(1);
    }
  }

  Future<void> runPostCSS(String mode) async {
    final process = await io.Process.start(
      'npm',
      ['run', mode],
      workingDirectory: workingDirectory,
    );
    await for (final event in process.stdout) {
      printEvent(event);
    }
    await for (final event in process.stderr) {
      printEvent(event);
      io.exit(1);
    }
  }

  Future<void> build() async {
    print('Building...');
    await runPostCSS('build');
    await runBlake('build');
  }

  Future<void> serve() async {
    print('Serving...');
    // ignore: unawaited_futures
    runPostCSS('postcss:watch');
    await runBlake('serve');
  }

  if (buildFlag) {
    return build();
  }

  if (serveFlag) {
    return serve();
  }

  if (deployFlag) {
    print('Deploying...');
    await build();
    final process = await io.Process.start('gh_pages', ['docs/public']);
    await for (final event in process.stdout) {
      printEvent(event);
    }
    await for (final event in process.stderr) {
      printEvent(event);
      io.exit(1);
    }
    return;
  }

  await serve();
}
