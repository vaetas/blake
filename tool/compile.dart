part of 'grind.dart';

const _kMac = 'mac';
const _kWindows = 'win';
const _kLinux = 'linux';

class Platform {
  const Platform._(this._value);

  factory Platform.fromIO() {
    if (io.Platform.isMacOS) {
      return const Platform._(_kMac);
    }
    if (io.Platform.isWindows) {
      return const Platform._(_kWindows);
    }
    if (io.Platform.isLinux) {
      return const Platform._(_kLinux);
    }

    throw ArgumentError('Unsupported platform');
  }

  final String _value;

  static const mac = Platform._(_kMac);
  static const windows = Platform._(_kWindows);
  static const linux = Platform._(_kLinux);

  T when<T>({
    required T Function() mac,
    required T Function() windows,
    required T Function() linux,
  }) {
    switch (_value) {
      case _kMac:
        return mac();
      case _kWindows:
        return windows();
      case _kLinux:
        return linux();
      default:
        throw ArgumentError('Unsupported platform');
    }
  }
}
