import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// What a toast is reporting.
enum AppToastKind {
  /// The action completed.
  success(AppTokens.success, AppTokens.successSoft, Icons.check_circle_rounded),

  /// The action did not complete.
  failure(AppTokens.failure, AppTokens.failureSoft, Icons.error_rounded),

  /// The action is still running.
  pending(AppTokens.pending, AppTokens.pendingSoft, Icons.schedule_rounded);

  const AppToastKind(this.accent, this.surface, this.icon);

  /// Colour of the icon, the rule and the title.
  final Color accent;

  /// Background tint of the card.
  final Color surface;

  /// Glyph shown at the leading edge, replaced by a spinner while pending.
  final IconData icon;
}

/// An inline status card, in a success, failure or pending flavour. The pending
/// flavour shows an indeterminate spinner, so a widget test must pump a bounded
/// duration rather than settling.
class AppToast extends StatelessWidget {
  /// Creates a toast of [kind] headed [title].
  const AppToast({
    required this.kind,
    required this.title,
    this.message,
    this.onDismiss,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Which flavour to draw.
  final AppToastKind kind;

  /// Headline of the card.
  final String title;

  /// Optional supporting line beneath the title.
  final String? message;

  /// Called when the close button is tapped; hidden when null.
  final VoidCallback? onDismiss;

  /// Label of the optional trailing action.
  final String? actionLabel;

  /// Called when the action is tapped.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 13, 8, 13),
    decoration: BoxDecoration(
      color: kind.surface,
      borderRadius: BorderRadius.circular(AppTokens.radius),
      border: Border.all(color: kind.accent, width: 1),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ToastGlyph(kind: kind),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: kind.accent,
                ),
              ),
              if (message != null) ...<Widget>[
                const SizedBox(height: 3),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppTokens.inkMuted,
                  ),
                ),
              ],
              if (actionLabel != null) ...<Widget>[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: kind.accent,
                      color: kind.accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onDismiss != null)
          IconButton(
            onPressed: onDismiss,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppTokens.inkMuted,
          )
        else
          const SizedBox(width: 6),
      ],
    ),
  );
}

/// Leading indicator: a glyph, or a spinner while the work is still running.
class _ToastGlyph extends StatelessWidget {
  const _ToastGlyph({required this.kind});

  final AppToastKind kind;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 20,
    height: 20,
    child: kind == AppToastKind.pending
        ? CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(kind.accent),
          )
        : Icon(kind.icon, size: 20, color: kind.accent),
  );
}
