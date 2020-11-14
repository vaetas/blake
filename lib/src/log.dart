import 'package:ansicolor/ansicolor.dart';
import 'package:meta/meta.dart';

class Logger {
  Logger({this.enableColors = true});

  final bool enableColors;

  void debug(dynamic message) => _log(LogLevel.debug, message: message);

  void info(dynamic message) => _log(LogLevel.info, message: message);

  void warning(dynamic message) => _log(LogLevel.warning, message: message);

  void severe(dynamic message, [Object error]) {
    _log(LogLevel.severe, message: message, error: error);
  }

  void _log(LogLevel level, {@required dynamic message, Object error}) {
    final pen = enableColors
        ? level.when(
            fine: (name) => _greyPen('[$name]'),
            info: (name) => _bluePen('[$name]'),
            warning: (name) => _yellowPen('[$name]'),
            severe: (name) => _redPen('[$name]'),
          )
        : '[${level.name}]';

    print('$pen $message');
  }

  final _greyPen = AnsiPen()..xterm(243, bg: false);
  final _bluePen = AnsiPen()..blue(bg: false, bold: true);
  final _redPen = AnsiPen()..red(bg: false, bold: true);
  final _yellowPen = AnsiPen()..yellow(bg: false, bold: true);
}

typedef _WhenCallback<T> = T Function(String name);

class LogLevel {
  const LogLevel._(this.name);

  final String name;

  static const debug = LogLevel._('DEBUG');

  static const info = LogLevel._('INFO');

  static const warning = LogLevel._('WARNING');

  static const severe = LogLevel._('SEVERE');

  T when<T>({
    _WhenCallback<T> fine,
    _WhenCallback<T> info,
    _WhenCallback<T> warning,
    _WhenCallback<T> severe,
  }) {
    switch (name) {
      case 'DEBUG':
        return fine?.call(name);
      case 'INFO':
        return info?.call(name);
      case 'WARNING':
        return warning?.call(name);
      case 'SEVERE':
        return severe?.call(name);
      default:
        throw ArgumentError('LogLevel $name is not valid.');
    }
  }
}

final log = Logger();
