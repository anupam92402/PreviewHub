import 'package:flutter/foundation.dart';

import 'widget_preview.dart';

/// What the gallery cannot work out for itself.
///
/// Bundled assets are discovered through the asset manifest and never need
/// registering, so this carries only the remote URLs:
///
/// ```dart
/// PreviewHubDashboard(
///   config: PreviewHubConfig(
///     networkImages: <String>['https://example.com/logo.svg'],
///   ),
/// )
/// ```
@immutable
class PreviewHubConfig {
  /// Creates a configuration; every field has a usable default.
  const PreviewHubConfig({
    this.networkImages = const <String>[],
    this.networkLotties = const <String>[],
    this.networkRives = const <String>[],
    this.widgets = const <WidgetPreview>[],
  });

  /// Remote icons and images to list alongside the bundled ones.
  ///
  /// Entries whose URL does not end in a supported image extension are ignored.
  final List<String> networkImages;

  /// Remote Lottie animations to list alongside the bundled ones.
  ///
  /// Entries that are not http or https URLs are ignored.
  final List<String> networkLotties;

  /// Remote Rive animations to list alongside the bundled ones.
  ///
  /// Entries that are not http or https URLs are ignored.
  final List<String> networkRives;

  /// Components and screens to list in the widget gallery.
  ///
  /// A widget is code rather than an asset, so there is no manifest to read:
  /// the host registers what it wants previewed. Entries missing a title, a
  /// group or a usable case are ignored.
  final List<WidgetPreview> widgets;
}
