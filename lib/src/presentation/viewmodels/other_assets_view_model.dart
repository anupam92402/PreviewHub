import 'package:flutter/foundation.dart';

import '../../domain/models/other_asset.dart';
import '../../domain/services/other_asset_catalog_service.dart';

/// Drives the Other screen: reading the bundle once and grouping what it finds
/// by kind. Only kinds with at least one file become groups, so the screen
/// never shows an empty heading.
class OtherAssetsViewModel extends ChangeNotifier {
  /// Reads through [catalog].
  OtherAssetsViewModel({required this._catalog});

  final OtherAssetCatalogService _catalog;

  List<OtherAssetGroup> _groups = const <OtherAssetGroup>[];
  bool _isLoading = true;
  bool _failed = false;
  bool _disposed = false;

  /// Whether the bundle is still being read.
  bool get isLoading => _isLoading;

  /// Whether the asset manifest could not be read at all.
  bool get failed => _failed;

  /// Groups with at least one file, in [OtherAssetKind] order.
  List<OtherAssetGroup> get groups => _groups;

  /// How many files are listed across every group.
  int get fileCount => _groups.fold(
    0,
    (int total, OtherAssetGroup group) => total + group.assets.length,
  );

  /// Bytes of every listed file.
  int get totalBytes => _groups.fold(
    0,
    (int total, OtherAssetGroup group) => total + group.totalBytes,
  );

  /// Reads the bundle and groups what it finds.
  Future<void> load() async {
    try {
      final List<OtherAsset> assets = await _catalog.load();
      if (_disposed) {
        return;
      }
      _groups = group(assets);
    } on Object catch (_) {
      if (_disposed) {
        return;
      }
      _failed = true;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Splits [assets] into one group per kind present, heaviest file first.
  @visibleForTesting
  static List<OtherAssetGroup> group(
    List<OtherAsset> assets,
  ) => <OtherAssetGroup>[
    for (final OtherAssetKind kind in OtherAssetKind.values)
      if (assets.any((OtherAsset asset) => asset.kind == kind))
        OtherAssetGroup(
          kind: kind,
          assets:
              assets.where((OtherAsset asset) => asset.kind == kind).toList()
                ..sort(
                  (OtherAsset a, OtherAsset b) =>
                      b.sizeInBytes.compareTo(a.sizeInBytes),
                ),
        ),
  ];

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
