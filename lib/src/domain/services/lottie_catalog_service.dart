import 'package:flutter/services.dart';

import '../models/lottie_asset.dart';

/// Builds the list of Lottie animations the gallery can play.
///
/// Bundled animations come from the asset manifest, so a consumer never
/// registers them. Every bundled `.json` is offered: whether a file really is
/// a Lottie is only knowable once it is parsed, so anything that is not shows
/// up and fails visibly rather than being guessed at by its path.
class LottieCatalogService {
  /// Reads bundled assets from [bundle], defaulting to the app's own bundle.
  LottieCatalogService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Every animation, bundled ones first, then the supplied URLs.
  Future<List<LottieAsset>> load({
    List<String> networkLotties = const <String>[],
  }) async => <LottieAsset>[
    ...await _discoverBundled(),
    ...networkLotties.map(LottieAsset.network).nonNulls,
  ];

  Future<List<LottieAsset>> _discoverBundled() async {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      _bundle,
    );
    final List<LottieAsset> found = manifest
        .listAssets()
        .map(LottieAsset.bundled)
        .nonNulls
        .toList();
    found.sort(
      (LottieAsset a, LottieAsset b) => a.locator.compareTo(b.locator),
    );
    return found;
  }
}
