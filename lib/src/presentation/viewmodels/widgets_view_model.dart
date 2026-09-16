import 'package:flutter/foundation.dart';

import '../../domain/models/widget_preview.dart';
import '../../domain/services/widget_catalog_service.dart';

/// Drives the widget index: the search, the section chips and which groups are
/// folded away. Groups start folded, so the index opens as a short list of
/// headings rather than a wall of entries. Expanded groups live here rather
/// than in a store, so reopening the gallery folds everything again.
class WidgetsViewModel extends ChangeNotifier {
  /// Creates a view model over [previews], dropping any that cannot be shown.
  WidgetsViewModel({
    required WidgetCatalogService catalog,
    required List<WidgetPreview> previews,
  }) : _catalog = catalog,
       _all = catalog.sanitize(previews) {
    _applyFilters();
  }

  final WidgetCatalogService _catalog;
  final List<WidgetPreview> _all;
  final Set<String> _expanded = <String>{};

  String _query = '';
  WidgetSection? _section;

  List<WidgetPreview> _matches = const <WidgetPreview>[];
  List<WidgetPreviewGroup> _groups = const <WidgetPreviewGroup>[];

  /// Groups to draw, already filtered by the search and the chips.
  List<WidgetPreviewGroup> get groups => _groups;

  /// How many entries survive the current search and chips.
  int get resultCount => _matches.length;

  /// Whether the index has nothing to show.
  bool get isEmpty => _matches.isEmpty;

  /// Section the chips have narrowed to, or null while showing everything.
  WidgetSection? get selectedSection => _section;

  /// Whether the All chip is the selected one.
  bool get isAllSections => _section == null;

  /// Whether [group] is currently folded away. A search opens every matching
  /// group: entries hidden behind a fold would make the search look as though
  /// it had found nothing.
  bool isCollapsed(String group) =>
      _query.isEmpty && !_expanded.contains(group);

  /// Narrows the index to entries matching [query].
  void search(String query) {
    final String next = query.trim().toLowerCase();
    if (next == _query) {
      return;
    }
    _query = next;
    _applyFilters();
    notifyListeners();
  }

  /// Narrows the index to [section], or clears the filter when null.
  void selectSection(WidgetSection? section) {
    if (section == _section) {
      return;
    }
    _section = section;
    _applyFilters();
    notifyListeners();
  }

  /// Opens [group], or folds it away again.
  void toggleGroup(String group) {
    if (!_expanded.remove(group)) {
      _expanded.add(group);
    }
    notifyListeners();
  }

  void _applyFilters() {
    _matches = _all
        .where(
          (WidgetPreview preview) =>
              (_section == null || preview.section == _section) &&
              (_query.isEmpty || preview.searchText.contains(_query)),
        )
        .toList(growable: false);
    _groups = _catalog.group(_matches);
  }
}
