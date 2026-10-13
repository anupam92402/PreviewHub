import 'package:flutter/material.dart';

import '../../../util/preview_hub_strings.dart';
import 'search/preview_search_field.dart';

/// The gallery's search field, shared by every collection screen. Owns only
/// its text controller and focus node: the query is reported through
/// [onChanged] and the screen's view model decides what it means.
class PreviewSearchBar extends StatefulWidget {
  /// Creates a search bar prompting with [hintText].
  const PreviewSearchBar({
    required this.onChanged,
    this.hintText = PreviewHubStrings.search,
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

/// Holds the text controller and focus node for [PreviewSearchBar].
class _PreviewSearchBarState extends State<PreviewSearchBar> {
  /// Text being edited, seeded with [PreviewSearchBar.initialValue].
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  /// Focus the field's accent ring follows.
  late final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Empties the field and reports the empty query.
  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _focusNode,
      builder: (BuildContext context, Widget? child) {
        return PreviewSearchField(
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
