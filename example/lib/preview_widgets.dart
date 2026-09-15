import 'package:flutter/material.dart';
import 'package:preview_hub/preview_hub.dart';

import 'design_system/app_button.dart';
import 'design_system/app_checkbox.dart';
import 'design_system/app_text_field.dart';
import 'design_system/app_toast.dart';
import 'design_system/app_tokens.dart';
import 'design_system/gradient_text.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/success_screen.dart';

/// Every component and screen this app hands to the gallery.
///
/// One list, in the order it should be read: components first, then whole
/// screens. The gallery files each entry under its group and section.
const List<WidgetPreview> previewWidgets = <WidgetPreview>[
  WidgetPreview(
    group: 'Buttons',
    title: 'AppButton · primary',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'filled · large (52)', builder: _primaryLarge),
      WidgetPreviewCase(label: 'filled · with icon', builder: _primaryIcon),
      WidgetPreviewCase(label: 'filled · medium (44)', builder: _primaryMedium),
      WidgetPreviewCase(label: 'filled · small (36)', builder: _primarySmall),
      WidgetPreviewCase(
        label: 'outlined · medium (44)',
        builder: _primaryOutlined,
      ),
      WidgetPreviewCase(label: 'text · medium (44)', builder: _primaryText),
      WidgetPreviewCase(label: 'disabled', builder: _primaryDisabled),
    ],
  ),
  WidgetPreview(
    group: 'Buttons',
    title: 'AppButton · secondary',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'filled · medium (44)', builder: _secondary),
      WidgetPreviewCase(
        label: 'outlined · medium (44)',
        builder: _secondaryOutlined,
      ),
      WidgetPreviewCase(label: 'text · medium (44)', builder: _secondaryText),
    ],
  ),
  WidgetPreview(
    group: 'Buttons',
    title: 'AppButton · tertiary',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'filled · medium (44)', builder: _tertiary),
      WidgetPreviewCase(
        label: 'outlined · medium (44)',
        builder: _tertiaryOutlined,
      ),
      WidgetPreviewCase(label: 'text · small (36)', builder: _tertiaryText),
    ],
  ),
  WidgetPreview(
    group: 'Feedback',
    title: 'AppToast · success / failure / pending',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'success', builder: _toastSuccess),
      WidgetPreviewCase(label: 'failure · with action', builder: _toastFailure),
      WidgetPreviewCase(label: 'pending · spinner', builder: _toastPending),
    ],
  ),
  WidgetPreview(
    group: 'Inputs',
    title: 'AppTextField · states',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'empty · with hint', builder: _fieldEmpty),
      WidgetPreviewCase(label: 'filled · with helper', builder: _fieldFilled),
      WidgetPreviewCase(label: 'error', builder: _fieldError),
      WidgetPreviewCase(
        label: 'password · reveal toggle',
        builder: _fieldPassword,
      ),
      WidgetPreviewCase(label: 'disabled', builder: _fieldDisabled),
    ],
  ),
  WidgetPreview(
    group: 'Selection',
    title: 'AppCheckbox · states',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'interactive', builder: _checkboxLive),
      WidgetPreviewCase(
        label: 'tristate · interactive',
        builder: _checkboxTristate,
      ),
      WidgetPreviewCase(label: 'error', builder: _checkboxError),
      WidgetPreviewCase(label: 'disabled', builder: _checkboxDisabled),
    ],
  ),
  WidgetPreview(
    group: 'Typography',
    title: 'GradientText · brand',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(
        label: 'display · brand gradient',
        builder: _gradientBrand,
      ),
      WidgetPreviewCase(
        label: 'display · success gradient',
        builder: _gradientSuccess,
      ),
      WidgetPreviewCase(label: 'title · two lines', builder: _gradientTwoLines),
    ],
  ),
  WidgetPreview(
    section: WidgetSection.screens,
    group: 'Auth',
    title: 'SignInScreen · default',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'default', builder: _signIn),
    ],
  ),
  WidgetPreview(
    section: WidgetSection.screens,
    group: 'Money',
    title: 'DashboardScreen · default',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'default', builder: _dashboard),
    ],
  ),
  WidgetPreview(
    section: WidgetSection.screens,
    group: 'Money',
    title: 'SuccessScreen · payment sent',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'payment sent', builder: _success),
    ],
  ),
  WidgetPreview(
    section: WidgetSection.screens,
    group: 'Money',
    title: 'HistoryScreen · grouped by day',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'grouped by day', builder: _history),
    ],
  ),
  WidgetPreview(
    section: WidgetSection.screens,
    group: 'Account',
    title: 'ProfileScreen · with field error',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'with field error', builder: _profile),
    ],
  ),
  WidgetPreview(
    section: WidgetSection.screens,
    group: 'Account',
    title: 'SettingsScreen · default',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'default', builder: _settings),
    ],
  ),
  WidgetPreview(
    section: WidgetSection.screens,
    group: 'Inbox',
    title: 'NotificationsScreen · unread',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'unread', builder: _notifications),
    ],
  ),
];

// Buttons. Each builder is a top-level function so the whole list above stays
// const, which a closure would prevent.

Widget _primaryLarge(BuildContext context) =>
    AppButton(label: 'Continue', size: AppButtonSize.large, onPressed: () {});

Widget _primaryIcon(BuildContext context) => AppButton(
  label: 'Pay now',
  size: AppButtonSize.large,
  icon: Icons.lock_outline_rounded,
  onPressed: () {},
);

Widget _primaryMedium(BuildContext context) =>
    AppButton(label: 'Continue', onPressed: () {});

Widget _primarySmall(BuildContext context) =>
    AppButton(label: 'Continue', size: AppButtonSize.small, onPressed: () {});

