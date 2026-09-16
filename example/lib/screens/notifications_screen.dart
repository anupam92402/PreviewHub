import 'package:flutter/material.dart';

import '../design_system/app_button.dart';
import '../design_system/app_toast.dart';
import '../design_system/app_tokens.dart';

/// Inbox screen, built almost entirely from the toast component.
class NotificationsScreen extends StatelessWidget {
  /// Creates the notifications screen.
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTokens.canvas,
    appBar: AppBar(
      backgroundColor: AppTokens.canvas,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Notifications',
        style: TextStyle(fontWeight: FontWeight.w700, color: AppTokens.ink),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        const _InboxLabel(label: 'Needs attention'),
        AppToast(
          kind: AppToastKind.failure,
          title: 'Toll recharge failed',
          message:
              'The card issuer declined ₹3,200. No money left your '
              'account.',
          actionLabel: 'Retry payment',
          onAction: () {},
          onDismiss: () {},
        ),
        const SizedBox(height: 12),
        AppToast(
          kind: AppToastKind.pending,
          title: 'Fuel card top-up in progress',
          message: '14 vehicles · started 9:15 AM',
          onDismiss: () {},
        ),
        const SizedBox(height: 24),
        const _InboxLabel(label: 'Earlier today'),
        AppToast(
          kind: AppToastKind.success,
          title: 'Payment sent to Meridian Freight',
          message: '₹12,480 settled at 11:42 AM.',
          onDismiss: () {},
        ),
        const SizedBox(height: 12),
        AppToast(
          kind: AppToastKind.success,
          title: 'Invoice #2291 collected',
          message: 'Kala Textiles paid ₹48,900.',
          onDismiss: () {},
        ),
        const SizedBox(height: 28),
        AppButton(
          label: 'Mark all as read',
          variant: AppButtonVariant.outlined,
          tone: AppButtonTone.secondary,
          onPressed: () {},
        ),
      ],
    ),
  );
}

/// Heading above a run of notifications.
class _InboxLabel extends StatelessWidget {
  const _InboxLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppTokens.inkMuted,
      ),
    ),
  );
}
