import 'package:flutter/material.dart';

import '../design_system/app_button.dart';
import '../design_system/app_toast.dart';
import '../design_system/app_tokens.dart';
import '../design_system/gradient_text.dart';

/// Confirmation screen shown after a payment goes through.
class SuccessScreen extends StatelessWidget {
  /// Creates the success screen.
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTokens.canvas,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(),
            const _SuccessSeal(),
            const SizedBox(height: 28),
            const Center(
              child: GradientText(
                'Payment sent',
                gradient: AppTokens.successGradient,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'We moved ₹12,480.00 to Meridian Freight. '
              'A receipt is on its way to your inbox.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: AppTokens.inkMuted,
              ),
            ),
            const SizedBox(height: 26),
            const AppToast(
              kind: AppToastKind.success,
              title: 'Reference #TR-90881',
              message: 'Settles by 6:00 PM today.',
            ),
            const Spacer(),
            AppButton(
              label: 'View receipt',
              size: AppButtonSize.large,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Back to dashboard',
              variant: AppButtonVariant.text,
              tone: AppButtonTone.secondary,
              size: AppButtonSize.large,
              onPressed: () {},
            ),
          ],
        ),
      ),
    ),
  );
}

/// Concentric rings around a tick, the screen's focal point.
class _SuccessSeal extends StatelessWidget {
  const _SuccessSeal();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 112,
      height: 112,
      decoration: const BoxDecoration(
        color: AppTokens.successSoft,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppTokens.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 42,
            color: AppTokens.onAccent,
          ),
        ),
      ),
    ),
  );
}
