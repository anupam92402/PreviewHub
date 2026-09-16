import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/models/preview_asset.dart';
import '../../preview_hub_strings.dart';

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

  /// Reports a failure after the current frame, since builders run during
  /// layout and the listener rebuilds the tile around them.
  void _reportFailure() {
    final VoidCallback? onFailed = this.onFailed;
    if (onFailed == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => onFailed());
  }

  @override
  Widget build(BuildContext context) {
    if (asset.type == AssetType.svg) {
      Widget onSvgError(BuildContext context, Object error, StackTrace stack) {
        _reportFailure();
        return const SizedBox.shrink();
      }

      return asset.source == AssetSource.bundled
          ? SvgPicture.asset(asset.locator, fit: fit, errorBuilder: onSvgError)
          : SvgPicture.network(
              asset.locator,
              fit: fit,
              placeholderBuilder: (BuildContext context) => const _Spinner(),
              errorBuilder: onSvgError,
            );
    }
    return _RasterPreview(
      provider: asset.source == AssetSource.bundled
          ? AssetImage(asset.locator)
          : NetworkImage(asset.locator),
      fit: fit,
      onDimensions: onDimensions,
      onFailed: onFailed,
    );
  }
}

/// Draws a raster image and reports the size it decoded to.
class _RasterPreview extends StatefulWidget {
  const _RasterPreview({
    required this.provider,
    required this.fit,
    this.onDimensions,
    this.onFailed,
  });

  final ImageProvider provider;
  final BoxFit fit;
  final void Function(int width, int height)? onDimensions;
  final VoidCallback? onFailed;

  @override
  State<_RasterPreview> createState() => _RasterPreviewState();
}

class _RasterPreviewState extends State<_RasterPreview> {
  late final ImageStreamListener _listener = ImageStreamListener(
    _onImage,
    onError: (Object error, StackTrace? stack) {},
  );
  ImageStream? _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribe();
  }

  @override
  void didUpdateWidget(_RasterPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider != oldWidget.provider) {
      _subscribe();
    }
  }

  /// Listens to the same stream the [Image] below draws, so the decode is
  /// shared rather than repeated.
  void _subscribe() {
    final ImageStream stream = widget.provider.resolve(
      createLocalImageConfiguration(context),
    );
    if (stream.key == _stream?.key) {
      return;
    }
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  /// Reports the decoded size and releases this listener's own clone of the
  /// image, which the completer hands out per listener.
  void _onImage(ImageInfo info, bool synchronousCall) {
    widget.onDimensions?.call(info.image.width, info.image.height);
    info.dispose();
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: widget.provider,
      fit: widget.fit,
      filterQuality: FilterQuality.medium,
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) =>
              progress == null ? child : const _Spinner(),
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        final VoidCallback? onFailed = widget.onFailed;
        if (onFailed != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onFailed());
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Shown while artwork is still arriving.
class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const Center(
    child: SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}

/// Stands in for artwork that could not be drawn. Sizes itself to whatever box
/// it is handed; a fixed glyph and caption do not fit the few dozen pixels a
/// tile gets at four per row.
class AssetPreviewFailure extends StatelessWidget {
  /// Creates a failure panel tinted with [accent].
  const AssetPreviewFailure({
    required this.accent,
    this.message = PreviewHubStrings.assetLoadFailed,
    this.iconSize = 28,
    super.key,
  });

  /// Colour of the glyph and caption.
  final Color accent;

  /// Caption under the glyph.
  final String message;

  /// Largest the glyph is allowed to be.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double shortest = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final double glyph = math.min(iconSize, shortest * 0.5);
        final double fontSize = math.max(9, glyph * 0.39);
        final bool showCaption =
            constraints.maxHeight >= glyph + fontSize * 2.4;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.quiz_outlined, size: glyph, color: accent),
            if (showCaption) ...<Widget>[
              SizedBox(height: glyph * 0.18),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: fontSize, color: accent),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
