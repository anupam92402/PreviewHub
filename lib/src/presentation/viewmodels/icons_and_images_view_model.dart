import 'package:flutter/foundation.dart';

import '../../domain/models/asset_sort_order.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/models/validation_issue.dart';
import '../../domain/services/asset_catalog_service.dart';
import '../../domain/services/asset_metrics_service.dart';

/// Drives the icons and images screen: loading, searching and filtering.
///
/// The screen renders [visibleAssets] and nothing else decides what is shown.
class IconsAndImagesViewModel extends ChangeNotifier {
  /// Loads through [catalog], listing [networkImages] after the bundled ones.
  IconsAndImagesViewModel({
    required this._catalog,
    required this._metrics,
    required this._networkImages,
  }) {
    _metrics.issues.addListener(notifyListeners);
  }

  final AssetCatalogService _catalog;
  final AssetMetricsService _metrics;
  final List<String> _networkImages;

  List<PreviewAsset> _assets = <PreviewAsset>[];
  List<ValidationIssue> _catalogIssues = const <ValidationIssue>[];
  final Set<AssetType> _types = <AssetType>{};
  AssetSource? _source;
  String _query = '';
  AssetSortOrder _sortOrder = AssetSortOrder.none;
  int _columns = 2;
  bool _isSorting = false;
  bool _isLoading = true;
  bool _isReportReady = false;
  bool _disposed = false;

  /// Whether the first load is still running.
  bool get isLoading => _isLoading;

  /// Whether every remote entry has been checked and [issues] is complete.
  ///
  /// The report stays hidden until this is true, because a report that has not
  /// finished checking would claim everything is fine when it does not yet
  /// know. Bundled assets are excluded: one listed in the manifest exists by
  /// definition, so there is nothing to validate.
  bool get isReportReady => _isReportReady;

  /// How many remote entries the report covers.
  int get checkedCount =>
      _assets.where((PreviewAsset a) => a.source == AssetSource.network).length;

  /// The one source being shown, or null while every source is shown.
  ///
  /// Sources are mutually exclusive: an asset is either bundled or remote, so
  /// picking both would mean the same thing as picking neither.
  AssetSource? get selectedSource => _source;

  /// Whether no source is being filtered out.
  bool get isAllSources => _source == null;

  /// How the grid is currently ordered.
  AssetSortOrder get sortOrder => _sortOrder;

  /// How many tiles the grid puts in one row.
  int get columns => _columns;

  /// Column counts the view menu offers.
  static const List<int> columnChoices = <int>[2, 3, 4];

  /// Whether sizes are still being gathered for a newly chosen order.
  bool get isSorting => _isSorting;

  /// Formats being shown; empty means every format.
  Set<AssetType> get selectedTypes => Set<AssetType>.unmodifiable(_types);

  /// Whether no format is being filtered out.
  bool get isAllTypes => _types.isEmpty;

  /// Everything rejected up front, plus anything that has failed since.
  ///
  /// Entries rejected for their shape are known immediately; content-type and
  /// reachability problems surface as each asset is measured.
  List<ValidationIssue> get issues => <ValidationIssue>[
    ..._catalogIssues,
    ..._metrics.issues.value,
  ];

  /// Formats present in the catalogue, so no chip can match nothing.
  List<AssetType> get availableTypes {
    final Set<AssetType> present = _assets
        .map((PreviewAsset asset) => asset.type)
        .toSet();
    return AssetType.values.where(present.contains).toList(growable: false);
  }

  /// Assets passing the current search and filters, in the current order.
  List<PreviewAsset> get visibleAssets {
    final String needle = _query.trim().toLowerCase();
    final List<PreviewAsset> matching = _assets.where((PreviewAsset asset) {
      if (_source != null && asset.source != _source) {
        return false;
      }
      if (_types.isNotEmpty && !_types.contains(asset.type)) {
        return false;
      }
      if (needle.isEmpty) {
        return true;
      }
      return asset.name.toLowerCase().contains(needle) ||
          asset.locator.toLowerCase().contains(needle);
    }).toList();

    if (_sortOrder.needsSizes) {
      matching.sort(_bySize);
    }
    return List<PreviewAsset>.unmodifiable(matching);
  }

  /// Orders by measured size, keeping anything unmeasured at the end.
  ///
  /// Ties break on the locator so the order stays put between rebuilds;
  /// [List.sort] gives no stability guarantee of its own.
  int _bySize(PreviewAsset a, PreviewAsset b) {
    final int? sizeA = _metrics.sizeOf(a);
    final int? sizeB = _metrics.sizeOf(b);
    if (sizeA == null || sizeB == null) {
      if (sizeA == sizeB) {
        return a.locator.compareTo(b.locator);
      }
      return sizeA == null ? 1 : -1;
    }
    final int bySize = _sortOrder == AssetSortOrder.sizeAsc
        ? sizeA.compareTo(sizeB)
        : sizeB.compareTo(sizeA);
    return bySize != 0 ? bySize : a.locator.compareTo(b.locator);
  }

  /// Discovers bundled assets and appends the supplied remote ones.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final AssetCatalog catalog = await _catalog.load(
      networkImages: _networkImages,
    );
    _assets = catalog.assets;
    _catalogIssues = catalog.issues;
    _isLoading = false;
    notifyListeners();

    await _checkNetworkEntries();
  }

  /// Contacts every remote entry so the report can be trusted.
  ///
  /// These measurements are cached, so a tile scrolled into view later reuses
  /// this result rather than asking again.
  Future<void> _checkNetworkEntries() async {
    await Future.wait(
      _assets
          .where((PreviewAsset a) => a.source == AssetSource.network)
          .map(_metrics.ensureMeasured),
    );
    if (_disposed) {
      return;
    }
    _isReportReady = true;
    notifyListeners();
  }

  /// Applies [value] as the search text.
  void search(String value) {
    if (value == _query) {
      return;
    }
    _query = value;
    notifyListeners();
  }

  /// Applies [order], measuring anything still unmeasured first.
  ///
  /// Sizes are resolved for the whole catalogue before the order changes, so
  /// the grid reorders once rather than shuffling as each measurement lands.
  /// The measurements are cached, so choosing a sort a second time is instant.
  Future<void> setSortOrder(AssetSortOrder order) async {
    if (_sortOrder == order) {
      return;
    }
    _sortOrder = order;
    if (!order.needsSizes) {
      notifyListeners();
      return;
    }

    _isSorting = true;
    notifyListeners();

    await Future.wait(_assets.map(_metrics.ensureMeasured));
    if (_disposed) {
      return;
    }
    _isSorting = false;
    notifyListeners();
  }

  /// Puts [value] tiles in each row.
  void setColumns(int value) {
    if (_columns == value) {
      return;
    }
    _columns = value;
    notifyListeners();
  }

  /// Shows only [source], or every source when it is null.
  void selectSource(AssetSource? source) {
    if (_source == source) {
      return;
    }
    _source = source;
    notifyListeners();
  }

  /// Adds or removes [type] from the format filter.
  ///
  /// Removing the last one falls back to showing every format, so the filter
  /// never lands in a state where nothing can match.
  void toggleType(AssetType type) {
    _types.contains(type) ? _types.remove(type) : _types.add(type);
    notifyListeners();
  }

  /// Shows every format again.
  void selectAllTypes() {
    if (_types.isEmpty) {
      return;
    }
    _types.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _metrics.issues.removeListener(notifyListeners);
    super.dispose();
  }
}
