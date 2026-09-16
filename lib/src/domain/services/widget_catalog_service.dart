import '../models/widget_preview.dart';

/// A run of entries sharing one heading in the index.
class WidgetPreviewGroup {
  /// Creates a group named [name] holding [previews].
  const WidgetPreviewGroup({
    required this.name,
    required this.section,
    required this.previews,
  });

  /// Heading shown above the entries.
  final String name;

  /// Which half of the gallery these entries belong to.
  final WidgetSection section;

  /// Entries under this heading, in declaration order.
  final List<WidgetPreview> previews;

  /// How many entries the heading covers.
  int get count => previews.length;

  /// Identity used to remember whether this group is folded. The name alone is
  /// not enough: a host may well file both a component and a screen under
  /// `Money`, and folding one must not fold the other.
  String get key => '${section.name}/$name';
}

/// Turns the host's flat list of previews into what the index screen draws.
/// There is nothing to read from disk or the network here, so unlike the asset
/// catalogs this is synchronous and holds no state.
class WidgetCatalogService {
  /// Creates the service.
  const WidgetCatalogService();

  /// Drops entries that could not be shown, keeping declaration order.
  List<WidgetPreview> sanitize(List<WidgetPreview> previews) => previews
      .where((WidgetPreview preview) => preview.isUsable)
      .toList(growable: false);

  /// Splits [previews] into groups, first seen first. Grouping is by section
  /// and name together, so one heading used for both a component and a screen
  /// stays two groups. Order follows the host's list rather than the alphabet.
  List<WidgetPreviewGroup> group(List<WidgetPreview> previews) {
    final Map<String, List<WidgetPreview>> byKey =
        <String, List<WidgetPreview>>{};

    for (final WidgetPreview preview in previews) {
      byKey
          .putIfAbsent(
            '${preview.section.name}/${preview.group}',
            () => <WidgetPreview>[],
          )
          .add(preview);
    }

    return byKey.values
        .map(
          (List<WidgetPreview> members) => WidgetPreviewGroup(
            name: members.first.group,
            section: members.first.section,
            previews: members,
          ),
        )
        .toList(growable: false);
  }
}
