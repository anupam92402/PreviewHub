import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/models/validation_issue.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../preview_hub_strings.dart';
import '../theme/asset_type_style.dart';
import '../widgets/asset_preview.dart';
import '../widgets/asset_preview_ramp.dart';
import '../widgets/asset_tile.dart';
import '../widgets/asset_tint_picker.dart';
import '../widgets/preview_backdrop.dart';

/// Everything known about one asset, with the artwork at full size. Where
/// the grid only says an asset is broken, this names the failure.
///
/// The artwork can be put on a checkerboard, white or near black, tinted the
/// way an icon theme would tint it, and drawn at the sizes icons ship at.
class AssetDetailScreen extends StatefulWidget {
  /// Creates the detail screen for [asset].
  const AssetDetailScreen({
    required this.asset,
    required this.metrics,
    super.key,
  });

  /// Asset being inspected.
  final PreviewAsset asset;

  /// Shared measurement cache.
  final AssetMetricsService metrics;

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

/// Where loading the artwork has got to. Nothing about the artwork is shown
/// until it leaves [loading], so a file that turns out to be broken never
/// flashes its controls before the error replaces them.
enum _Artwork {
  /// Still being loaded.
  loading,

  /// Loaded and drawable.
  ready,

  /// Could not be drawn.
  failed,
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final ValueNotifier<_Artwork> _artwork = ValueNotifier<_Artwork>(
    _Artwork.loading,
  );
  final ValueNotifier<PreviewBackdrop> _backdrop =
      ValueNotifier<PreviewBackdrop>(PreviewBackdrop.surface);
  final ValueNotifier<Color?> _tint = ValueNotifier<Color?>(null);
  bool _loadStarted = false;

  /// Loads the artwork once, against this screen's image configuration so the
  /// preview drawn afterwards comes straight from the cache.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStarted) {
      return;
    }
    _loadStarted = true;
    AssetPreview.load(
      widget.asset,
      createLocalImageConfiguration(context),
    ).then((bool drawable) {
      if (mounted && _artwork.value == _Artwork.loading) {
        _artwork.value = drawable ? _Artwork.ready : _Artwork.failed;
      }
    });
  }

  @override
  void dispose() {
    _artwork.dispose();
    _backdrop.dispose();
    _tint.dispose();
    super.dispose();
  }

  /// Names the failure, falling back to a plain sentence when the cause was
  /// never recorded, as with a bundled file that simply will not decode.
  String _describeFailure() {
    final ValidationIssue? issue = widget.metrics.issueFor(widget.asset);
    if (issue == null) {
      return PreviewHubStrings.assetCannotDisplay;
    }
    return issue.detail == null
        ? issue.failure.message
        : '${issue.failure.message} (${issue.detail})';
  }

  @override
  Widget build(BuildContext context) {
    final PreviewAsset asset = widget.asset;
    final AssetMetricsService metrics = widget.metrics;

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: <Widget>[
          ListenableBuilder(
            listenable: Listenable.merge(<Listenable>[
              _artwork,
              _backdrop,
              _tint,
            ]),
            builder: (BuildContext context, Widget? child) {
              final bool failed = _artwork.value == _Artwork.failed;
              final Color accent = failed
                  ? Theme.of(context).colorScheme.error
                  : AssetTypeStyle.colorOf(asset.type);

              return PreviewBackdropBox(
                backdrop: _backdrop.value,
                accent: accent,
                failed: failed,
                child: switch (_artwork.value) {
                  _Artwork.loading => const _Loading(),
                  _Artwork.failed => AssetPreviewFailure(
                    accent: accent,
                    iconSize: 44,
                  ),
                  _Artwork.ready => AssetPreview(
                    asset: asset,
                    tint: _tint.value,
                    onDimensions: (int width, int height) =>
                        metrics.recordDimensions(asset, width, height),
                    onFailed: () => _artwork.value = _Artwork.failed,
                  ),
                },
              );
            },
          ),
          const SizedBox(height: 14),
          // Background and tint choices, then the artwork at icon sizes in a
          // panel of its own on the same background. Shown only once the
          // artwork has loaded: a broken file never gets them.
          ListenableBuilder(
            listenable: Listenable.merge(<Listenable>[
              _artwork,
              _backdrop,
              _tint,
            ]),
            builder: (BuildContext context, Widget? child) =>
                _artwork.value != _Artwork.ready
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          PreviewBackdropPicker(
                            value: _backdrop.value,
                            onChanged: (PreviewBackdrop value) =>
                                _backdrop.value = value,
                          ),
                          AssetTintPicker(
                            value: _tint.value,
                            onChanged: (Color? value) => _tint.value = value,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        PreviewHubStrings.assetIconSizes,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      PreviewBackdropBox(
                        backdrop: _backdrop.value,
                        accent: AssetTypeStyle.colorOf(asset.type),
                        height: 116,
                        // Shrinks rather than clips at large text sizes or
                        // on a narrow phone.
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AssetPreviewRamp(
                              asset: asset,
                              tint: _tint.value,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 22),
          ValueListenableBuilder<AssetMetricsState>(
            valueListenable: metrics.watch(asset),
            builder:
                (
                  BuildContext context,
                  AssetMetricsState state,
                  Widget? child,
                ) => Column(
                  children: <Widget>[
                    _Row(
                      label: PreviewHubStrings.detailName,
                      value: asset.name,
                    ),
                    _Row(
                      label: PreviewHubStrings.detailType,
                      value: asset.type.label,
                      valueColor: AssetTypeStyle.colorOf(asset.type),
                    ),
                    _Row(
                      label: PreviewHubStrings.detailSource,
                      value: asset.source.label,
                    ),
                    _Row(
                      label: PreviewHubStrings.detailDimensions,
                      value: state.status == MetricsStatus.failed
                          ? PreviewHubStrings.assetUnavailable
                          : describeDimensions(asset, state.metrics),
                    ),
                    _Row(
                      label: PreviewHubStrings.detailSize,
                      value: switch (state.status) {
                        MetricsStatus.loading => PreviewHubStrings.measuring,
                        MetricsStatus.failed =>
                          PreviewHubStrings.assetUnavailable,
                        MetricsStatus.ready => AssetMetrics.formatBytes(
                          state.metrics.sizeInBytes,
                        ),
                      },
                    ),
                    _Row(
                      label: asset.source == AssetSource.bundled
                          ? PreviewHubStrings.detailPath
                          : PreviewHubStrings.detailUrl,
                      value: asset.locator,
                      onCopy: () => _copy(context, asset.locator),
                    ),
                    ValueListenableBuilder<_Artwork>(
                      valueListenable: _artwork,
                      builder:
                          (
                            BuildContext context,
                            _Artwork artwork,
                            Widget? child,
                          ) =>
                              artwork == _Artwork.failed ||
                                  state.status == MetricsStatus.failed
                              ? _Row(
                                  label: PreviewHubStrings.detailError,
                                  value: _describeFailure(),
                                  valueColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(PreviewHubStrings.copied),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// One label/value line, optionally with a copy button.
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.onCopy,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.35,
                color: valueColor,
                fontWeight: valueColor == null ? null : FontWeight.w700,
              ),
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              tooltip: PreviewHubStrings.copy,
              iconSize: 17,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
    );
  }
}

/// Fills the artwork box while the file is still loading.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Center(
    child: SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}
