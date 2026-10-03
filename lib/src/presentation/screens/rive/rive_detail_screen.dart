import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../../domain/models/asset_metrics.dart';
import '../../../domain/models/preview_asset.dart';
import '../../../domain/models/rive_asset.dart';
import '../../../domain/services/asset_metrics_service.dart';
import '../../../util/preview_hub_strings.dart';
import '../../widgets/common/animation_playback_failure.dart';
import '../../widgets/common/copied_snack_bar.dart';
import '../../widgets/common/detail_row.dart';
import '../../widgets/common/preview_backdrop.dart';
import '../../widgets/rive/rive_player.dart';
import '../../widgets/rive/rive_transport.dart';

/// Everything known about one Rive animation, playing at full size on a
/// choice of background.
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
  final ValueNotifier<PreviewBackdrop> _backdrop =
      ValueNotifier<PreviewBackdrop>(PreviewBackdrop.surface);

  /// Disposes the notifiers; the Rive controller itself belongs to the player.
  @override
  void dispose() {
    _isPlaying.dispose();
    _failed.dispose();
    _controller.dispose();
    _backdrop.dispose();
    super.dispose();
  }

  /// Plays from the start again.
  void _restart() {
    _controller.value?.stateMachine.advanceAndApply(0);
    _controller.value?.active = true;
    _isPlaying.value = true;
  }

  void _copy() => CopiedSnackBar.copy(context, widget.asset.locator);

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
              ValueListenableBuilder<PreviewBackdrop>(
                valueListenable: _backdrop,
                builder:
                    (
                      BuildContext context,
                      PreviewBackdrop backdrop,
                      Widget? child,
                    ) => PreviewBackdropBox(
                      backdrop: backdrop,
                      accent: accent,
                      height: 300,
                      failed: failed,
                      child: child!,
                    ),
                child: failed
                    ? AnimationPlaybackFailure(
                        message: PreviewHubStrings.riveFailed,
                        accent: accent,
                        iconSize: 44,
                      )
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
                RiveTransport(
                  isPlaying: _isPlaying,
                  controller: _controller,
                  onRestart: _restart,
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<PreviewBackdrop>(
                  valueListenable: _backdrop,
                  builder:
                      (
                        BuildContext context,
                        PreviewBackdrop backdrop,
                        Widget? child,
                      ) => Center(
                        child: PreviewBackdropPicker(
                          value: backdrop,
                          onChanged: (PreviewBackdrop value) =>
                              _backdrop.value = value,
                        ),
                      ),
                ),
              ],
              const SizedBox(height: 18),
              DetailRow(label: PreviewHubStrings.detailName, value: asset.name),
              DetailRow(
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
                        DetailRow(
                          label: PreviewHubStrings.riveDetailArtboard,
                          value:
                              controller?.artboard.name ??
                              PreviewHubStrings.assetUnavailable,
                        ),
                        DetailRow(
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
                    ) => DetailRow(
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
              DetailRow(
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
