import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/font_family_info.dart';
import '../../domain/services/font_catalog_service.dart';
import '../../domain/services/font_metrics_service.dart';

/// Drives the fonts screen: discovery, search, and which family is showing.
class FontsViewModel extends ChangeNotifier {
  /// Discovers through [catalog] and measures through [metrics].
  FontsViewModel({required this._catalog, required this._metrics});

  final FontCatalogService _catalog;
  final FontMetricsService _metrics;

  List<FontFamilyInfo> _families = <FontFamilyInfo>[];
  FontFamilyInfo? _selected;
  String _query = '';
  bool _isLoading = true;
  bool _disposed = false;

  /// Whether the first load is still running.
  bool get isLoading => _isLoading;

  /// The family currently on show, or null while none has been chosen.
  FontFamilyInfo? get selected => _selected;

  /// Families passing the current search, app fonts first.
  List<FontFamilyInfo> get visibleFamilies {
    final String needle = _query.trim().toLowerCase();
    if (needle.isEmpty) {
      return List<FontFamilyInfo>.unmodifiable(_families);
    }
    return List<FontFamilyInfo>.unmodifiable(
      _families.where(
        (FontFamilyInfo family) =>
            family.name.toLowerCase().contains(needle) ||
            family.manifestKey.toLowerCase().contains(needle),
      ),
    );
  }

  /// Measured size of the file behind [face], or null while unknown.
  int? sizeOf(FontFace face) => _metrics.sizeOf(face);

  /// Measured size of every face in [family], or null while unknown.
  int? totalSizeOf(FontFamilyInfo family) => _metrics.totalOf(family);

  /// Reads the font manifest and opens the first family.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _families = await _catalog.load();
    _isLoading = false;
    notifyListeners();

    final FontFamilyInfo? first = _families.firstOrNull;
    if (first != null) {
      await select(first);
    }
  }

  /// Shows [family], measuring its faces the first time it is opened.
  Future<void> select(FontFamilyInfo family) async {
    if (_selected == family && _metrics.totalOf(family) != null) {
      return;
    }
    _selected = family;
    notifyListeners();

    await _metrics.measure(family);
    if (_disposed) {
      return;
    }
    notifyListeners();
  }

  /// Applies [value] as the search text.
  ///
  /// A search that hides the open family moves to the first one still
  /// showing, so the sheet below the chips never belongs to a hidden chip.
  void search(String value) {
    if (value == _query) {
      return;
    }
    _query = value;
    final List<FontFamilyInfo> visible = visibleFamilies;
    if (visible.isNotEmpty && !visible.contains(_selected)) {
      unawaited(select(visible.first));
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
