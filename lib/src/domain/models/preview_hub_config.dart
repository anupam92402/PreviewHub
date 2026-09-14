import 'package:flutter/foundation.dart';

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
  const PreviewHubConfig({this.networkImages = const <String>[]});

  /// Remote icons and images to list alongside the bundled ones.
  ///
  /// Entries whose URL does not end in a supported image extension are ignored.
  final List<String> networkImages;
}
