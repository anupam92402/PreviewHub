import 'package:flutter/material.dart';

import '../design_system/app_button.dart';
import '../design_system/app_checkbox.dart';
import '../design_system/app_text_field.dart';
import '../design_system/app_tokens.dart';
import '../design_system/gradient_text.dart';

/// Sign-in form: the design system's fields, checkbox and buttons in one flow.
class SignInScreen extends StatefulWidget {
  /// Creates the sign-in screen.
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final ValueNotifier<bool> _remember = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _remember.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTokens.canvas,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _SignInMark(),
            const SizedBox(height: 26),
            const GradientText('Welcome back'),
            const SizedBox(height: 8),
            const Text(
              'Sign in to pick up where you left off.',
              style: TextStyle(fontSize: 15, color: AppTokens.inkMuted),
            ),
            const SizedBox(height: 30),
            const AppTextField(
              label: 'Email',
              hintText: 'you@company.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            const AppTextField(
              label: 'Password',
              hintText: 'At least 8 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscurable: true,
              initialText: 'hunter2024',
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<bool>(
              valueListenable: _remember,
              builder: (BuildContext context, bool remember, Widget? child) =>
                  AppCheckbox(
                    label: 'Keep me signed in',
                    value: remember,
                    onChanged: (bool? value) =>
                        _remember.value = value ?? false,
                  ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Sign in',
              size: AppButtonSize.large,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Continue with SSO',
              variant: AppButtonVariant.outlined,
              size: AppButtonSize.large,
              icon: Icons.shield_outlined,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Forgot password?',
              variant: AppButtonVariant.text,
              tone: AppButtonTone.secondary,
              onPressed: () {},
            ),
          ],
        ),
      ),
    ),
  );
}

/// Rounded brand tile standing in for a logo.
class _SignInMark extends StatelessWidget {
  const _SignInMark();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: AppTokens.brandGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.bolt_rounded,
        color: AppTokens.onAccent,
        size: 30,
      ),
    ),
  );
}
