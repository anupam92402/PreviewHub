import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/asset_size_report.dart';
import '../models/preview_asset.dart';
import 'lottie_document.dart';

/// Adds up what the bundled images, icons, fonts, Lottie and Rive files weigh,
/// and everything else the app bundles as Other. Every asset in the manifest is
/// classified and every file behind it is loaded once to read its length,
/// resolution variants included, since a 2.0x and a 3.0x copy ship alongside
/// the 1x one. Remote assets are not counted: they do not add to the app. The
/// icon fonts Flutter injects are left out too, because in a debug build they
/// are measured before tree shaking and would dwarf everything the app itself
/// ships.
class AssetSizeService {
  /// Reads files from [bundle], defaulting to the app's own bundle.
  AssetSizeService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Families left out of the breakdown; see the class comment.
  static const Set<String> _iconFontFamilies = <String>{
    'MaterialIcons',
    'CupertinoIcons',
  };

  /// Font file extensions, for fonts bundled as plain assets.
  static const Set<String> _fontExtensions = <String>{'ttf', 'otf', 'ttc'};

  /// Measures every bundled asset that falls into a category.
  Future<AssetSizeReport> measure() async {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      _bundle,
    );
    final (Map<String, String> fontFiles, Set<String> iconFontFiles) =
        await _fontFiles();
    final List<AssetSizeEntry> entries = <AssetSizeEntry>[];

    for (final String key in manifest.listAssets()) {
      if (iconFontFiles.contains(key)) {
        continue;
      }
      final Set<String> files = <String>{
        key,
        ...?manifest
            .getAssetVariants(key)
            ?.map((AssetMetadata variant) => variant.key),
      };
      final AssetSizeEntry? entry = await _measure(key, files, fontFiles);
      if (entry != null) {
        entries.add(entry);
      }
    }
    return AssetSizeReport(entries: entries);
  }

  /// Classifies and measures the asset at [key] across [files]. Returns null
  /// only for a file that cannot be read.
  Future<AssetSizeEntry?> _measure(
    String key,
    Set<String> files,
    Map<String, String> fontFiles,
  ) async {
    final String extension = _extensionOf(key);

    /// JSON stays undecided until it has been read: a Lottie animation or
    /// anything else. Every other file is decided by its name alone.
    AssetSizeCategory? category = switch (AssetType.fromLocator(key)) {
      AssetType() => AssetSizeCategory.iconsAndImages,
      null =>
        extension == 'riv'
            ? AssetSizeCategory.rive
            : fontFiles.containsKey(key) || _fontExtensions.contains(extension)
            ? AssetSizeCategory.fonts
            : extension == 'json'
            ? null
            : AssetSizeCategory.other,
    };

    int bytes = 0;
    int counted = 0;
    for (final String file in files) {
      try {
        final ByteData data = await _bundle.load(file);
        if (category == null) {
          /// Only JSON gets here, and only its main file: a Lottie has no
          /// resolution variants.
          final String text = utf8.decode(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
            allowMalformed: true,
          );
          category = LottieDocument.describesAnimation(text)
              ? AssetSizeCategory.lottie
              : AssetSizeCategory.other;
        }
        bytes += data.lengthInBytes;
        counted++;
      } on Object catch (_) {
        continue;
      }
    }
    if (category == null || counted == 0) {
      return null;
    }
    return AssetSizeEntry(
      locator: key,
      category: category,
      bytes: bytes,
      fileCount: counted,
      fontFamily: category == AssetSizeCategory.fonts ? fontFiles[key] : null,
    );
  }

  /// Font files the font manifest names: the app's own, each mapped to its
  /// family's manifest key, and the icon fonts left out of the breakdown. An
  /// app without a font manifest has neither.
  Future<(Map<String, String>, Set<String>)> _fontFiles() async {
    final Map<String, String> own = <String, String>{};
    final Set<String> icons = <String>{};
    try {
      final List<dynamic> manifest =
          jsonDecode(await _bundle.loadString('FontManifest.json'))
              as List<dynamic>;
      for (final Map<String, dynamic> family
          in manifest.cast<Map<String, dynamic>>()) {
        final String key = family['family'] as String? ?? '';
        final bool isIconFont = _iconFontFamilies.contains(key.split('/').last);
        for (final Map<String, dynamic> font
            in (family['fonts'] as List<dynamic>? ?? <dynamic>[])
                .cast<Map<String, dynamic>>()) {
          final String? asset = font['asset'] as String?;
          if (asset == null) {
            continue;
          }
          if (isIconFont) {
            icons.add(asset);
          } else {
            own[asset] = key;
          }
        }
      }
    } on Object catch (_) {}
    return (own, icons);
  }

  static String _extensionOf(String key) {
    final String path = Uri.tryParse(key)?.path ?? key;
    final int dot = path.lastIndexOf('.');
    return dot == -1 ? '' : path.substring(dot + 1).toLowerCase();
  }
}
