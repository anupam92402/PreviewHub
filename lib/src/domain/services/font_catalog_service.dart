import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/font_family_info.dart';

/// Discovers the font families bundled with the app. Families come from
/// `FontManifest.json`, which Flutter writes from the `fonts:` section of every
/// pubspec in the build, so no family is registered by hand.
class FontCatalogService {
  /// Reads the manifest from [bundle], defaulting to the app's own bundle.
  FontCatalogService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Families Flutter injects that carry icons rather than text. They resolve
  /// glyphs by ligature, so a sample line renders mostly blank, and neither
  /// belongs to the consumer's design system.
  static const Set<String> _iconFamilies = <String>{
    'MaterialIcons',
    'CupertinoIcons',
  };

  /// Every family, app fonts first, each with its faces lightest first.
  Future<List<FontFamilyInfo>> load() async {
    final List<dynamic> manifest =
        jsonDecode(await _bundle.loadString('FontManifest.json'))
            as List<dynamic>;

    final List<FontFamilyInfo> families = manifest
        .cast<Map<String, dynamic>>()
        .map(_familyFrom)
        .where((FontFamilyInfo family) => !_iconFamilies.contains(family.name))
        .toList();

    families.sort(
      (FontFamilyInfo a, FontFamilyInfo b) => a.name.compareTo(b.name),
    );
    return families;
  }

  /// Faces are sorted lightest first, upright before italic at equal weight.
  FontFamilyInfo _familyFrom(Map<String, dynamic> entry) {
    final List<FontFace> faces =
        (entry['fonts'] as List<dynamic>? ?? <dynamic>[])
            .cast<Map<String, dynamic>>()
            .map(_faceFrom)
            .toList()
          ..sort((FontFace a, FontFace b) {
            final int byWeight = a.weight.compareTo(b.weight);
            if (byWeight != 0) {
              return byWeight;
            }
            return a.isItalic == b.isItalic ? 0 : (a.isItalic ? 1 : -1);
          });

    return FontFamilyInfo.fromManifest(
      manifestKey: entry['family'] as String,
      faces: faces,
    );
  }

  /// A manifest face omits `weight` and `style` when it is regular upright.
  FontFace _faceFrom(Map<String, dynamic> font) => FontFace(
    asset: font['asset'] as String? ?? '',
    weight: font['weight'] as int? ?? 400,
    isItalic: font['style'] == 'italic',
  );
}
