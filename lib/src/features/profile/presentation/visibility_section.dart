import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/profile/data/profile_controller.dart';

/// Search visibility (UAT-12, §5.5).
///
/// ## Not a schema field, deliberately
///
/// Two reasons, both from the contract. §4.2's `kind` union has no `enum`
/// member, so there is nothing to render it as; and this is the one write that
/// must **not** refresh `lastMeaningfulUpdateAt` — a privacy toggle cannot be
/// used to make a stale profile look maintained. `PUT /candidates/me/visibility`
/// owns it and the form engine never sees it.
///
/// ## It applies immediately
///
/// Not part of the form's dirty set and not gated on the save bar. A privacy
/// control that needs a second confirming tap somewhere else is one a user can
/// believe they have set when they have not.
///
/// ## The setting is not the effect
///
/// BR-02 gates *searchability* on a complete profile, so choosing "visible in
/// search" on an incomplete profile changes the setting and nothing else. The
/// completeness card states the resulting state separately, which is why this
/// control does not try to explain it too.
class VisibilitySection extends ConsumerStatefulWidget {
  const VisibilitySection({required this.current, super.key});

  /// The stored value: `searchable`, `hidden` or `visible_after_apply`.
  final String current;

  @override
  ConsumerState<VisibilitySection> createState() => _VisibilitySectionState();
}

class _VisibilitySectionState extends ConsumerState<VisibilitySection> {
  /// Set while a write is in flight, so the radio shows the choice the user
  /// made rather than snapping back to the stored value until the server
  /// answers. Cleared on both success and failure.
  String? _pending;

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final selected = _pending ?? widget.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.profileVisibilityTitle, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),

        _option(
          value: 'searchable',
          selected: selected,
          label: l10n.profileVisibilitySearchable,
          hint: l10n.profileVisibilitySearchableHint,
        ),
        _option(
          value: 'hidden',
          selected: selected,
          label: l10n.profileVisibilityHidden,
          hint: l10n.profileVisibilityHiddenHint,
        ),
        _option(
          value: 'visible_after_apply',
          selected: selected,
          label: l10n.profileVisibilityAfterApply,
          hint: l10n.profileVisibilityAfterApplyHint,
        ),
      ],
    );
  }

  Widget _option({
    required String value,
    required String selected,
    required String label,
    required String hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: HhSpace.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HhRadioRow<String>(
          label: label,
          value: value,
          groupValue: selected,
          onChanged: _saving ? null : _choose,
        ),
        Padding(
          // Indented to sit under the label rather than the control, so the
          // hint reads as belonging to the option above it.
          padding: const EdgeInsets.only(left: HhSpace.xl),
          child: Text(
            hint,
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),
        ),
      ],
    ),
  );

  Future<void> _choose(String value) async {
    if (value == widget.current || _saving) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _pending = value;
      _saving = true;
    });

    try {
      await ref.read(profileEditorProvider.notifier).setVisibility(value);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      // Cleared either way: on success the controller has adopted the server's
      // value, and on failure the radio must fall back to what is actually
      // stored rather than showing a choice that did not take.
      if (mounted) {
        setState(() {
          _pending = null;
          _saving = false;
        });
      }
    }
  }
}
