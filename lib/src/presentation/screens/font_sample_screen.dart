import 'package:flutter/material.dart';

import '../../domain/models/font_family_info.dart';
import '../../preview_hub_strings.dart';
import '../viewmodels/font_sample_view_model.dart';
import '../widgets/preview_filter_bar.dart';

/// A type tester: words the consumer writes, set in a face they choose.
///
/// The preview takes the room, because it is the point; the controls sit
/// beneath it and stay out of the way.
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
          Expanded(child: _Stage(viewModel: _viewModel)),
          _Controls(viewModel: _viewModel, controller: _controller),
        ],
      ),
    ),
  );
}

/// The preview itself: the sample, the placeholder, or what is still missing.
class _Stage extends StatelessWidget {
  const _Stage({required this.viewModel});

  final FontSampleViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: switch ((viewModel.isComplete, viewModel.hasPreview)) {
        (false, _) => _Checklist(viewModel: viewModel),
        (true, false) => const _Placeholder(),
        (true, true) => _Sample(viewModel: viewModel),
      },
    );
  }
}

/// What is chosen and what is not, before the field opens.
class _Checklist extends StatelessWidget {
  const _Checklist({required this.viewModel});

  final FontSampleViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<String> missing = viewModel.missingChoices;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            PreviewHubStrings.fontSampleChecklist,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          for (final String field in <String>[
            PreviewHubStrings.fontFieldFamily,
            PreviewHubStrings.fontFieldWeight,
            PreviewHubStrings.fontFieldSize,
          ])
            _ChecklistRow(label: field, done: !missing.contains(field)),
        ],
      ),
    );
  }
}

/// One line of the checklist.
class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color tone = done ? scheme.primary : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: tone,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}

/// Everything chosen, nothing typed yet.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.keyboard_alt_outlined,
            size: 30,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            PreviewHubStrings.fontSamplePlaceholder,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The finished sample, with a caption naming what it is set in.
class _Sample extends StatelessWidget {
  const _Sample({required this.viewModel});

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

/// The chips and the field, in a panel under the preview.
class _Controls extends StatelessWidget {
  const _Controls({required this.viewModel, required this.controller});

  final FontSampleViewModel viewModel;
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
            child: _SampleField(viewModel: viewModel, controller: controller),
          ),
        ],
      ),
    );
  }
}

/// Takes the words, once there is a face to set them in.
class _SampleField extends StatelessWidget {
  const _SampleField({required this.viewModel, required this.controller});

  final FontSampleViewModel viewModel;
  final TextEditingController controller;

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
            // Says what is still missing rather than only grey­ing the field out.
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
        // Driven by the controller, so the button appears and disappears
        // without the screen having to track whether anything is typed.
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
                    // The field's own onChanged does not fire for a
                    // programmatic clear, so the preview is told directly.
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
