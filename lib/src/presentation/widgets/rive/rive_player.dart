import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../../domain/models/preview_asset.dart';
import '../../../domain/models/rive_asset.dart';
import '../../../domain/services/rive_runtime.dart';
import '../../../util/preview_hub_strings.dart';
import '../common/animation_playback_failure.dart';
import '../common/small_spinner.dart';
import 'rive_reported_failure.dart';

/// Plays [asset], with the play state under the caller's control.
class RivePlayer extends StatefulWidget {
  /// Creates a player for [asset].
  const RivePlayer({
    required this.asset,
    required this.isPlaying,
    this.onLoaded,
    this.onFailed,
    this.fit = rive.Fit.contain,
    super.key,
  });

  /// Animation to play.
  final RiveAsset asset;

  /// Whether the animation should be running.
  final bool isPlaying;

  /// Called once the file has loaded, with what it describes.
  final ValueChanged<rive.RiveWidgetController>? onLoaded;

  /// Called when the file cannot be played at all.
  final VoidCallback? onFailed;

  /// How the animation fills its box.
  final rive.Fit fit;

  @override
  State<RivePlayer> createState() => _RivePlayerState();
}

class _RivePlayerState extends State<RivePlayer> {
  /// Built once the runtime is up, then reused. Held here rather than built in
  /// `build`, which would refetch the file on every rebuild.
  final ValueNotifier<rive.FileLoader?> _loader =
      ValueNotifier<rive.FileLoader?>(null);
  final ValueNotifier<bool> _failed = ValueNotifier<bool>(false);
  rive.RiveWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(RivePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      _applyPlayState();
    }
    if (widget.asset != oldWidget.asset) {
      _loader.value?.dispose();
      _loader.value = null;
      _failed.value = false;
      _prepare();
    }
  }

  @override
  void dispose() {
    _loader.value?.dispose();
    _loader.dispose();
    _failed.dispose();
    super.dispose();
  }

  /// Brings the runtime up, then opens the file it needs. Uses
  /// `Factory.flutter` so the animation draws through Flutter's own renderer
  /// and works wherever Flutter does.
  Future<void> _prepare() async {
    try {
      final bool ready = await RiveRuntime.ensureInitialised();
      if (!mounted) {
        return;
      }
      if (!ready) {
        _failed.value = true;
        return;
      }
      _loader.value = widget.asset.source == AssetSource.bundled
          ? rive.FileLoader.fromAsset(
              widget.asset.locator,
              riveFactory: rive.Factory.flutter,
            )
          : rive.FileLoader.fromUrl(
              widget.asset.locator,
              riveFactory: rive.Factory.flutter,
            );
    } on Object {
      if (mounted) {
        _failed.value = true;
      }
    }
  }

  /// Starts or holds the animation, without rewinding when it is held.
  void _applyPlayState() => _controller?.active = widget.isPlaying;

  void _onLoaded(rive.RiveLoaded state) {
    _controller = state.controller;
    _applyPlayState();
    widget.onLoaded?.call(state.controller);
  }

  void _onFailed() {
    _failed.value = true;
    widget.onFailed?.call();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: _failed,
    builder: (BuildContext context, bool failed, Widget? child) {
      if (failed) {
        return AnimationPlaybackFailure(
          message: PreviewHubStrings.riveFailed,
          accent: Theme.of(context).colorScheme.error,
        );
      }
      return ValueListenableBuilder<rive.FileLoader?>(
        valueListenable: _loader,
        builder:
            (BuildContext context, rive.FileLoader? loader, Widget? child) =>
                loader == null
                ? const SmallSpinner()
                : rive.RiveWidgetBuilder(
                    fileLoader: loader,
                    onLoaded: _onLoaded,
                    onFailed: (Object error, StackTrace stack) => _onFailed(),
                    builder: (BuildContext context, rive.RiveState state) =>
                        switch (state) {
                          rive.RiveLoading() => const SmallSpinner(),
                          rive.RiveFailed() => RiveReportedFailure(
                            onFailed: _onFailed,
                          ),
                          rive.RiveLoaded() => rive.RiveWidget(
                            controller: state.controller,
                            fit: widget.fit,
                          ),
                        },
                  ),
      );
    },
  );
}
