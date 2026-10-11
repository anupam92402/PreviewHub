import 'package:flutter/material.dart';

import '../../../domain/models/font_family_info.dart';
import '../../../util/preview_hub_strings.dart';
import '../../widgets/fonts/font_compare/font_compare_pair.dart';
import '../../widgets/fonts/font_compare/font_compare_picker.dart';
import '../../widgets/fonts/font_compare/font_compare_weight_notes.dart';
import '../../widgets/fonts/font_compare/font_compare_weight_picker.dart';
import '../../widgets/fonts/font_metrics_button.dart';

/// Two families set in the same words at the same weight and sizes, one above
/// the other, with their baselines drawn, so a swap from one to the other can
/// be judged before it is made. A family with no file at the chosen weight is
/// noted with the nearby weight drawn instead.
class FontCompareScreen extends StatefulWidget {
  /// Creates the comparison, offering every one of [families] on either side.
  const FontCompareScreen({required this.families, super.key});

  /// Families either side can be set in; at least two.
  final List<FontFamilyInfo> families;

  /// Sizes each pair is set at.
  static const List<double> sizes = <double>[12, 16, 20, 28, 32, 36, 40, 48];

  @override
  State<FontCompareScreen> createState() => _FontCompareScreenState();
}

class _FontCompareScreenState extends State<FontCompareScreen> {
  late final ValueNotifier<FontFamilyInfo> _first =
      ValueNotifier<FontFamilyInfo>(widget.families.first);
  late final ValueNotifier<FontFamilyInfo> _second =
      ValueNotifier<FontFamilyInfo>(widget.families[1]);

  /// Weight both families are set in.
  final ValueNotifier<FontWeight> _weight = ValueNotifier<FontWeight>(
    FontWeight.w400,
  );

  /// Words both families are set in; the standard sample while the field is
  /// empty.
  final ValueNotifier<String> _text = ValueNotifier<String>(
    PreviewHubStrings.fontSampleText,
  );

  /// Whether every line draws its baseline.
  final ValueNotifier<bool> _showMetrics = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    _weight.dispose();
    _text.dispose();
    _showMetrics.dispose();
    super.dispose();
  }

  /// Builds the page. Only the pairs listen to the choices, so typing in the
  /// field never rebuilds the field itself.
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(PreviewHubStrings.fontCompareTitle),
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: <Widget>[
        FontMetricsButton(showMetrics: _showMetrics),
        const SizedBox(width: 4),
      ],
    ),
    body: ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.paddingOf(context).bottom + 28,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: FontComparePicker(
                label: PreviewHubStrings.fontCompareFirst,
                families: widget.families,
                selection: _first,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FontComparePicker(
                label: PreviewHubStrings.fontCompareSecond,
                families: widget.families,
                selection: _second,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            FontCompareWeightPicker(selection: _weight),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                onChanged: (String value) => _text.value = value.isEmpty
                    ? PreviewHubStrings.fontSampleText
                    : value,
                decoration: const InputDecoration(
                  labelText: PreviewHubStrings.fontFieldText,
                  hintText: PreviewHubStrings.fontTextHint,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[
            _first,
            _second,
            _weight,
            _text,
            _showMetrics,
          ]),
          builder: (BuildContext context, Widget? child) => Column(
            children: <Widget>[
              FontCompareWeightNotes(
                families: <FontFamilyInfo>[_first.value, _second.value],
                weight: _weight.value.value,
              ),
              for (final double size in FontCompareScreen.sizes)
                FontComparePair(
                  size: size,
                  text: _text.value,
                  first: _first.value,
                  second: _second.value,
                  weight: _weight.value,
                  showMetrics: _showMetrics.value,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
