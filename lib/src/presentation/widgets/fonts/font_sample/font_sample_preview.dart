import 'package:flutter/material.dart';

import '../../../../domain/models/font_family_info.dart';
import '../../../../util/preview_hub_strings.dart';
import '../../../viewmodels/font_sample_view_model.dart';

/// The typed text set in the chosen face, with a caption naming the family,
/// weight and size.
class FontSamplePreview extends StatelessWidget {
  /// Creates the preview; [viewModel] must have every choice made.
  const FontSamplePreview({required this.viewModel, super.key});

  /// Source of the choices and the typed text.
  final FontSampleViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final FontFamilyInfo family = viewModel.family!;
    final FontFace face = viewModel.face!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              viewModel.text,
              style: TextStyle(
                fontFamily: family.manifestKey,
                fontSize: viewModel.size,
                fontWeight: face.fontWeight,
                fontStyle: face.fontStyle,
                height: 1.25,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          PreviewHubStrings.fontSampleCaption(
            family.name,
            face.label,
            viewModel.size!,
          ),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }
}
