import 'package:flutter/services.dart';

import '../models/lottie_asset.dart';

/// Builds the list of Lottie animations the gallery can play. Bundled
/// animations come from the asset manifest, so none are registered by hand.
/// Every bundled `.json` is offered, since only parsing tells a Lottie from
/// anything else; a file that is not one fails visibly.
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
