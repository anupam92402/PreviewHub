import 'package:flutter/foundation.dart';

/// How far the lazy measurement of an asset has got.
enum MetricsStatus {
  /// The measurement is still running.
  loading,

  /// Whatever could be measured has been measured.
  ready,

  /// The asset could not be measured at all.
  failed,
}

/// Measurements taken of one asset.
@immutable
class AssetMetrics {
  /// Creates a set of measurements.
  ///
  /// Every field is optional because each is resolved from a different source
  /// and may land on its own.
  const AssetMetrics({this.sizeInBytes, this.width, this.height});

  /// Encoded size on disk or over the wire.
  final int? sizeInBytes;

  /// Decoded pixel width; null for vector and unmeasured assets.
  final int? width;

  /// Decoded pixel height; null for vector and unmeasured assets.
  final int? height;

  /// Copy carrying the pixel size the decoder reported.
  AssetMetrics withDimensions(int width, int height) =>
      AssetMetrics(sizeInBytes: sizeInBytes, width: width, height: height);

  /// Copy carrying a resolved byte count.
  AssetMetrics withSize(int? bytes) =>
      AssetMetrics(sizeInBytes: bytes, width: width, height: height);

  /// `1.4 MB` style rendering of [bytes], or `—` when it is unknown.
  static String formatBytes(int? bytes) {
    if (bytes == null) {
      return '—';
    }
    if (bytes < 1024) {
      return '$bytes B';
    }
    const List<String> units = <String>['KB', 'MB', 'GB'];
    double value = bytes / 1024;
    int unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(value >= 100 ? 0 : 1)} ${units[unit]}';
  }
}

/// Lazily resolved metrics for one asset, and why they failed if they did.
@immutable
class AssetMetricsState {
  /// Creates a state in [status].
  const AssetMetricsState({
    required this.status,
    this.metrics = const AssetMetrics(),
    this.error,
  });

  /// Nothing measured yet.
  static const AssetMetricsState loading = AssetMetricsState(
    status: MetricsStatus.loading,
  );

  /// Where the measurement has got to.
  final MetricsStatus status;

  /// What has been measured so far.
  final AssetMetrics metrics;

  /// Why measuring failed, when it did.
  final String? error;

  /// Copy in [MetricsStatus.ready] carrying [metrics].
  AssetMetricsState ready(AssetMetrics metrics) =>
      AssetMetricsState(status: MetricsStatus.ready, metrics: metrics);
}
