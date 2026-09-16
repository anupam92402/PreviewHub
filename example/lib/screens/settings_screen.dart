import 'package:flutter/material.dart';

import '../design_system/app_button.dart';
import '../design_system/app_checkbox.dart';
import '../design_system/app_tokens.dart';

/// Preferences screen: grouped switches, a consent checkbox and a sign-out.
class SettingsScreen extends StatefulWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ValueNotifier<bool> _pushAlerts = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _weeklyDigest = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _biometrics = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _analytics = ValueNotifier<bool>(false);
  final ValueNotifier<bool?> _marketing = ValueNotifier<bool?>(false);

  @override
  void dispose() {
    _pushAlerts.dispose();
    _weeklyDigest.dispose();
    _biometrics.dispose();
    _analytics.dispose();
    _marketing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTokens.canvas,
    appBar: AppBar(
      backgroundColor: AppTokens.canvas,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Settings',
        style: TextStyle(fontWeight: FontWeight.w700, color: AppTokens.ink),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        const _SettingsGroupLabel(label: 'Notifications'),
        _SettingsCard(
          children: <Widget>[
            _SwitchRow(
              title: 'Push alerts',
              subtitle: 'Payments, approvals and failures',
              icon: Icons.notifications_active_outlined,
              value: _pushAlerts,
            ),
            const _SettingsDivider(),
            _SwitchRow(
              title: 'Weekly digest',
              subtitle: 'A Monday summary by email',
              icon: Icons.mail_outline_rounded,
              value: _weeklyDigest,
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _SettingsGroupLabel(label: 'Security'),
        _SettingsCard(
          children: <Widget>[
            _SwitchRow(
              title: 'Biometric unlock',
              subtitle: 'Face ID on this device',
              icon: Icons.fingerprint_rounded,
              value: _biometrics,
            ),
            const _SettingsDivider(),
            _SwitchRow(
              title: 'Share usage analytics',
              subtitle: 'Anonymous crash and performance data',
              icon: Icons.insights_outlined,
              value: _analytics,
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _SettingsGroupLabel(label: 'Consent'),
        _SettingsCard(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ValueListenableBuilder<bool?>(
                valueListenable: _marketing,
                builder: (BuildContext context, bool? value, Widget? child) =>
                    AppCheckbox(
                      label: 'Send me product news',
                      helperText: 'You can turn this off at any time.',
                      value: value,
                      onChanged: (bool? next) => _marketing.value = next,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        AppButton(
          label: 'Sign out',
          variant: AppButtonVariant.outlined,
          tone: AppButtonTone.secondary,
          size: AppButtonSize.large,
          icon: Icons.logout_rounded,
          onPressed: () {},
        ),
        const SizedBox(height: 10),
        const AppButton(
          label: 'Delete account',
          variant: AppButtonVariant.text,
          tone: AppButtonTone.secondary,
          size: AppButtonSize.large,
        ),
      ],
    ),
  );
}

/// Small caps-ish label above a card of rows.
class _SettingsGroupLabel extends StatelessWidget {
  const _SettingsGroupLabel({required this.label});

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

/// White rounded container holding a group's rows.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(AppTokens.radius),
      border: Border.all(color: AppTokens.outline),
    ),
    child: Column(children: children),
  );
}

/// Hairline between two rows of a card.
class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppTokens.canvas);
}

/// One preference, toggled by the switch on its trailing edge.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ValueNotifier<bool> value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: <Widget>[
        Icon(icon, size: 20, color: AppTokens.inkMuted),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppTokens.inkMuted,
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: value,
          builder: (BuildContext context, bool on, Widget? child) => Switch(
            value: on,
            activeThumbColor: AppTokens.onAccent,
            activeTrackColor: AppTokens.primary,
            onChanged: (bool next) => value.value = next,
          ),
        ),
      ],
    ),
  );
}
