import 'package:flutter/material.dart';

import '../../../domain/models/font_family_info.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/font_sample_view_model.dart';
import '../../widgets/fonts/font_sample/font_sample_controls.dart';
import '../../widgets/fonts/font_sample/font_sample_stage.dart';

/// A type tester: words the consumer writes, set in a face they choose. The
/// preview takes the room; the controls sit beneath it.
class FontSampleScreen extends StatefulWidget {
  /// Creates the screen over [families].
  const FontSampleScreen({required this.families, super.key});

  /// Families the screen can set text in.
  final List<FontFamilyInfo> families;

  @override
  State<FontSampleScreen> createState() => _FontSampleScreenState();
}

class _FontSampleScreenState extends State<FontSampleScreen> {
  late final FontSampleViewModel _viewModel = FontSampleViewModel(
    families: widget.families,
  );
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _viewModel.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(PreviewHubStrings.fontSampleTitle),
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    body: ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) => Column(
        children: <Widget>[
          Expanded(child: FontSampleStage(viewModel: _viewModel)),
          FontSampleControls(viewModel: _viewModel, controller: _controller),
        ],
      ),
    ),
  );
}
