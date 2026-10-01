import 'package:flutter/foundation.dart';

import '../../domain/models/font_family_info.dart';
import '../../domain/models/lottie_asset.dart';
import '../../domain/models/other_asset.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/models/preview_hub_config.dart';
import '../../domain/models/rive_asset.dart';
import '../../domain/models/widget_preview.dart';
import '../../domain/services/asset_catalog_service.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../domain/services/font_catalog_service.dart';
import '../../domain/services/lottie_catalog_service.dart';
import '../../domain/services/other_asset_catalog_service.dart';
import '../../domain/services/rive_catalog_service.dart';

/// One hit in the landing screen's search, naming what it found.
sealed class GlobalSearchResult {
  const GlobalSearchResult();
}

/// A registered component or screen.
final class WidgetSearchResult extends GlobalSearchResult {
  /// Wraps [preview].
  const WidgetSearchResult(this.preview);

  /// Entry found.
  final WidgetPreview preview;
}

/// An icon or image.
final class AssetSearchResult extends GlobalSearchResult {
  /// Wraps [asset].
  const AssetSearchResult(this.asset);

  /// Asset found.
  final PreviewAsset asset;
}

/// A font family.
final class FontSearchResult extends GlobalSearchResult {
  /// Wraps [family].
  const FontSearchResult(this.family);

  /// Family found.
  final FontFamilyInfo family;
}

/// A Lottie animation.
final class LottieSearchResult extends GlobalSearchResult {
  /// Wraps [asset].
  const LottieSearchResult(this.asset);

  /// Animation found.
  final LottieAsset asset;
}

/// A Rive animation.
final class RiveSearchResult extends GlobalSearchResult {
  /// Wraps [asset].
  const RiveSearchResult(this.asset);

  /// Animation found.
  final RiveAsset asset;
}

/// A bundled file no other collection shows: audio, video, JSON, PDF and the
/// rest.
final class OtherSearchResult extends GlobalSearchResult {
  /// Wraps [location].
  const OtherSearchResult(this.location);

  /// File found.
  final OtherAssetLocation location;
}

/// Searches every collection at once from the landing screen.
///
/// Widgets are in memory already. The asset collections are read from the
/// manifests the first time something is typed, not when the gallery opens,
/// so a developer who never searches pays nothing. Remote entries are matched
/// by URL only; nothing is fetched to search them, and other bundled files are
/// found by name without being measured.
class GlobalSearchViewModel extends ChangeNotifier {
  /// Creates a search over what [config] and the manifests describe.
  GlobalSearchViewModel({
    required this._config,
    AssetCatalogService? assets,
    FontCatalogService? fonts,
    LottieCatalogService? lotties,
    RiveCatalogService? rives,
    OtherAssetCatalogService? others,
  }) : _assetCatalog = assets ?? AssetCatalogService(),
       _fontCatalog = fonts ?? FontCatalogService(),
       _lottieCatalog = lotties ?? LottieCatalogService(),
       _riveCatalog = rives ?? RiveCatalogService(),
       _otherCatalog = others ?? OtherAssetCatalogService();

  /// Most hits listed per collection.
  static const int perCollectionLimit = 12;

  final PreviewHubConfig _config;
  final AssetCatalogService _assetCatalog;
  final FontCatalogService _fontCatalog;
  final LottieCatalogService _lottieCatalog;
  final RiveCatalogService _riveCatalog;
  final OtherAssetCatalogService _otherCatalog;

  /// Measurement caches handed to a detail screen opened from a hit, typed the
  /// way each collection's own grid types them.
  final AssetMetricsService imageMetrics = AssetMetricsService();

  /// See [imageMetrics].
  final AssetMetricsService lottieMetrics = AssetMetricsService(
    contentTypePrefixes: const <String>{'application/json', 'text/'},
  );

  /// See [imageMetrics].
  final AssetMetricsService riveMetrics = AssetMetricsService(
    contentTypePrefixes: const <String>{'application/', 'binary/'},
  );

  List<PreviewAsset> _assets = const <PreviewAsset>[];
  List<FontFamilyInfo> _fonts = const <FontFamilyInfo>[];
  List<LottieAsset> _lotties = const <LottieAsset>[];
  List<RiveAsset> _rives = const <RiveAsset>[];
  List<OtherAssetLocation> _others = const <OtherAssetLocation>[];
  Future<void>? _loading;
  bool _isLoaded = false;
  bool _disposed = false;
  String _query = '';

