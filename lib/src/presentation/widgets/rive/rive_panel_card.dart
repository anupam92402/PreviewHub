import 'package:flutter/material.dart';

/// The rounded card the Rive detail panels sit in, titled, with an optional
/// action beside the title.
class RivePanelCard extends StatelessWidget {
  /// Creates a card titled [title] holding [children].
  const RivePanelCard({
    required this.title,
    required this.children,
    this.action,
    super.key,
  });

  /// Heading of the card.
  final String title;

  /// Rows of the card, top to bottom.
  final List<Widget> children;

  /// Control shown at the end of the title row, or null for none.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Widget? action = this.action;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ?action,
                ],
              ),
              const SizedBox(height: 4),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
