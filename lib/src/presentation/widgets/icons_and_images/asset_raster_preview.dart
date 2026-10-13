import 'package:flutter/material.dart';

import '../common/small_spinner.dart';

/// Draws a raster image and reports the size it decoded to.
class AssetRasterPreview extends StatefulWidget {
  /// Creates a preview drawing [provider] with [fit].
  const AssetRasterPreview({
    required this.provider,
    required this.fit,
    this.tint,
    this.onDimensions,
    this.onFailed,
    super.key,
  });

  /// Source of the image drawn.
  final ImageProvider<Object> provider;

  /// How the image fills its box.
  final BoxFit fit;

  /// Colour to fill the image's shape with, or null to draw it as authored.
  final Color? tint;

  /// Called with the decoded pixel size.
  final void Function(int width, int height)? onDimensions;

  /// Called when the image cannot be drawn.
  final VoidCallback? onFailed;

  @override
  State<AssetRasterPreview> createState() => _AssetRasterPreviewState();
}

class _AssetRasterPreviewState extends State<AssetRasterPreview> {
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
  void didUpdateWidget(AssetRasterPreview oldWidget) {
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
      color: widget.tint,
      colorBlendMode: widget.tint == null ? null : BlendMode.srcIn,
      filterQuality: FilterQuality.medium,
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) =>
              progress == null ? child : const SmallSpinner(),
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        final VoidCallback? onFailed = widget.onFailed;
        if (onFailed != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (Duration _) => onFailed(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
