import 'package:flutter/material.dart';

import '../../preview_hub_strings.dart';

/// The gallery's search field, shared by every collection screen.
/// Owns nothing but its text controller: the query is reported through
/// [onChanged] and the screen's view model decides what it means.
class PreviewSearchBar extends StatefulWidget {
  /// Creates a search bar prompting with [hintText].
  const PreviewSearchBar({
    required this.onChanged,
    this.hintText = 'Search',
    this.initialValue = '',
    this.resultCount,
    super.key,
  });

  /// Called on every keystroke, and when the field is cleared.
  final ValueChanged<String> onChanged;

  /// Placeholder shown while the field is empty.
  final String hintText;

  /// Text the field starts with.
  final String initialValue;

  /// Match count shown on the trailing side; hidden when null.
  final int? resultCount;

  @override
  State<PreviewSearchBar> createState() => _PreviewSearchBarState();
}

class _PreviewSearchBarState extends State<PreviewSearchBar> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  late final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _focusNode,
      builder: (BuildContext context, Widget? child) {
        return _Field(
          controller: _controller,
          focusNode: _focusNode,
          hintText: widget.hintText,
          resultCount: widget.resultCount,
          onChanged: widget.onChanged,
          onClear: _clear,
        );
      },
    );
  }
}

/// The field itself, rebuilt as focus moves.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.resultCount,
    required this.onChanged,
    required this.onClear,
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
                    : _Count(count: resultCount!);
              }
              return Row(
                children: <Widget>[
                  if (resultCount != null) _Count(count: resultCount!),
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

/// How many items currently match.
class _Count extends StatelessWidget {
  const _Count({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: scheme.primary,
        ),
      ),
    );
  }
}
