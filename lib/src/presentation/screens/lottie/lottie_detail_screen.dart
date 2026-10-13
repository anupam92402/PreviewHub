import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../domain/models/asset_metrics.dart';
import '../../../domain/models/lottie_asset.dart';
import '../../../domain/models/preview_asset.dart';
import '../../../domain/services/asset_metrics_service.dart';
import '../../../util/preview_hub_strings.dart';
import '../../widgets/common/animation_playback_failure.dart';
import '../../widgets/common/copied_snack_bar.dart';
import '../../widgets/common/detail_row.dart';
import '../../widgets/common/preview_backdrop.dart';
import '../../widgets/lottie/lottie_markers.dart';
import '../../widgets/lottie/lottie_player.dart';
import '../../widgets/lottie/lottie_scrubber.dart';
import '../../widgets/lottie/lottie_speed_picker.dart';
import '../../widgets/lottie/lottie_transport.dart';

/// Everything known about one animation, playing at full size, with the
/// controls a motion review needs: speed, a frame scrubber, loop or once, a
/// choice of background, and the named markers the file carries.
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
  /// Owned here rather than by the player, because scrubbing and playing a
  /// marker both move the animation rather than merely resuming it.
  late final AnimationController _controller = AnimationController(vsync: this)
    ..addStatusListener(_onStatus);
  final ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _failed = ValueNotifier<bool>(false);
  final ValueNotifier<LottieComposition?> _composition =
      ValueNotifier<LottieComposition?>(null);
  final ValueNotifier<double> _speed = ValueNotifier<double>(1);
  final ValueNotifier<bool> _loop = ValueNotifier<bool>(true);
  final ValueNotifier<PreviewBackdrop> _backdrop =
      ValueNotifier<PreviewBackdrop>(PreviewBackdrop.surface);

  @override
  void dispose() {
    _controller.dispose();
    _isPlaying.dispose();
    _failed.dispose();
    _composition.dispose();
    _speed.dispose();
    _loop.dispose();
    _backdrop.dispose();
    super.dispose();
  }

  /// Shows the play button again once a single run ends.
  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_loop.value) {
      _isPlaying.value = false;
    }
  }

  /// Holds the animation while the scrubber is dragged.
  void _scrubStart(double _) => _isPlaying.value = false;

  void _scrub(double value) => _controller.value = value;

  /// Plays [marker]'s span once. The player stops the controller when told to
  /// pause, so the span starts after that has happened, a frame later.
  void _playMarker(Marker marker) {
    _isPlaying.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final LottieComposition? composition = _composition.value;
      if (!mounted || composition == null) {
        return;
      }
      final double span = (marker.end - marker.start).clamp(0, 1);
      _controller.value = marker.start.clamp(0, 1);
      _controller.animateTo(
        marker.end.clamp(0, 1),
        duration: composition.duration * (span / _speed.value),
      );
    });
  }

  void _copy() => CopiedSnackBar.copy(context, widget.asset.locator);

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
                        message: PreviewHubStrings.lottieFailed,
                        accent: accent,
                        iconSize: 44,
                      )
                    : ListenableBuilder(
                        listenable: Listenable.merge(<Listenable>[
                          _isPlaying,
                          _speed,
                          _loop,
                        ]),
                        builder: (BuildContext context, Widget? child) =>
                            LottiePlayer(
                              asset: asset,
                              isPlaying: _isPlaying.value,
                              speed: _speed.value,
                              loop: _loop.value,
                              controller: _controller,
                              onLoaded: (LottieComposition c) =>
                                  _composition.value = c,
                              onFailed: () => _failed.value = true,
                            ),
                      ),
              ),
              if (!failed) ...<Widget>[
                const SizedBox(height: 10),
                LottieScrubber(
                  controller: _controller,
                  composition: _composition,
                  onChangeStart: _scrubStart,
                  onChanged: _scrub,
                ),
                LottieTransport(isPlaying: _isPlaying, loop: _loop),
                const SizedBox(height: 18),
                ListenableBuilder(
                  listenable: Listenable.merge(<Listenable>[_backdrop, _speed]),
                  builder: (BuildContext context, Widget? child) => Wrap(
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
                      LottieSpeedPicker(
                        value: _speed.value,
                        onChanged: (double value) => _speed.value = value,
                      ),
                    ],
                  ),
                ),
                LottieMarkers(composition: _composition, onTap: _playMarker),
              ],
              const SizedBox(height: 18),
              DetailRow(label: PreviewHubStrings.detailName, value: asset.name),
              DetailRow(
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
                        DetailRow(
                          label: PreviewHubStrings.lottieDetailDuration,
                          value: composition == null
                              ? PreviewHubStrings.assetUnavailable
                              : PreviewHubStrings.lottieDuration(
                                  composition.duration,
                                ),
                        ),
                        if (composition != null)
                          DetailRow(
                            label: PreviewHubStrings.detailDimensions,
                            value: PreviewHubStrings.dimensions(
                              composition.bounds.width,
                              composition.bounds.height,
                            ),
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