  /// Text being searched for, lower-cased and trimmed.
  String get query => _query;

  /// Whether a search is in progress.
  bool get isActive => _query.isNotEmpty;

  /// Whether the collections are still being read for the first search.
  bool get isLoading => isActive && !_isLoaded;

  /// Registered widgets matching the query.
  List<WidgetSearchResult> get widgets => _config.widgets
      .where(
        (WidgetPreview preview) =>
            preview.isUsable && preview.searchText.contains(_query),
      )
      .take(perCollectionLimit)
      .map(WidgetSearchResult.new)
      .toList(growable: false);

  /// Icons and images matching the query.
  List<AssetSearchResult> get assets => _assets
      .where((PreviewAsset asset) => _matches(asset.name, asset.locator))
      .take(perCollectionLimit)
      .map(AssetSearchResult.new)
      .toList(growable: false);

  /// Font families matching the query.
  List<FontSearchResult> get fonts => _fonts
      .where(
        (FontFamilyInfo family) => _matches(family.name, family.manifestKey),
      )
      .take(perCollectionLimit)
      .map(FontSearchResult.new)
      .toList(growable: false);

  /// Lottie animations matching the query.
  List<LottieSearchResult> get lotties => _lotties
      .where((LottieAsset asset) => _matches(asset.name, asset.locator))
      .take(perCollectionLimit)
      .map(LottieSearchResult.new)
      .toList(growable: false);

  /// Rive animations matching the query.
  List<RiveSearchResult> get rives => _rives
      .where((RiveAsset asset) => _matches(asset.name, asset.locator))
      .take(perCollectionLimit)
      .map(RiveSearchResult.new)
      .toList(growable: false);

  /// Other bundled files matching the query.
  List<OtherSearchResult> get others => _others
      .where(
        (OtherAssetLocation location) =>
            _matches(location.name, location.locator),
      )
      .take(perCollectionLimit)
      .map(OtherSearchResult.new)
      .toList(growable: false);

  /// Whether nothing at all matches.
  bool get hasNoResults =>
      !isLoading &&
      widgets.isEmpty &&
      assets.isEmpty &&
      fonts.isEmpty &&
      lotties.isEmpty &&
      rives.isEmpty &&
      others.isEmpty;

  bool _matches(String name, String locator) =>
      name.toLowerCase().contains(_query) ||
      locator.toLowerCase().contains(_query);

  /// Searches for [value], reading the collections first if this is the first
  /// search.
  void search(String value) {
    final String next = value.trim().toLowerCase();
    if (next == _query) {
      return;
    }
    _query = next;
    notifyListeners();
    if (next.isNotEmpty) {
      _loading ??= _load();
    }
  }

  /// Reads every collection. One that cannot be read, such as an app with no
  /// font manifest, contributes nothing rather than failing the search.
  Future<void> _load() async {
    final (
      List<PreviewAsset> assets,
      List<FontFamilyInfo> fonts,
      List<LottieAsset> lotties,
      List<RiveAsset> rives,
      List<OtherAssetLocation> others,
    ) = await (
      _orEmpty(
        _assetCatalog
            .load(networkImages: _config.networkImages)
            .then((AssetCatalog catalog) => catalog.assets),
      ),
      _orEmpty(_fontCatalog.load()),
      _orEmpty(_lottieCatalog.load(networkLotties: _config.networkLotties)),
      _orEmpty(_riveCatalog.load(networkRives: _config.networkRives)),
      _orEmpty(_otherCatalog.locate()),
    ).wait;
    if (_disposed) {
      return;
    }
    _assets = assets;
    _fonts = fonts;
    _lotties = lotties;
    _rives = rives;
    _others = others;
    _isLoaded = true;
    notifyListeners();
  }

  static Future<List<T>> _orEmpty<T>(Future<List<T>> load) async {
    try {
      return await load;
    } on Object catch (_) {
      return <T>[];
    }
  }

  @override
  void dispose() {
    _disposed = true;
    imageMetrics.dispose();
    lottieMetrics.dispose();
    riveMetrics.dispose();
    super.dispose();
  }
}
