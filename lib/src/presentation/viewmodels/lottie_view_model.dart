import 'package:flutter/foundation.dart';

import '../../domain/models/asset_sort_order.dart';
import '../../domain/models/lottie_asset.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/models/validation_issue.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../domain/services/lottie_catalog_service.dart';

/// Drives the Lottie screen: loading, searching and filtering by source.
class LottieViewModel extends ChangeNotifier {
  /// Loads through [catalog], listing [networkLotties] after the bundled ones.
  LottieViewModel({
    required this._catalog,
    required this._metrics,
    required this._networkLotties,
  }) {
    _metrics.issues.addListener(notifyListeners);
  }

  /// Column counts the view menu offers.
  static const List<int> columnChoices = <int>[2, 3, 4];

  final LottieCatalogService _catalog;
  final AssetMetricsService _metrics;
  final List<String> _networkLotties;

  List<LottieAsset> _assets = <LottieAsset>[];
  AssetSource? _source;
  AssetSortOrder _sortOrder = AssetSortOrder.none;
  int _columns = 2;
  String _query = '';
  bool _isLoading = true;
  bool _isSorting = false;
  bool _isReportReady = false;
  bool _disposed = false;

  /// Whether the first load is still running.
  bool get isLoading => _isLoading;

  /// The one source being shown, or null while every source is shown.
  AssetSource? get selectedSource => _source;

  /// Whether no source is being filtered out.
  bool get isAllSources => _source == null;

  /// How the grid is currently ordered.
  AssetSortOrder get sortOrder => _sortOrder;

  /// Whether sizes are still being gathered for a newly chosen order.
  bool get isSorting => _isSorting;

  /// How many tiles the grid puts in one row.
  int get columns => _columns;

  /// Whether every remote entry has been checked and [issues] is complete.
  bool get isReportReady => _isReportReady;

  /// How many remote entries the report covers.
  int get checkedCount =>
      _assets.where((LottieAsset a) => a.source == AssetSource.network).length;

  /// Anything that failed while fetching, once checked.
  List<ValidationIssue> get issues => _metrics.issues.value;

  /// Animations passing the current search and filter.
  List<LottieAsset> get visibleAssets {
    final String needle = _query.trim().toLowerCase();
    return List<LottieAsset>.unmodifiable(
      _assets.where((LottieAsset asset) {
        if (_source != null && asset.source != _source) {
          return false;
        }
        if (needle.isEmpty) {
          return true;
        }
        return asset.name.toLowerCase().contains(needle) ||
            asset.locator.toLowerCase().contains(needle);
      }).toList()..sort(_order),
    );
  }

  /// Keeps discovery order unless a size sort is on. Ties break on the locator
  /// so the order stays put between rebuilds; [List.sort] gives no stability
  /// guarantee of its own.
  int _order(LottieAsset a, LottieAsset b) {
    if (!_sortOrder.needsSizes) {
      return 0;
    }
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

  /// Discovers bundled animations and appends the supplied remote ones.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _assets = await _catalog.load(networkLotties: _networkLotties);
    _isLoading = false;
    notifyListeners();

    await _checkNetworkEntries();
  }

  /// Contacts every remote entry so the report can be trusted.
  Future<void> _checkNetworkEntries() async {
    await Future.wait(
      _assets
          .where((LottieAsset a) => a.source == AssetSource.network)
          .map(_metrics.ensureMeasured),
    );
    if (_disposed) {
      return;
    }
    _isReportReady = true;
    notifyListeners();
  }

  /// Applies [order], measuring anything still unmeasured first.
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

  /// Applies [value] as the search text.
  void search(String value) {
    if (value == _query) {
      return;
    }
    _query = value;
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

  @override
  void dispose() {
    _disposed = true;
    _metrics.issues.removeListener(notifyListeners);
    super.dispose();
  }
}
