import 'package:flutter/services.dart';

import '../models/rive_asset.dart';

/// Builds the list of Rive animations the gallery can play. Bundled animations
/// come from the asset manifest, so a consumer never registers them: every
/// `.riv` Flutter bundled is picked up.
class RiveCatalogService {
  /// Reads bundled assets from [bundle], defaulting to the app's own bundle.
  RiveCatalogService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Every animation, bundled ones first, then the supplied URLs.
  Future<List<RiveAsset>> load({
    List<String> networkRives = const <String>[],
  }) async => <RiveAsset>[
    ...await _discoverBundled(),
    ...networkRives.map(RiveAsset.network).nonNulls,
  ];

  Future<List<RiveAsset>> _discoverBundled() async {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      _bundle,
    );
    final List<RiveAsset> found = manifest
        .listAssets()
        .map(RiveAsset.bundled)
        .nonNulls
        .toList();
    found.sort((RiveAsset a, RiveAsset b) => a.locator.compareTo(b.locator));
    return found;
  }
}
