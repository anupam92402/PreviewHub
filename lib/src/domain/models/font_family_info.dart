import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// One face of a family: a single file at one weight and style.
@immutable
class FontFace {
  /// Creates a face loaded from [asset].
  const FontFace({
    required this.asset,
    this.weight = 400,
    this.isItalic = false,
  });

  /// Asset key of the font file.
  final String asset;

  /// Numeric weight, defaulting to regular when the manifest omits one.
  final int weight;

  /// Whether the file is an italic cut.
  final bool isItalic;

  /// Weight as Flutter renders it. [FontWeight.values] runs w100 to w900 in
  /// order, so the hundreds digit picks the entry; anything unexpected falls
  /// back to regular.
  FontWeight get fontWeight {
    final int index = (weight ~/ 100) - 1;
    if (index < 0 || index >= FontWeight.values.length) {
      return FontWeight.w400;
    }
    return FontWeight.values[index];
  }

  /// Style as Flutter renders it.
  FontStyle get fontStyle => isItalic ? FontStyle.italic : FontStyle.normal;

  /// `Medium 500`, or `Medium 500 Italic` for an italic cut.
  String get label {
    final String name = switch (weight) {
      100 => 'Thin',
      200 => 'Extra light',
      300 => 'Light',
      400 => 'Regular',
      500 => 'Medium',
      600 => 'Semi bold',
      700 => 'Bold',
      800 => 'Extra bold',
      900 => 'Black',
      _ => 'Weight',
    };
    return isItalic ? '$name $weight Italic' : '$name $weight';
  }
}

/// A family discovered in the font manifest, with every face it ships.
@immutable
class FontFamilyInfo {
  /// Creates a family described by [manifestKey].
  const FontFamilyInfo({
    required this.manifestKey,
    required this.name,
    required this.faces,
  });

  /// Builds a family from its manifest key and faces. A dependency's family
  /// arrives as `packages/<package>/<family>`; [name] keeps only the family,
  /// while [manifestKey] stays as Flutter exposes it, which is the string a
  /// [TextStyle] needs.
  factory FontFamilyInfo.fromManifest({
    required String manifestKey,
    required List<FontFace> faces,
  }) => FontFamilyInfo(
    manifestKey: manifestKey,
    name: manifestKey.split('/').last,
    faces: faces,
  );

  /// Key exactly as Flutter exposes it, and what `fontFamily` expects.
  final String manifestKey;

  /// Family name on its own, without any package prefix.
  final String name;

  /// Every face, lightest first.
  final List<FontFace> faces;

  /// Standard weights the family ships no upright file for. A style asking for
  /// one of these gets the nearest face Flutter can find, and a bold request
  /// with no bold face is thickened artificially, which never matches the
  /// design. Empty for a family that ships all nine.
  List<int> get missingWeights {
    final Set<int> shipped = faces
        .where((FontFace face) => !face.isItalic)
        .map((FontFace face) => face.weight)
        .toSet();
    return <int>[
      for (int weight = 100; weight <= 900; weight += 100)
        if (!shipped.contains(weight)) weight,
    ];
  }

  /// Weight of the upright face a style asking for [weight] is drawn with,
  /// following the CSS font matching order the engine approximates: 400 tries
  /// 500 first and 500 tries 400, both then going lighter before heavier;
  /// below 400 goes lighter first, above 500 goes heavier first. Null for a
  /// family with no upright face.
  int? nearestWeight(int weight) {
    final List<int> shipped =
        faces
            .where((FontFace face) => !face.isItalic)
            .map((FontFace face) => face.weight)
            .toSet()
            .toList()
          ..sort();
    if (shipped.isEmpty) {
      return null;
    }
    if (shipped.contains(weight)) {
      return weight;
    }
    final List<int> lighter = shipped.where((int w) => w < weight).toList()
      ..sort((int a, int b) => b.compareTo(a));
    final List<int> heavier = shipped.where((int w) => w > weight).toList();
    if (weight == 400 && shipped.contains(500)) {
      return 500;
    }
    if (weight == 500 && shipped.contains(400)) {
      return 400;
    }
    final List<int> order = weight > 500
        ? <int>[...heavier, ...lighter]
        : <int>[...lighter, ...heavier];
    return order.first;
  }

  /// The face closest to regular, used for the family's own sample line.
  FontFace get representativeFace => faces.firstWhere(
    (FontFace face) => face.weight == 400 && !face.isItalic,
    orElse: () => faces.first,
  );
}
