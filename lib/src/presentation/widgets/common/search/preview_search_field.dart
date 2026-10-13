import 'package:flutter/material.dart';

import '../../../../util/preview_hub_strings.dart';
import 'search_result_count.dart';

/// The rounded field drawn by a search bar, rebuilt as focus moves so its ring
/// and glyph follow [focusNode]. Shows the match count, and a clear button once
/// something is typed.
class PreviewSearchField extends StatelessWidget {
  /// Creates the field editing [controller].
  const PreviewSearchField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.resultCount,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  /// Text being edited.
  final TextEditingController controller;

  /// Focus the accent ring follows.
  final FocusNode focusNode;

  /// Placeholder shown while the field is empty.
  final String hintText;

  /// Match count shown on the trailing side; hidden when null.
  final int? resultCount;

  /// Called on every keystroke.
  final ValueChanged<String> onChanged;

  /// Called when the clear button is tapped.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool focused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: 48,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused
              ? scheme.primary.withValues(alpha: 0.55)
              : scheme.outlineVariant.withValues(alpha: 0.5),
          width: focused ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              Icons.search_rounded,
              size: 19,
              color: focused ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: hintText,
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (BuildContext context, TextEditingValue value, Widget? _) {
              if (value.text.isEmpty) {
                return resultCount == null
                    ? const SizedBox(width: 12)
                    : SearchResultCount(count: resultCount!);
              }
              return Row(
                children: <Widget>[
                  if (resultCount != null)
                    SearchResultCount(count: resultCount!),
                  IconButton(
                    onPressed: onClear,
                    iconSize: 17,
                    visualDensity: VisualDensity.compact,
                    tooltip: PreviewHubStrings.clear,
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const SizedBox(width: 4),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
