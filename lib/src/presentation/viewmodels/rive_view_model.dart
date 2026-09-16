import 'package:flutter/foundation.dart';

import '../../domain/models/asset_sort_order.dart';
import '../../domain/models/rive_asset.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/models/validation_issue.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../domain/services/rive_catalog_service.dart';

/// Drives the Rive screen: loading, searching and filtering by source.
class RiveViewModel extends ChangeNotifier {
  /// Loads through [catalog], listing [networkRives] after the bundled ones.
  RiveViewModel({
    required this._catalog,
    required this._metrics,
    required this._networkRives,
  }) {
    _metrics.issues.addListener(notifyListeners);
  }

  /// Column counts the view menu offers.
  static const List<int> columnChoices = <int>[2, 3, 4];

  final RiveCatalogService _catalog;
  final AssetMetricsService _metrics;
  final List<String> _networkRives;

  List<RiveAsset> _assets = <RiveAsset>[];
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
      _assets.where((RiveAsset a) => a.source == AssetSource.network).length;

  /// Anything that failed while fetching, once checked.
  List<ValidationIssue> get issues => _metrics.issues.value;

  /// Animations passing the current search and filter.
  List<RiveAsset> get visibleAssets {
    final String needle = _query.trim().toLowerCase();
    return List<RiveAsset>.unmodifiable(
      _assets.where((RiveAsset asset) {
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
  int _order(RiveAsset a, RiveAsset b) {
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

    _assets = await _catalog.load(networkRives: _networkRives);
    _isLoading = false;
    notifyListeners();

    await _checkNetworkEntries();
  }

  /// Contacts every remote entry so the report can be trusted.
  Future<void> _checkNetworkEntries() async {
    await Future.wait(
      _assets
          .where((RiveAsset a) => a.source == AssetSource.network)
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
