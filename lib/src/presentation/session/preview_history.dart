import 'package:flutter/foundation.dart';

/// Widget entries the developer starred or opened lately, by
/// `WidgetPreview.path`.
///
/// Held in memory for the life of the app process rather than written to disk,
/// so the gallery needs no storage dependency: closing and reopening the
/// gallery keeps both lists, a restart of the app clears them.
class PreviewHistory {
  PreviewHistory._();

  /// The one history the app shares.
  static final PreviewHistory instance = PreviewHistory._();

  /// Most entries the recent list keeps.
  static const int recentLimit = 5;

  final ValueNotifier<Set<String>> _favourites = ValueNotifier<Set<String>>(
    const <String>{},
  );
  final ValueNotifier<List<String>> _recents = ValueNotifier<List<String>>(
    const <String>[],
  );

  /// Starred entries, in the order they were starred.
  ValueListenable<Set<String>> get favourites => _favourites;

  /// Entries opened lately, newest first.
  ValueListenable<List<String>> get recents => _recents;

  /// Whether [path] is starred.
  bool isFavourite(String path) => _favourites.value.contains(path);

  /// Stars [path], or unstars it.
  void toggleFavourite(String path) {
    final Set<String> next = <String>{..._favourites.value};
    if (!next.remove(path)) {
      next.add(path);
    }
    _favourites.value = Set<String>.unmodifiable(next);
  }

  /// Moves [path] to the front of the recent list.
  void recordOpened(String path) {
    final List<String> next = <String>[
      path,
      ..._recents.value.where((String item) => item != path),
    ];
    _recents.value = List<String>.unmodifiable(next.take(recentLimit));
  }

  /// Empties both lists, so one test cannot see another's history.
  @visibleForTesting
  void reset() {
    _favourites.value = const <String>{};
    _recents.value = const <String>[];
  }
}
