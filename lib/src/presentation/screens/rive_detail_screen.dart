import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/rive_asset.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../preview_hub_strings.dart';
import '../widgets/rive_player.dart';

/// Everything known about one Rive animation, playing at full size.
class RiveDetailScreen extends StatefulWidget {
  /// Creates the detail screen for [asset].
  const RiveDetailScreen({
    required this.asset,
    required this.metrics,
    super.key,
  });

  /// Animation being inspected.
  final RiveAsset asset;

  /// Shared measurement cache.
  final AssetMetricsService metrics;

  @override
  State<RiveDetailScreen> createState() => _RiveDetailScreenState();
}

class _RiveDetailScreenState extends State<RiveDetailScreen> {
  final ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _failed = ValueNotifier<bool>(false);
  final ValueNotifier<rive.RiveWidgetController?> _controller =
      ValueNotifier<rive.RiveWidgetController?>(null);

  /// Disposes the notifiers; the Rive controller itself belongs to the player.
  @override
  void dispose() {
    _isPlaying.dispose();
    _failed.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Plays from the start again.
  void _restart() {
    _controller.value?.stateMachine.advanceAndApply(0);
    _controller.value?.active = true;
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
    final RiveAsset asset = widget.asset;

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
                    ? RivePlayerFailure(accent: accent, iconSize: 44)
                    : ValueListenableBuilder<bool>(
                        valueListenable: _isPlaying,
                        builder:
                            (
                              BuildContext context,
                              bool playing,
                              Widget? child,
                            ) => RivePlayer(
                              asset: asset,
                              isPlaying: playing,
                              onLoaded: (rive.RiveWidgetController c) =>
                                  _controller.value = c,
                              onFailed: () => _failed.value = true,
                            ),
                      ),
              ),
              if (!failed) ...<Widget>[
                const SizedBox(height: 14),
                _Transport(
                  isPlaying: _isPlaying,
                  controller: _controller,
                  onRestart: _restart,
                ),
              ],
              const SizedBox(height: 18),
              _Row(label: PreviewHubStrings.detailName, value: asset.name),
              _Row(
                label: PreviewHubStrings.detailSource,
                value: asset.source.label,
              ),
              ValueListenableBuilder<rive.RiveWidgetController?>(
                valueListenable: _controller,
                builder:
                    (
                      BuildContext context,
                      rive.RiveWidgetController? controller,
                      Widget? child,
                    ) => Column(
                      children: <Widget>[
                        _Row(
                          label: PreviewHubStrings.riveDetailArtboard,
                          value:
                              controller?.artboard.name ??
                              PreviewHubStrings.assetUnavailable,
                        ),
                        _Row(
                          label: PreviewHubStrings.riveDetailStateMachine,
                          value:
                              controller?.stateMachine.name ??
                              PreviewHubStrings.riveNoStateMachine,
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
    required this.controller,
    required this.onRestart,
  });

  final ValueNotifier<bool> isPlaying;
  final ValueNotifier<rive.RiveWidgetController?> controller;
  final VoidCallback onRestart;

  /// Builds the controls; restart stays disabled until the file loads, since
  /// before that there is no first frame to return to.
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
      ValueListenableBuilder<rive.RiveWidgetController?>(
        valueListenable: controller,
        builder:
            (
              BuildContext context,
              rive.RiveWidgetController? loaded,
              Widget? child,
            ) => OutlinedButton.icon(
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
