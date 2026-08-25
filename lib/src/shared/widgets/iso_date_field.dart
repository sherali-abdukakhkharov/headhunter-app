import 'package:flutter/material.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

/// A read-only field that opens a date picker and emits ISO `yyyy-MM-dd`.
///
/// ISO on the wire, always: the value is data, not display. §8.3's display
/// policy for dates and times is still open, and a localized format invented
/// here would have to be undone when it lands.
///
/// Shared rather than owned by the profile forms, because candidate search
/// asks for two dates of its own (§7.1's "available by" and "recently
/// updated") and the wire format is the part that must not diverge.
class IsoDateField extends StatelessWidget {
  const IsoDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  /// Bounds for the calendar. Both default to eighty years back and ten
  /// forward, which is a range wide enough that the *server* stays the one
  /// refusing a nonsensical date — in its own words, which the user can read.
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhTextField(
      label: label,
      readOnly: true,
      enabled: enabled,
      hintText: l10n.profileDateHint,
      trailingIconPath: HhIconPath.calendar,
      trailingSemanticLabel: l10n.commonPickDate,
      controller: TextEditingController(text: value ?? ''),
      onTap: enabled ? () => _pick(context) : null,
      onTrailingTap: enabled ? () => _pick(context) : null,
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _parse(value) ?? now,
      firstDate: firstDate ?? DateTime(now.year - 80),
      lastDate: lastDate ?? DateTime(now.year + 10),
    );

    if (picked == null) return;

    onChanged(
      '${picked.year.toString().padLeft(4, '0')}-'
      '${picked.month.toString().padLeft(2, '0')}-'
      '${picked.day.toString().padLeft(2, '0')}',
    );
  }

  static DateTime? _parse(String? value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } on FormatException {
      return null;
    }
  }
}
