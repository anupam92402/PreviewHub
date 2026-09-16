import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/lottie_asset.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../preview_hub_strings.dart';
import '../widgets/lottie_player.dart';

/// Everything known about one animation, playing at full size.
class LottieDetailScreen extends StatefulWidget {
  /// Creates the detail screen for [asset].
  const LottieDetailScreen({
    required this.asset,
    required this.metrics,
    super.key,
  });

  /// Animation being inspected.
  final LottieAsset asset;

  /// Shared measurement cache.
  final AssetMetricsService metrics;

  @override
  State<LottieDetailScreen> createState() => _LottieDetailScreenState();
}

class _LottieDetailScreenState extends State<LottieDetailScreen>
    with SingleTickerProviderStateMixin {
  /// Owned here rather than by the player, because restarting rewinds the
  /// animation instead of merely resuming it.
  late final AnimationController _controller = AnimationController(vsync: this);
  final ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _failed = ValueNotifier<bool>(false);
  final ValueNotifier<LottieComposition?> _composition =
      ValueNotifier<LottieComposition?>(null);

  @override
  void dispose() {
    _controller.dispose();
    _isPlaying.dispose();
    _failed.dispose();
    _composition.dispose();
    super.dispose();
  }

  /// Plays from the first frame again.
  void _restart() {
    _controller.reset();
    _controller.repeat();
    _isPlaying.value = true;
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.asset.locator));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(PreviewHubStrings.copied),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LottieAsset asset = widget.asset;

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _failed,
        builder: (BuildContext context, bool failed, Widget? child) {
          final ColorScheme scheme = Theme.of(context).colorScheme;
          final Color accent = failed ? scheme.error : scheme.primary;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: <Widget>[
              Container(
                height: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: failed ? 0.10 : 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.22)),
                ),
                child: failed
                    ? LottiePlayerFailure(accent: accent, iconSize: 44)
                    : ValueListenableBuilder<bool>(
                        valueListenable: _isPlaying,
                        builder:
                            (
                              BuildContext context,
                              bool playing,
                              Widget? child,
                            ) => LottiePlayer(
                              asset: asset,
                              isPlaying: playing,
                              controller: _controller,
                              onLoaded: (LottieComposition c) =>
                                  _composition.value = c,
                              onFailed: () => _failed.value = true,
                            ),
                      ),
              ),
              if (!failed) ...<Widget>[
                const SizedBox(height: 14),
                _Transport(
                  isPlaying: _isPlaying,
                  composition: _composition,
                  onRestart: _restart,
                ),
              ],
              const SizedBox(height: 18),
              _Row(label: PreviewHubStrings.detailName, value: asset.name),
              _Row(
                label: PreviewHubStrings.detailSource,
                value: asset.source.label,
              ),
              ValueListenableBuilder<LottieComposition?>(
                valueListenable: _composition,
                builder:
                    (
                      BuildContext context,
                      LottieComposition? composition,
                      Widget? child,
                    ) => Column(
                      children: <Widget>[
                        _Row(
                          label: PreviewHubStrings.lottieDetailDuration,
                          value: composition == null
                              ? PreviewHubStrings.assetUnavailable
                              : PreviewHubStrings.lottieDuration(
                                  composition.duration,
                                ),
                        ),
                        _Row(
                          label: PreviewHubStrings.lottieDetailFrames,
                          value: composition == null
                              ? PreviewHubStrings.assetUnavailable
                              : '${composition.endFrame.toInt()} '
                                    '@ ${composition.frameRate.toInt()}fps',
                        ),
                      ],
                    ),
              ),
              ValueListenableBuilder<AssetMetricsState>(
                valueListenable: widget.metrics.watch(asset),
                builder:
                    (
                      BuildContext context,
                      AssetMetricsState state,
                      Widget? child,
                    ) => _Row(
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
              ),
              _Row(
                label: asset.source == AssetSource.bundled
                    ? PreviewHubStrings.detailPath
                    : PreviewHubStrings.detailUrl,
                value: asset.locator,
                onCopy: _copy,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Play, pause and restart, side by side.
class _Transport extends StatelessWidget {
  const _Transport({
    required this.isPlaying,
    required this.composition,
    required this.onRestart,
  });

  final ValueNotifier<bool> isPlaying;
  final ValueNotifier<LottieComposition?> composition;
  final VoidCallback onRestart;

  /// Builds the controls; restart stays disabled until the composition parses,
  /// since before that there is no first frame to return to.
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      ValueListenableBuilder<bool>(
        valueListenable: isPlaying,
        builder: (BuildContext context, bool playing, Widget? child) =>
            FilledButton.tonalIcon(
              onPressed: () => isPlaying.value = !playing,
              icon: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 18,
              ),
              label: Text(
                playing
                    ? PreviewHubStrings.lottiePause
                    : PreviewHubStrings.lottiePlay,
              ),
            ),
      ),
      const SizedBox(width: 12),
      ValueListenableBuilder<LottieComposition?>(
        valueListenable: composition,
        builder:
            (BuildContext context, LottieComposition? loaded, Widget? child) =>
                OutlinedButton.icon(
                  onPressed: loaded == null ? null : onRestart,
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: const Text(PreviewHubStrings.lottieRestart),
                ),
      ),
    ],
  );
}

/// One label/value line, optionally with a copy button.
class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.onCopy});

  final String label;
  final String value;
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
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
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
