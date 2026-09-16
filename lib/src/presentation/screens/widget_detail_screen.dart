import 'package:flutter/material.dart';

import '../../domain/models/widget_preview.dart';
import '../widgets/widget_case_card.dart';

/// Every labelled rendering of one component, stacked down the page.
/// Each case is built lazily by the list, so opening an entry with twenty
/// renderings costs only the ones actually on screen.
class WidgetDetailScreen extends StatelessWidget {
  /// Creates the detail screen for [preview].
  const WidgetDetailScreen({required this.preview, super.key});

  /// Entry being inspected.
  final WidgetPreview preview;

  @override
  Widget build(BuildContext context) {
    final List<WidgetPreviewCase> cases = preview.usableCases;

    return Scaffold(
      appBar: AppBar(
        title: Text(preview.title),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        itemCount: cases.length,
        itemBuilder: (BuildContext context, int index) =>
            WidgetCaseCard(item: cases[index]),
      ),
    );
  }
}
