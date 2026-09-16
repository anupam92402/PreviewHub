import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import '../../domain/models/preview_asset.dart';
import '../../domain/models/rive_asset.dart';
import '../../preview_hub_strings.dart';

/// Starts the Rive runtime once, on first use. Kept inside the package so a
/// tile renders without a bootstrap call in the host app's `main`.
class RiveRuntime {
  const RiveRuntime._();

  static Future<bool>? _initialisation;

  /// Completes with whether the native runtime came up. Reports failure rather
  /// than throwing, so a tile shows an error instead of waiting on a future
  /// that never completes.
  static Future<bool> ensureInitialised() => _initialisation ??= _start();

  static Future<bool> _start() async {
    try {
      return await rive.RiveNative.init();
    } on Object {
      return false;
    }
  }
}

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
        return RivePlayerFailure(accent: Theme.of(context).colorScheme.error);
      }
      return ValueListenableBuilder<rive.FileLoader?>(
        valueListenable: _loader,
        builder:
            (BuildContext context, rive.FileLoader? loader, Widget? child) =>
                loader == null
                ? const _Spinner()
                : rive.RiveWidgetBuilder(
                    fileLoader: loader,
                    onLoaded: _onLoaded,
                    onFailed: (Object error, StackTrace stack) => _onFailed(),
                    builder: (BuildContext context, rive.RiveState state) =>
                        switch (state) {
                          rive.RiveLoading() => const _Spinner(),
                          rive.RiveFailed() => _ReportedFailure(
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

/// Shows the failure panel and reports the failure once, after the frame.
/// [rive.RiveWidgetBuilder] does not call `onFailed` for its failed state, and
/// builders run during layout.
class _ReportedFailure extends StatelessWidget {
  const _ReportedFailure({required this.onFailed});

  final VoidCallback onFailed;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onFailed());
    return RivePlayerFailure(accent: Theme.of(context).colorScheme.error);
  }
}

/// Shown while the runtime is starting or the file is loading.
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

/// Stands in for an animation that could not be played.
class RivePlayerFailure extends StatelessWidget {
  /// Creates a failure panel tinted with [accent].
  const RivePlayerFailure({
    required this.accent,
    this.iconSize = 28,
    super.key,
  });

  /// Colour of the glyph and caption.
  final Color accent;

  /// Largest the glyph is allowed to be.
  final double iconSize;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final double glyph = iconSize.clamp(
        12,
        constraints.biggest.shortestSide * 0.5,
      );
      final bool showCaption = constraints.maxHeight >= glyph * 2.4;

      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.motion_photos_off_outlined, size: glyph, color: accent),
          if (showCaption) ...<Widget>[
            SizedBox(height: glyph * 0.18),
            Flexible(
              child: Text(
                PreviewHubStrings.riveFailed,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: glyph * 0.36, color: accent),
              ),
            ),
          ],
        ],
      );
    },
  );
}
