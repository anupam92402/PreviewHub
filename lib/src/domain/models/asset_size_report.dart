import 'package:flutter/foundation.dart';

/// The kinds of bundled file the size breakdown adds up.
enum AssetSizeCategory {
  /// SVG, PNG, JPEG, WebP and GIF files, every resolution variant included.
  /// One slice, as on the landing screen: a file's format says nothing
  /// reliable about whether it is used as an icon or an image.
  iconsAndImages('Icons & Images'),

  /// Font files from the font manifest.
  fonts('Fonts'),

  /// Lottie animations: bundled JSON that really is Bodymovin.
  lottie('Lottie'),

  /// Rive animations.
  rive('Rive'),

  /// Every other bundled file: audio, video, JSON that is not a Lottie, PDF
  /// and the rest. The same files the Other collection lists.
  other('Other');

  const AssetSizeCategory(this.label);

  /// Name shown in the legend.
  final String label;
}

/// One bundled asset and what it costs, variants included.
@immutable
class AssetSizeEntry {
  /// Records that [locator] takes [bytes] across [fileCount] files.
  const AssetSizeEntry({
    required this.locator,
    required this.category,
    required this.bytes,
    this.fileCount = 1,
    this.fontFamily,
  });

  /// Manifest key of the main asset.
  final String locator;

  /// Which slice of the breakdown it belongs to.
  final AssetSizeCategory category;

  /// Bytes of every file behind the asset: the main file and any 2.0x or 3.0x
  /// variant, since all of them ship.
  final int bytes;

  /// How many files that is.
  final int fileCount;

  /// For a font file, the font manifest key of the family it belongs to, so
  /// the fonts screen can open on it. Null for everything else, and for a font
  /// bundled as a plain asset outside the font manifest.
  final String? fontFamily;

  /// File name, for the list.
  String get name =>
      locator.split('/').where((String part) => part.isNotEmpty).lastOrNull ??
      locator;
}

/// What the bundled assets add up to, by category.
@immutable
class AssetSizeReport {
  /// Creates a report over [entries].
  AssetSizeReport({required List<AssetSizeEntry> entries})
    : entries = List<AssetSizeEntry>.unmodifiable(
        <AssetSizeEntry>[...entries]..sort(
          (AssetSizeEntry a, AssetSizeEntry b) => b.bytes.compareTo(a.bytes),
        ),
      );

  /// Every measured asset, heaviest first.
  final List<AssetSizeEntry> entries;

  /// Bytes of every measured asset.
  int get totalBytes =>
      entries.fold(0, (int total, AssetSizeEntry entry) => total + entry.bytes);

  /// Files behind every measured asset, variants included.
  int get totalFiles => entries.fold(
    0,
    (int total, AssetSizeEntry entry) => total + entry.fileCount,
  );

  /// Whether nothing was measured.
  bool get isEmpty => entries.isEmpty;

  /// Assets in [category], heaviest first.
  List<AssetSizeEntry> entriesOf(AssetSizeCategory category) => entries
      .where((AssetSizeEntry entry) => entry.category == category)
      .toList(growable: false);

  /// Bytes of every asset in [category].
  int bytesOf(AssetSizeCategory category) => entriesOf(
    category,
  ).fold(0, (int total, AssetSizeEntry entry) => total + entry.bytes);

  /// Share of the total [category] takes, from 0 to 1.
  double shareOf(AssetSizeCategory category) {
    final int total = totalBytes;
    return total == 0 ? 0 : bytesOf(category) / total;
  }

  /// Categories with anything in them, heaviest first.
  List<AssetSizeCategory> get presentCategories =>
      AssetSizeCategory.values
          .where((AssetSizeCategory category) => bytesOf(category) > 0)
          .toList()
        ..sort(
          (AssetSizeCategory a, AssetSizeCategory b) =>
              bytesOf(b).compareTo(bytesOf(a)),
        );
}
