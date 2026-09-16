import 'package:flutter/material.dart';

import '../design_system/app_tokens.dart';

/// How a past entry ended.
enum _EntryStatus {
  settled('Settled', AppTokens.success, AppTokens.successSoft),
  failed('Failed', AppTokens.failure, AppTokens.failureSoft),
  awaiting('Awaiting', AppTokens.pending, AppTokens.pendingSoft);

  const _EntryStatus(this.label, this.accent, this.surface);

  final String label;
  final Color accent;
  final Color surface;
}

/// One past transaction.
class _Entry {
  const _Entry(this.title, this.time, this.amount, this.status);

  final String title;
  final String time;
  final String amount;
  final _EntryStatus status;
}

/// A day's worth of entries, under one sticky-looking heading.
class _Day {
  const _Day(this.label, this.entries);

  final String label;
  final List<_Entry> entries;
}

/// Transaction history, grouped by day with a status chip on each row.
class HistoryScreen extends StatelessWidget {
  /// Creates the history screen.
  const HistoryScreen({super.key});

  /// The list, newest day first.
  static const List<_Day> _days = <_Day>[
    _Day('Today', <_Entry>[
      _Entry('Meridian Freight', '11:42 AM', '-₹12,480', _EntryStatus.settled),
      _Entry('Fuel card top-up', '9:15 AM', '-₹22,150', _EntryStatus.awaiting),
    ]),
    _Day('Yesterday', <_Entry>[
      _Entry('Kala Textiles', '6:04 PM', '+₹48,900', _EntryStatus.settled),
      _Entry('Toll recharge', '2:38 PM', '-₹3,200', _EntryStatus.failed),
      _Entry(
        'Northline Logistics',
        '10:07 AM',
        '+₹15,300',
        _EntryStatus.settled,
      ),
    ]),
    _Day('12 September', <_Entry>[
      _Entry(
        'Driver payout batch',
        '7:20 PM',
        '-₹86,400',
        _EntryStatus.settled,
      ),
      _Entry('Insurance premium', '11:55 AM', '-₹9,750', _EntryStatus.settled),
    ]),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTokens.canvas,
    appBar: AppBar(
      backgroundColor: AppTokens.canvas,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'History',
        style: TextStyle(fontWeight: FontWeight.w700, color: AppTokens.ink),
      ),
      actions: const <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.tune_rounded, color: AppTokens.ink),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        for (final _Day day in _days) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 10, bottom: 10),
            child: Text(
              day.label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppTokens.inkMuted,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppTokens.surface,
              borderRadius: BorderRadius.circular(AppTokens.radius),
              border: Border.all(color: AppTokens.outline),
            ),
            child: Column(
              children: <Widget>[
                for (final _Entry entry in day.entries)
                  _EntryRow(entry: entry, isLast: entry == day.entries.last),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

/// One transaction row: title, time, status chip and signed amount. Time and
/// status wrap, since side by side they overflow a narrow phone.
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.isLast});

  final _Entry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        entry.time,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTokens.inkMuted,
                        ),
                      ),
                      _StatusChip(status: entry.status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              entry.amount,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: entry.amount.startsWith('+')
                    ? AppTokens.success
                    : AppTokens.ink,
              ),
            ),
          ],
        ),
      ),
      if (!isLast)
        const Divider(height: 1, thickness: 1, color: AppTokens.canvas),
    ],
  );
}

/// Pill telling the reader how the transaction ended.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _EntryStatus status;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: status.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: status.accent,
      ),
    ),
  );
}
