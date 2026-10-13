import 'package:flutter/material.dart';

import '../../../../util/preview_hub_strings.dart';
import '../../../viewmodels/font_sample_view_model.dart';

/// Takes the sample words, locked until there is a face to set them in.
class FontSampleField extends StatelessWidget {
  /// Creates the field feeding [viewModel], with [controller] holding the
  /// typed text.
  const FontSampleField({
    required this.viewModel,
    required this.controller,
    super.key,
  });

  /// Receives the typed text and says whether the field is unlocked.
  final FontSampleViewModel viewModel;

  /// Holds the text typed into the field.
  final TextEditingController controller;

  /// Builds the field. The clear button follows the controller, so the screen
  /// tracks no typed state, and clearing calls the view model directly because
  /// onChanged does not fire for a programmatic clear.
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool ready = viewModel.isComplete;

    return TextField(
      controller: controller,
      enabled: ready,
      maxLines: 2,
      minLines: 1,
      textInputAction: TextInputAction.newline,
      onChanged: viewModel.setText,
      decoration: InputDecoration(
        hintText: ready
            ? PreviewHubStrings.fontTextHint
            : PreviewHubStrings.fontSampleLocked(viewModel.missingChoices),
        hintStyle: TextStyle(
          color: ready ? null : scheme.error,
          fontSize: ready ? null : 13,
        ),
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        isDense: true,
        prefixIcon: Icon(
          ready ? Icons.edit_rounded : Icons.lock_outline_rounded,
          size: 18,
          color: ready ? scheme.primary : scheme.onSurfaceVariant,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (BuildContext context, TextEditingValue value, Widget? _) =>
              value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: PreviewHubStrings.clear,
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    controller.clear();
                    viewModel.setText('');
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
