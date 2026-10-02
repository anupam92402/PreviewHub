import 'package:flutter/foundation.dart';

import '../../domain/models/asset_size_report.dart';
import '../../domain/services/asset_size_service.dart';

/// Drives the size breakdown: measuring the bundle once, and which category is
/// picked out on the chart.
class AssetSizeViewModel extends ChangeNotifier {
  /// Measures through [service].
  AssetSizeViewModel({required this._service});

  final AssetSizeService _service;

  AssetSizeReport? _report;
  AssetSizeCategory? _selected;
  bool _failed = false;
  bool _disposed = false;

  /// The breakdown, or null while it is being measured.
  AssetSizeReport? get report => _report;

  /// Whether measuring failed outright, as with an app that has no asset
  /// manifest at all.
  bool get failed => _failed;

  /// Category picked out on the chart and opened in the list, or null.
  AssetSizeCategory? get selected => _selected;

  /// Measures every bundled asset.
  Future<void> load() async {
    try {
      final AssetSizeReport report = await _service.measure();
      if (_disposed) {
        return;
      }
      _report = report;
    } on Object catch (_) {
      if (_disposed) {
        return;
      }
      _failed = true;
    }
    notifyListeners();
  }

  /// Picks out [category], or lets it go when it is already picked.
  void select(AssetSizeCategory category) {
    _selected = _selected == category ? null : category;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
