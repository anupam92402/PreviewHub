import 'package:flutter/foundation.dart';

import '../../domain/models/font_family_info.dart';
import '../../preview_hub_strings.dart';

/// Drives the sheet where a consumer sets their own text in a chosen face.
///
/// The three choices gate the text field: there is nothing to preview text in
/// until a family, a weight and a size have all been picked.
class FontSampleViewModel extends ChangeNotifier {
  /// Offers a choice between [families].
  FontSampleViewModel({required this.families});

  /// Sizes the sheet offers, in points.
  static const List<double> sizeChoices = <double>[
    8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 40, 48,
  ];

  /// Families the sheet can set text in.
  final List<FontFamilyInfo> families;

  FontFamilyInfo? _family;
  FontFace? _face;
  double? _size;
  String _text = '';

  /// Family chosen so far, or null.
  FontFamilyInfo? get family => _family;

  /// Face chosen so far, or null.
  FontFace? get face => _face;

  /// Size chosen so far, or null.
  double? get size => _size;

  /// Text typed so far.
  String get text => _text;

  /// Faces the chosen family offers; empty until a family is chosen.
  List<FontFace> get availableFaces => _family?.faces ?? const <FontFace>[];

  /// Whether every choice has been made and text may be written.
  bool get isComplete => _family != null && _face != null && _size != null;

  /// What is still missing, in the order the fields appear.
  List<String> get missingChoices => <String>[
    if (_family == null) PreviewHubStrings.fontFieldFamily,
    if (_face == null) PreviewHubStrings.fontFieldWeight,
    if (_size == null) PreviewHubStrings.fontFieldSize,
  ];

  /// Whether there is a finished sample to show.
  bool get hasPreview => isComplete && _text.trim().isNotEmpty;

  /// Chooses [family], dropping any weight that belonged to the last one.
  void selectFamily(FontFamilyInfo? family) {
    if (_family == family) {
      return;
    }
    _family = family;
    // A face belongs to one family, so the old choice cannot carry over.
    _face = null;
    notifyListeners();
  }

  /// Chooses [face].
  void selectFace(FontFace? face) {
    if (_face == face) {
      return;
    }
    _face = face;
    notifyListeners();
  }

  /// Chooses [size].
  void selectSize(double? size) {
    if (_size == size) {
      return;
    }
    _size = size;
    notifyListeners();
  }

  /// Records the text being previewed.
  void setText(String value) {
    if (_text == value) {
      return;
    }
    _text = value;
    notifyListeners();
  }
}
