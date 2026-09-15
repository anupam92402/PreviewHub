import 'package:flutter/material.dart';

import '../design_system/app_button.dart';
import '../design_system/app_text_field.dart';
import '../design_system/app_tokens.dart';

/// Account screen: identity header, editable details and a save action.
class ProfileScreen extends StatelessWidget {
  /// Creates the profile screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTokens.canvas,
    appBar: AppBar(
      backgroundColor: AppTokens.canvas,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Profile',
        style: TextStyle(fontWeight: FontWeight.w700, color: AppTokens.ink),
      ),
      actions: const <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.more_horiz_rounded, color: AppTokens.ink),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        const _ProfileHeader(),
        const SizedBox(height: 22),
        const Row(
          children: <Widget>[
            Expanded(child: _ProfileStat(label: 'Trips', value: '1,284')),
            Expanded(child: _ProfileStat(label: 'Vehicles', value: '37')),
            Expanded(child: _ProfileStat(label: 'Rating', value: '4.8')),
          ],
        ),
        const SizedBox(height: 26),
        const AppTextField(
          label: 'Full name',
          initialText: 'Anupam Gupta',
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 18),
        const AppTextField(
          label: 'Work email',
          initialText: 'anupam@wheelseye.com',
          prefixIcon: Icons.mail_outline_rounded,
          helperText: 'Used for invoices and receipts.',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        const AppTextField(
          label: 'Phone',
          initialText: '+91 90000 00000',
          prefixIcon: Icons.call_outlined,
          errorText: 'This number is already on another account.',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 18),
        const AppTextField(
          label: 'Employee ID',
          initialText: 'WE-4471',
          prefixIcon: Icons.badge_outlined,
          enabled: false,
          helperText: 'Managed by your administrator.',
        ),
        const SizedBox(height: 28),
        AppButton(
          label: 'Save changes',
          size: AppButtonSize.large,
          onPressed: () {},
        ),
      ],
    ),
  );
}

/// Avatar, name and role, above the figures.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(
        width: 66,
        height: 66,
        decoration: const BoxDecoration(
          gradient: AppTokens.brandGradient,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'AG',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: AppTokens.onAccent,
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Anupam Gupta',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppTokens.ink,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Fleet operations · Gurugram',
              style: TextStyle(fontSize: 13.5, color: AppTokens.inkMuted),
            ),
          ],
        ),
      ),
    ],
  );
}

/// One figure in the three-up row under the header.
class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Text(
        value,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppTokens.ink,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: const TextStyle(fontSize: 12.5, color: AppTokens.inkMuted),
      ),
    ],
  );
}
