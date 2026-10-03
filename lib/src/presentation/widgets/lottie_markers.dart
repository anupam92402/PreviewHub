import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// The named markers an animation carries, as centred chips that each play
/// their span when tapped. Shows nothing for a file without markers.
class LottieMarkers extends StatelessWidget {
  /// Creates the marker chips for [composition].
  const LottieMarkers({
    required this.composition,
    required this.onTap,
    super.key,
  });

  /// Loaded animation, or null while it is still loading.
  final ValueListenable<LottieComposition?> composition;

  /// Called with the marker tapped.
  final ValueChanged<Marker> onTap;

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<LottieComposition?>(
    valueListenable: composition,
    builder: (BuildContext context, LottieComposition? loaded, Widget? child) {
      final List<Marker> markers = loaded?.markers ?? const <Marker>[];
      if (markers.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: <Widget>[
            for (final Marker marker in markers)
              ActionChip(
                avatar: const Icon(Icons.flag_outlined, size: 16),
                label: Text(marker.name.trim().isEmpty ? '—' : marker.name),
                onPressed: () => onTap(marker),
              ),
          ],
        ),
      );
    },
  );
}
