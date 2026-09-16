import 'package:flutter/widgets.dart';

/// Which half of the widget gallery an entry belongs to.
///
/// The two values drive the chip row at the top of the index, and decide how
/// an entry opens: a component lists its cases inline, a screen takes over the
/// display.
enum WidgetSection {
  /// Pieces of a design system: buttons, fields, toasts.
  components('Components'),

  /// Whole screens, which need the full display to be judged.
  screens('Screens');

  const WidgetSection(this.label);

  /// Text on the chip.
  final String label;
}

/// One labelled rendering of a widget.
///
/// The [label] is the specification, such as `filled · large (52)`, and sits
/// directly above what it describes. The [builder] runs only once the case is
/// on screen, so an index of a hundred entries costs nothing to scroll, and a
/// stateful sample starts fresh every time it is opened.
@immutable
class WidgetPreviewCase {
  /// Creates a case labelled [label], built by [builder].
  const WidgetPreviewCase({required this.label, required this.builder});

  /// What makes this rendering different from the others.
  final String label;

  /// Builds the widget being shown.
  final WidgetBuilder builder;

  /// Whether the case carries enough to be shown.
  bool get isUsable => label.trim().isNotEmpty;
}

/// One entry in the widget gallery.
///
/// Supplied by the host app through [PreviewHubConfig.widgets], since a widget
/// is code and cannot be discovered from an asset manifest. Build one with
/// [WidgetPreview.component] or [WidgetPreview.screen]; the section follows
/// from which you pick, so it can never disagree with the shape.
///
/// ```dart
/// WidgetPreview.component(
///   group: 'Buttons',
///   title: 'AppButton · primary',
///   cases: <WidgetPreviewCase>[
///     WidgetPreviewCase(
///       label: 'filled · large (52)',
///       builder: (BuildContext context) => AppButton(label: 'Continue'),
///     ),
///   ],
/// )
///
/// WidgetPreview.screen(
///   group: 'Auth',
///   title: 'SignInScreen',
///   builder: (BuildContext context) => const SignInScreen(),
/// )
/// ```
@immutable
class WidgetPreview {
  /// Creates a component entry, showing each of [cases] down one page.
  const WidgetPreview.component({
    required this.group,
    required this.title,
    required List<WidgetPreviewCase> cases,
  }) : section = WidgetSection.components,
       _componentCases = cases,
       _screenBuilder = null;

  /// Creates a screen entry, shown at full size.
  ///
  /// A screen has no second axis to label: its states, such as empty against
  /// loaded, read better as separate entries under the same [group], where the
  /// index can count and search them.
  const WidgetPreview.screen({
    required this.group,
    required this.title,
    required WidgetBuilder builder,
  }) : section = WidgetSection.screens,
       _componentCases = null,
       _screenBuilder = builder;

  /// Heading this entry is listed under, such as `Buttons` or `Auth`.
  final String group;

  /// Name of the entry, including any variant, as one string.
  final String title;

  /// Whether this is a component or a whole screen.
  ///
  /// Set by the constructor rather than by the host, so the two can never
  /// disagree.
  final WidgetSection section;

  final List<WidgetPreviewCase>? _componentCases;
  final WidgetBuilder? _screenBuilder;

  /// Every labelled rendering, in the order the host declared them.
  ///
  /// A screen has exactly one, synthesised from its builder and named after
  /// the entry, so the screens that draw an entry need no second code path.
  List<WidgetPreviewCase> get cases => switch (_screenBuilder) {
    null => _componentCases ?? const <WidgetPreviewCase>[],
    final WidgetBuilder builder => <WidgetPreviewCase>[
      WidgetPreviewCase(label: title, builder: builder),
    ],
  };

  /// Cases that carry a label, which are the only ones ever shown.
  List<WidgetPreviewCase> get usableCases => cases
      .where((WidgetPreviewCase item) => item.isUsable)
      .toList(growable: false);

  /// Whether the entry can be listed at all.
  ///
  /// A malformed entry is dropped rather than thrown over, so one bad
  /// registration cannot stop the gallery from opening.
  bool get isUsable =>
      title.trim().isNotEmpty &&
      group.trim().isNotEmpty &&
      usableCases.isNotEmpty;

  /// Lower-cased text the search field matches against.
  ///
  /// Case labels are included, so searching `disabled` finds the entry that
  /// has a disabled rendering even though its title never says so.
  String get searchText => <String>[
    title,
    group,
    for (final WidgetPreviewCase item in cases) item.label,
  ].join(' ').toLowerCase();
}
