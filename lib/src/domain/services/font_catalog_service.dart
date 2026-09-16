import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/font_family_info.dart';

/// Discovers the font families bundled with the app.
///
/// Families come from `FontManifest.json`, which Flutter writes from the
/// `fonts:` section of every pubspec in the build — the app's own and its
/// dependencies' — so a consumer never registers a family by hand.
class FontCatalogService {
  /// Reads the manifest from [bundle], defaulting to the app's own bundle.
  FontCatalogService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Families Flutter injects that carry icons rather than text.
  ///
  /// MaterialIcons arrives with `uses-material-design: true` and looks its
  /// icons up by ligature, so it has lowercase letters and digits but no
  /// uppercase — a sample line renders as blank ligature components with only
  /// the capitals falling back to a real font. Neither family belongs to the
  /// consumer's design system, so neither is listed.
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
            // Upright before italic at the same weight.
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
