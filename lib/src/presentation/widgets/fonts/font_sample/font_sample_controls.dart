import 'package:flutter/material.dart';

import '../../../../domain/models/font_family_info.dart';
import '../../../../util/preview_hub_strings.dart';
import '../../../viewmodels/font_sample_view_model.dart';
import '../../common/preview_filter_bar.dart';
import 'font_sample_field.dart';

/// The family, weight and size chips and the sample field, in a panel under
/// the preview.
class FontSampleControls extends StatelessWidget {
  /// Creates the controls driving [viewModel], with [controller] holding the
  /// typed text.
  const FontSampleControls({
    required this.viewModel,
    required this.controller,
    super.key,
  });

  /// Source and target of the choices.
  final FontSampleViewModel viewModel;

  /// Holds the text typed into the sample field.
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      padding: EdgeInsets.only(
        top: 14,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PreviewFilterBar(
            groups: <PreviewFilterGroup>[
              PreviewFilterGroup(
                label: PreviewHubStrings.fontFieldFamily,
                filters: <PreviewFilter>[
                  for (final FontFamilyInfo family in viewModel.families)
                    PreviewFilter(
                      label: family.name,
                      selected: viewModel.family == family,
                      onSelected: () => viewModel.selectFamily(family),
                    ),
                ],
              ),
              PreviewFilterGroup(
                label: PreviewHubStrings.fontFieldWeight,
                filters: <PreviewFilter>[
                  for (final FontFace face in viewModel.availableFaces)
                    PreviewFilter(
                      label: '${face.weight}',
                      selected: viewModel.face == face,
                      onSelected: () => viewModel.selectFace(face),
                    ),
                ],
              ),
              PreviewFilterGroup(
                label: PreviewHubStrings.fontFieldSize,
                filters: <PreviewFilter>[
                  for (final double size in FontSampleViewModel.sizeChoices)
                    PreviewFilter(
                      label: '${size.toInt()}',
                      selected: viewModel.size == size,
                      onSelected: () => viewModel.selectSize(size),
                    ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: FontSampleField(
              viewModel: viewModel,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
