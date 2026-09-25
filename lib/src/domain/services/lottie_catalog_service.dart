import 'package:flutter/services.dart';

import '../models/lottie_asset.dart';
import 'lottie_document.dart';

/// Builds the list of Lottie animations the gallery can play. Bundled
/// animations come from the asset manifest, so none are registered by hand.
/// Every bundled `.json` is read once and kept only if it really is Bodymovin
/// JSON, so translations, config and mock responses never reach the grid.
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
    final List<LottieAsset> candidates = manifest
        .listAssets()
        .map(LottieAsset.bundled)
        .nonNulls
        .toList();
    final List<bool> isAnimation = await Future.wait(
      candidates.map((LottieAsset asset) => _isAnimation(asset.locator)),
    );

    final List<LottieAsset> found = <LottieAsset>[
      for (int i = 0; i < candidates.length; i++)
        if (isAnimation[i]) candidates[i],
    ];
    found.sort(
      (LottieAsset a, LottieAsset b) => a.locator.compareTo(b.locator),
    );
    return found;
  }

  /// Whether the bundled JSON at [key] is an animation. The text is loaded
  /// uncached, since a document read only to be classified is not worth
  /// holding on to — an animation the gallery goes on to play is loaded again
  /// by the player, which caches its own composition.
  Future<bool> _isAnimation(String key) async {
    try {
      return LottieDocument.describesAnimation(
        await _bundle.loadString(key, cache: false),
      );
    } on Object catch (_) {
      return false;
    }
  }
}