Widget _primaryOutlined(BuildContext context) => AppButton(
  label: 'Continue',
  variant: AppButtonVariant.outlined,
  onPressed: () {},
);

Widget _primaryText(BuildContext context) => AppButton(
  label: 'Continue',
  variant: AppButtonVariant.text,
  onPressed: () {},
);

Widget _primaryDisabled(BuildContext context) =>
    const AppButton(label: 'Continue');

Widget _secondary(BuildContext context) => AppButton(
  label: 'Save draft',
  tone: AppButtonTone.secondary,
  onPressed: () {},
);

Widget _secondaryOutlined(BuildContext context) => AppButton(
  label: 'Save draft',
  tone: AppButtonTone.secondary,
  variant: AppButtonVariant.outlined,
  onPressed: () {},
);

Widget _secondaryText(BuildContext context) => AppButton(
  label: 'Save draft',
  tone: AppButtonTone.secondary,
  variant: AppButtonVariant.text,
  onPressed: () {},
);

Widget _tertiary(BuildContext context) => AppButton(
  label: 'Request money',
  tone: AppButtonTone.tertiary,
  onPressed: () {},
);

Widget _tertiaryOutlined(BuildContext context) => AppButton(
  label: 'Request money',
  tone: AppButtonTone.tertiary,
  variant: AppButtonVariant.outlined,
  onPressed: () {},
);

Widget _tertiaryText(BuildContext context) => AppButton(
  label: 'Request money',
  tone: AppButtonTone.tertiary,
  variant: AppButtonVariant.text,
  size: AppButtonSize.small,
  onPressed: () {},
);

// Feedback.

Widget _toastSuccess(BuildContext context) => const AppToast(
  kind: AppToastKind.success,
  title: 'Payment sent',
  message: '₹12,480 settled at 11:42 AM.',
);

Widget _toastFailure(BuildContext context) => AppToast(
  kind: AppToastKind.failure,
  title: 'Toll recharge failed',
  message: 'The card issuer declined ₹3,200.',
  actionLabel: 'Retry payment',
  onAction: () {},
  onDismiss: () {},
);

Widget _toastPending(BuildContext context) => const AppToast(
  kind: AppToastKind.pending,
  title: 'Fuel card top-up in progress',
  message: '14 vehicles · started 9:15 AM',
);

// Inputs.

Widget _fieldEmpty(BuildContext context) => const AppTextField(
  label: 'Email',
  hintText: 'you@company.com',
  prefixIcon: Icons.mail_outline_rounded,
);

Widget _fieldFilled(BuildContext context) => const AppTextField(
  label: 'Work email',
  initialText: 'anupam@wheelseye.com',
  prefixIcon: Icons.mail_outline_rounded,
  helperText: 'Used for invoices and receipts.',
);

Widget _fieldError(BuildContext context) => const AppTextField(
  label: 'Phone',
  initialText: '+91 90000 00000',
  prefixIcon: Icons.call_outlined,
  errorText: 'This number is already on another account.',
);

Widget _fieldPassword(BuildContext context) => const AppTextField(
  label: 'Password',
  initialText: 'hunter2024',
  prefixIcon: Icons.lock_outline_rounded,
  obscurable: true,
);

Widget _fieldDisabled(BuildContext context) => const AppTextField(
  label: 'Employee ID',
  initialText: 'WE-4471',
  prefixIcon: Icons.badge_outlined,
  enabled: false,
  helperText: 'Managed by your administrator.',
);

// Selection.

Widget _checkboxLive(BuildContext context) =>
    const _CheckboxDemo(label: 'Keep me signed in', initial: true);

Widget _checkboxTristate(BuildContext context) => const _CheckboxDemo(
  label: 'Select all vehicles',
  initial: null,
  tristate: true,
  helperText: 'Tap to cycle through all, none and some.',
);

Widget _checkboxError(BuildContext context) => const AppCheckbox(
  label: 'I accept the terms of service',
  value: false,
  errorText: 'You must accept before continuing.',
);

Widget _checkboxDisabled(BuildContext context) =>
    const AppCheckbox(label: 'Managed by your administrator', value: true);

// Typography.

Widget _gradientBrand(BuildContext context) =>
    const GradientText('Welcome back');

Widget _gradientSuccess(BuildContext context) =>
    const GradientText('Payment sent', gradient: AppTokens.successGradient);

Widget _gradientTwoLines(BuildContext context) => const GradientText(
  'See your design system\nrunning for real',
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppTokens.onAccent,
  ),
);

// Screens.

Widget _signIn(BuildContext context) => const SignInScreen();

Widget _dashboard(BuildContext context) => const DashboardScreen();

Widget _success(BuildContext context) => const SuccessScreen();

Widget _history(BuildContext context) => const HistoryScreen();

Widget _profile(BuildContext context) => const ProfileScreen();

Widget _settings(BuildContext context) => const SettingsScreen();

Widget _notifications(BuildContext context) => const NotificationsScreen();

/// A checkbox that actually toggles, so the preview is worth tapping.
class _CheckboxDemo extends StatefulWidget {
  const _CheckboxDemo({
    required this.label,
    required this.initial,
    this.tristate = false,
    this.helperText,
  });

  final String label;
  final bool? initial;
  final bool tristate;
  final String? helperText;

  @override
  State<_CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<_CheckboxDemo> {
  late final ValueNotifier<bool?> _value = ValueNotifier<bool?>(widget.initial);

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool?>(
    valueListenable: _value,
    builder: (BuildContext context, bool? value, Widget? child) => AppCheckbox(
      label: widget.label,
      value: value,
      tristate: widget.tristate,
      helperText: widget.helperText,
      onChanged: (bool? next) => _value.value = next,
    ),
  );
}
