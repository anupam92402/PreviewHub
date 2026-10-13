import 'package:rive/rive.dart' as rive;

/// Starts the Rive runtime once, on first use. Kept inside the package so a
/// tile renders without a bootstrap call in the host app's `main`.
class RiveRuntime {
  const RiveRuntime._();

  static Future<bool>? _initialisation;

  /// Completes with whether the native runtime came up. Reports failure rather
  /// than throwing, so a tile shows an error instead of waiting on a future
  /// that never completes.
  static Future<bool> ensureInitialised() => _initialisation ??= _start();

  static Future<bool> _start() async {
    try {
      return await rive.RiveNative.init();
    } on Object {
      return false;
    }
  }
}
