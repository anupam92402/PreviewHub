import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../../domain/models/asset_metrics.dart';
import '../../../domain/models/preview_asset.dart';
import '../../../domain/models/rive_asset.dart';
import '../../../domain/services/asset_metrics_service.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/rive_event_log.dart';
import '../../widgets/common/animation_playback_failure.dart';
import '../../widgets/common/copied_snack_bar.dart';
import '../../widgets/common/detail_row.dart';
import '../../widgets/common/preview_backdrop.dart';
import '../../widgets/rive/rive_events_button.dart';
import '../../widgets/rive/rive_inputs.dart';
import '../../widgets/rive/rive_player.dart';
import '../../widgets/rive/rive_transport.dart';

/// Everything known about one Rive animation, playing at full size on a choice
/// of background. Every input its state machine declares is laid out as a
/// control, so each state can be reached without writing code, and the events
/// it reports are counted on a button in the app bar that lists them.
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

  /// Raised by restart, which rebuilds the animation from its start.
  final ValueNotifier<int> _restartCount = ValueNotifier<int>(0);
  final ValueNotifier<bool> _failed = ValueNotifier<bool>(false);
  final ValueNotifier<rive.RiveWidgetController?> _controller =
      ValueNotifier<rive.RiveWidgetController?>(null);
  final ValueNotifier<PreviewBackdrop> _backdrop =
      ValueNotifier<PreviewBackdrop>(PreviewBackdrop.surface);

  /// Events the playing state machine has reported.
  final RiveEventLog _events = RiveEventLog();

  /// Disposes the notifiers; the Rive controller itself belongs to the player.
  @override
  void dispose() {
    _isPlaying.dispose();
    _restartCount.dispose();
    _failed.dispose();
    _controller.dispose();
    _backdrop.dispose();
    _events.dispose();
    super.dispose();
  }

  /// Plays from the start again, with every state and input back where the
  /// file begins. Focus is dropped first, since a number field being edited is
  /// about to be rebuilt, and so is the old controller, so no panel reads one
  /// that is being disposed.
  void _restart() {
    FocusScope.of(context).unfocus();
    _controller.value = null;
    _events.clear();
    _restartCount.value++;
    _isPlaying.value = true;
  }

  void _copy() => CopiedSnackBar.copy(context, widget.asset.locator);

  /// Keeps the loaded controller and listens to its events.
  void _onLoaded(rive.RiveWidgetController controller) {
    _controller.value = controller;
    _events.attach(controller);
  }

  /// Builds the page. It scrolls as one column rather than a lazy list, so
  /// the animation stays mounted while the panels below are scrolled to;
  /// a lazy list would dispose it, and its controller, out of sight.
  @override
  Widget build(BuildContext context) {
    final RiveAsset asset = widget.asset;

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: <Widget>[
          RiveEventsButton(log: _events),
          const SizedBox(width: 4),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _failed,
        builder: (BuildContext context, bool failed, Widget? child) {
          final ColorScheme scheme = Theme.of(context).colorScheme;
          final Color accent = failed ? scheme.error : scheme.primary;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      : ListenableBuilder(
                          listenable: Listenable.merge(<Listenable>[
                            _isPlaying,
                            _restartCount,
                          ]),
                          builder: (BuildContext context, Widget? child) =>
                              RivePlayer(
                                asset: asset,
                                isPlaying: _isPlaying.value,
                                restartCount: _restartCount.value,
                                onLoaded: _onLoaded,
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
                  ValueListenableBuilder<rive.RiveWidgetController?>(
                    valueListenable: _controller,
                    builder:
                        (
                          BuildContext context,
                          rive.RiveWidgetController? controller,
                          Widget? child,
                        ) => controller == null
                        ? const SizedBox.shrink()
                        : RiveInputs(
                            key: ObjectKey(controller),
                            controller: controller,
                          ),
                  ),
                ],
                const SizedBox(height: 18),
                DetailRow(
                  label: PreviewHubStrings.detailName,
                  value: asset.name,
                ),
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
            ),
          );
        },
      ),
    );
  }
}
