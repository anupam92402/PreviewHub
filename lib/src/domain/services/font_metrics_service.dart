import 'package:flutter/services.dart';

import '../models/font_family_info.dart';

/// Measures the font files behind a family.
///
/// A family has a handful of faces at most, so they are measured together when
/// one is opened rather than lazily per row. Results are cached for the life of
/// the service, so returning to a family costs nothing.
class FontMetricsService {
  /// Reads font files from [bundle], defaulting to the app's own bundle.
  FontMetricsService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<String, int> _sizes = <String, int>{};

  /// Size of the file behind [face], or null until it has been measured.
  int? sizeOf(FontFace face) => _sizes[face.asset];

  /// Total of every measured face in [family], or null if none are known yet.
  int? totalOf(FontFamilyInfo family) {
    final Iterable<int> known = family.faces
        .map((FontFace face) => _sizes[face.asset])
        .nonNulls;
    return known.isEmpty ? null : known.reduce((int a, int b) => a + b);
  }

  /// Measures every face of [family] that has not been measured yet.
  Future<void> measure(FontFamilyInfo family) async {
    await Future.wait(family.faces.map(_measureFace));
  }

  Future<void> _measureFace(FontFace face) async {
    if (face.asset.isEmpty || _sizes.containsKey(face.asset)) {
      return;
    }
    try {
      _sizes[face.asset] = (await _bundle.load(face.asset)).lengthInBytes;
    } on Object {
      // A face the bundle cannot produce simply stays unmeasured; the row
      // shows the type without a size rather than failing the screen.
    }
  }
}
