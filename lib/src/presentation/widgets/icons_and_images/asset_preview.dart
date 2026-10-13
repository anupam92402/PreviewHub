import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../domain/models/preview_asset.dart';
import '../common/small_spinner.dart';
import 'asset_raster_preview.dart';

/// Renders [asset] whatever its format and source. Raster formats report their
/// decoded size through [onDimensions], which is where the gallery's width and
/// height come from at no extra network cost.
class AssetPreview extends StatelessWidget {
  /// Creates a preview of [asset].
  const AssetPreview({
    required this.asset,
    this.fit = BoxFit.contain,
    this.onDimensions,
    this.onFailed,
    this.tint,
    super.key,
  });

  /// Asset to draw.
  final PreviewAsset asset;

  /// How the artwork fills its box.
  final BoxFit fit;

  /// Called with the decoded pixel size, for raster formats only.
  final void Function(int width, int height)? onDimensions;

  /// Called when the artwork cannot be drawn at all. A failed measurement is
  /// not a failure; an image whose size cannot be read still draws fine.
  final VoidCallback? onFailed;

  /// Colour to fill the artwork's shape with, as an icon tinted by
  /// `IconTheme` would be, or null to draw it as authored.
  final Color? tint;

  /// The provider a raster [asset] is drawn from. Shared with [load], so the
  /// image it loads is the one the preview then draws from the image cache.
  static ImageProvider<Object> providerFor(PreviewAsset asset) =>
      asset.source == AssetSource.bundled
      ? AssetImage(asset.locator)
      : NetworkImage(asset.locator);

  /// Loads [asset] the way the preview would and reports whether it can be
  /// drawn, so a screen can hold back controls that only make sense for
  /// drawable artwork until the outcome is known. A raster image is resolved
  /// against [configuration] into the image cache and an SVG is parsed through
  /// the SVG byte cache, so the preview drawn afterwards reuses the work
  /// rather than fetching the file again.
  static Future<bool> load(
    PreviewAsset asset,
    ImageConfiguration configuration,
  ) async {
    try {
      if (asset.type == AssetType.svg) {
        final BytesLoader loader = asset.source == AssetSource.bundled
            ? SvgAssetLoader(asset.locator)
            : SvgNetworkLoader(asset.locator);
        final PictureInfo info = await vg.loadPicture(loader, null);
        info.picture.dispose();
        return true;
      }
      final Completer<bool> outcome = Completer<bool>();
      final ImageStream stream = providerFor(asset).resolve(configuration);
      late final ImageStreamListener listener;
      void finish(bool drawable) {
        stream.removeListener(listener);
        if (!outcome.isCompleted) {
          outcome.complete(drawable);
        }
      }

      listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
        info.dispose();
        finish(true);
      }, onError: (Object error, StackTrace? stack) => finish(false));
      stream.addListener(listener);
      return await outcome.future;
    } on Object catch (_) {
      return false;
    }
  }

  /// Reports a failure after the current frame, since builders run during
  /// layout and the listener rebuilds the tile around them.
  void _reportFailure() {
    final VoidCallback? onFailed = this.onFailed;
    if (onFailed == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => onFailed());
  }

  @override
  Widget build(BuildContext context) {
    if (asset.type == AssetType.svg) {
      Widget onSvgError(BuildContext context, Object error, StackTrace stack) {
        _reportFailure();
        return const SizedBox.shrink();
      }

      final Color? tint = this.tint;
      final ColorFilter? filter = tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn);
      return asset.source == AssetSource.bundled
          ? SvgPicture.asset(
              asset.locator,
              fit: fit,
              colorFilter: filter,
              errorBuilder: onSvgError,
            )
          : SvgPicture.network(
              asset.locator,
              fit: fit,
              colorFilter: filter,
              placeholderBuilder: (BuildContext context) =>
                  const SmallSpinner(),
              errorBuilder: onSvgError,
            );
    }
    return AssetRasterPreview(
      provider: providerFor(asset),
      fit: fit,
      tint: tint,
      onDimensions: onDimensions,
      onFailed: onFailed,
    );
  }
}
