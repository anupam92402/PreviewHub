import 'package:flutter/material.dart';

import '../design_system/app_button.dart';
import '../design_system/app_tokens.dart';

/// Home screen: balance, quick actions and the last few movements.
class DashboardScreen extends StatelessWidget {
  /// Creates the dashboard.
  const DashboardScreen({super.key});

  /// Rows under the activity heading.
  static const List<_Movement> _movements = <_Movement>[
    _Movement('Meridian Freight', 'Vendor payout', '-₹12,480', false),
    _Movement('Kala Textiles', 'Invoice #2291 settled', '+₹48,900', true),
    _Movement('Fuel card top-up', '14 vehicles', '-₹22,150', false),
    _Movement('Northline Logistics', 'Invoice #2287 settled', '+₹15,300', true),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTokens.canvas,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: <Widget>[
          const _DashboardGreeting(),
          const SizedBox(height: 20),
          const _BalanceCard(),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: 'Pay',
                  icon: Icons.north_east_rounded,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Request',
                  tone: AppButtonTone.tertiary,
                  icon: Icons.south_west_rounded,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionHeading(title: 'This month'),
          const SizedBox(height: 12),
          const Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(
                  label: 'Collected',
                  value: '₹3.42L',
                  delta: '+12.4%',
                  positive: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Spent',
                  value: '₹2.08L',
                  delta: '-4.1%',
                  positive: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionHeading(title: 'Recent activity'),
          const SizedBox(height: 4),
          for (final _Movement movement in _movements)
            _MovementRow(movement: movement),
        ],
      ),
    ),
  );
}

/// One row of the recent activity list.
class _Movement {
  const _Movement(this.title, this.subtitle, this.amount, this.incoming);

  final String title;
  final String subtitle;
  final String amount;
  final bool incoming;
}

/// Salutation and the avatar, at the top of the scroll.
class _DashboardGreeting extends StatelessWidget {
  const _DashboardGreeting();

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Good morning',
              style: TextStyle(fontSize: 13.5, color: AppTokens.inkMuted),
            ),
            SizedBox(height: 2),
            Text(
              'John Doe',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: AppTokens.ink,
              ),
            ),
          ],
        ),
      ),
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTokens.primarySoft,
          shape: BoxShape.circle,
          border: Border.all(color: AppTokens.outline),
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          size: 21,
          color: AppTokens.primary,
        ),
      ),
    ],
  );
}

/// Gradient card carrying the headline number.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
    decoration: BoxDecoration(
      gradient: AppTokens.brandGradient,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Available balance',
          style: TextStyle(fontSize: 13, color: Color(0xFFE4E7FB)),
        ),
        SizedBox(height: 8),
        Text(
          '₹4,86,210.55',
          style: TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w800,
            color: AppTokens.onAccent,
          ),
        ),
        SizedBox(height: 14),
        Row(
          children: <Widget>[
            Icon(
              Icons.account_balance_rounded,
              size: 15,
              color: Color(0xFFE4E7FB),
            ),
            SizedBox(width: 6),
            Text(
              'HDFC · 8841',
              style: TextStyle(fontSize: 12.5, color: Color(0xFFE4E7FB)),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Small heading above a block of content.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontSize: 15.5,
      fontWeight: FontWeight.w700,
      color: AppTokens.ink,
    ),
  );
}

/// One of the two figures beneath the heading.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.positive,
  });

  final String label;
  final String value;
  final String delta;
  final bool positive;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(AppTokens.radius),
      border: Border.all(color: AppTokens.outline),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: AppTokens.inkMuted),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTokens.ink,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Icon(
              positive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              size: 15,
              color: positive ? AppTokens.success : AppTokens.failure,
            ),
            const SizedBox(width: 4),
            Text(
              delta,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: positive ? AppTokens.success : AppTokens.failure,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// One movement, with a direction badge and a signed amount.
class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});

  final _Movement movement;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: movement.incoming
                ? AppTokens.successSoft
                : AppTokens.secondarySoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            movement.incoming
                ? Icons.south_west_rounded
                : Icons.north_east_rounded,
            size: 19,
            color: movement.incoming
                ? AppTokens.success
                : AppTokens.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                movement.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                movement.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppTokens.inkMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          movement.amount,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: movement.incoming ? AppTokens.success : AppTokens.ink,
          ),
        ),
      ],
    ),
  );
}
