import 'package:flutter/material.dart';

/// A small centred progress ring, for a box whose content is still loading.
class SmallSpinner extends StatelessWidget {
  /// Creates a ring [size] logical pixels across.
  const SmallSpinner({this.size = 18, super.key});

  /// Width and height of the ring.
  final double size;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox.square(
      dimension: size,
      child: const CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}
