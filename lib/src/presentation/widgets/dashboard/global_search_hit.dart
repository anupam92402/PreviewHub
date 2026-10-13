import 'package:flutter/material.dart';

/// One hit in the landing screen's search results.
class GlobalSearchHit extends StatelessWidget {
  /// Creates a hit reading [title] over [subtitle].
  const GlobalSearchHit({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.fontFamily,
    super.key,
  });

  /// Name of the entry found.
  final String title;

  /// Where or what the entry is.
  final String subtitle;

  /// Opens the entry.
  final VoidCallback onTap;

  /// Family to set the title in, for a font hit.
  final String? fontFamily;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: fontFamily == null ? null : TextStyle(fontFamily: fontFamily),
    ),
    subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    onTap: onTap,
  );
}
