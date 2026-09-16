import 'package:flutter/services.dart';

import '../models/preview_asset.dart';
import '../models/validation_issue.dart';

/// What a catalogue load produced: what can be shown, and what could not.
class AssetCatalog {
  /// Creates a catalogue.
  const AssetCatalog({required this.assets, required this.issues});

  /// Assets worth putting on screen, bundled first then remote.
  final List<PreviewAsset> assets;

  /// Entries rejected before any request was made.
  final List<ValidationIssue> issues;
}

/// Builds the list of previewable image assets.
/// Bundled assets come from the asset manifest, so a consumer never registers
/// them: anything Flutter bundled and listed there is picked up, including
/// assets shipped by dependencies under a `packages/<name>/` key.
/// Supplied URLs are checked for shape here, which costs nothing. Whether the
/// server actually serves an image is only discovered when something asks for
/// that asset's metrics.
class AssetCatalogService {
  /// Reads bundled assets from [bundle], defaulting to the app's own bundle.
  AssetCatalogService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Every supported image, bundled ones first, plus anything rejected.
  Future<AssetCatalog> load({
    List<String> networkImages = const <String>[],
  }) async {
    final List<PreviewAsset> assets = await _discoverBundled();
    final List<ValidationIssue> issues = <ValidationIssue>[];

    for (final String entry in networkImages) {
      final ValidationIssue? issue = _validate(entry);
      if (issue != null) {
        issues.add(issue);
        continue;
      }
      final PreviewAsset? asset = PreviewAsset.network(entry);
      if (asset != null) {
        assets.add(asset);
      }
    }

    return AssetCatalog(assets: assets, issues: issues);
  }

  /// Image keys from the asset manifest, sorted by key.
  ///
  /// [AssetManifest.listAssets] already drops resolution variants, so a `2.0x/`
  /// copy never shows up as a separate asset.
  Future<List<PreviewAsset>> _discoverBundled() async {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      _bundle,
    );
    final List<PreviewAsset> found = manifest
        .listAssets()
        .map(PreviewAsset.bundled)
        .nonNulls
        .toList();
    found.sort(
      (PreviewAsset a, PreviewAsset b) => a.locator.compareTo(b.locator),
    );
    return found;
  }

  /// Checks [entry] is an http or https URL naming a supported image.
  ValidationIssue? _validate(String entry) {
    final Uri? uri = Uri.tryParse(entry);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return ValidationIssue(
        entry: entry,
        failure: ValidationFailure.malformedUrl,
      );
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return ValidationIssue(
        entry: entry,
        failure: ValidationFailure.unsupportedScheme,
        detail: '${uri.scheme}:',
      );
    }
    if (AssetType.fromLocator(entry) == null) {
      return ValidationIssue(
        entry: entry,
        failure: ValidationFailure.unsupportedFormat,
      );
    }
    return null;
  }
}
