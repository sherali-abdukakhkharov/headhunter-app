import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/platform_pricing.dart';

/// §10.5's three money settings: Coin price, unlock cost, registration bonus.
///
/// ## The client never computes a price, and this is not an exception
///
/// §12.3.1 forbids the app from computing a total, a balance or an amount
/// payable, and nothing here does: every number on screen is one an
/// administrator typed or one the server returned. The one derived figure —
/// what an unlock costs in money — is shown as a *preview of what they are
/// setting*, from the two fields in front of them, and it is never sent.
///
/// ## The declared default is shown beside every setting
///
/// Otherwise "1 200" and "1 000" are indistinguishable: both are just numbers,
/// and nothing on screen says which one the deployment chose. **Restore
/// default** deletes the override rather than writing the default back, which
/// is what makes it still track a later change to the environment.
///
/// ## Only what changed is sent
///
/// The server records one audit row per setting that actually moves, so
/// submitting all three when one was edited would put three decisions in the
/// log that nobody took. The submit button is therefore off when nothing has
/// moved, and says so.
class AdminPricingScreen extends ConsumerWidget {
  const AdminPricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final pricing = ref.watch(platformPricingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPricingTitle)),
      body: switch (pricing) {
        // Error first: retry is disabled app-wide, so a failure is terminal and
        // matching the loading arm first spins over it.
        AsyncValue(hasError: true, :final error?) => Padding(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: HhErrorState(
            title: failureTitle(error, l10n),
            message: error is ApiException
                ? error.message
                : l10n.stateErrorBody,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(platformPricingProvider),
          ),
        ),
        AsyncData(:final value) => _Editor(pricing: value),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.pricing});

  final PlatformPricing pricing;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late final Map<PricingField, TextEditingController> _fields = {
    for (final field in PricingField.values)
      field: TextEditingController(
        text: field.read(widget.pricing.current).toString(),
      ),
  };

  final _reason = TextEditingController();

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // The submit button's enabled state is derived from the same values the
    // submit path reads, so it has to be recomputed as they are typed.
    for (final controller in _fields.values) {
      controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    _reason.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  /// What each field currently holds, or null if it is not a whole number.
  int? _value(PricingField field) => int.tryParse(_fields[field]!.text.trim());

  /// The floor this field's value is under, or null when it is acceptable.
  ///
  /// The server's own bounds, restated so a control is refused before a request
  /// rather than after one — and on the field, never in a page error state
  /// whose heading claims the system failed (MT-013).
  String? _fieldError(PricingField field, AppL10n l10n) {
    final value = _value(field);
    if (value == null) return l10n.adminPricingBelowMinimum('${field.minimum}');
    if (value >= field.minimum) return null;

    // BR-16 in words rather than as a bound: the number is not the point, and
    // "at least 1" tells an administrator nothing about why.
    if (field == PricingField.unlockCost) return l10n.adminPricingFreeUnlock;

    return l10n.adminPricingBelowMinimum('${field.minimum}');
  }

  /// Every setting whose value differs from what the server holds.
  Map<PricingField, int> get _changes => {
    for (final field in PricingField.values)
      if (_value(field) case final value?
          when value != field.read(widget.pricing.current) &&
              value >= field.minimum)
        field: value,
  };

  /// What an unlock would cost at the two values on screen.
  ///
  /// A preview of what is being set, from fields the administrator is editing —
  /// not a quote, and never sent. §12.3.1's rule is about the client inventing
  /// an amount *payable*; showing the product of two numbers somebody just
  /// typed is the opposite of that, and leaving it out means setting a Coin
  /// price with no idea what it does to the only thing Coins buy.
  int get _unlockUzs =>
      _value(PricingField.unlockCost)! * _value(PricingField.coinPrice)!;

  bool get _valid => PricingField.values.every((field) {
    final value = _value(field);
    return value != null && value >= field.minimum;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final changes = _changes;

    return ListView(
      padding: const EdgeInsets.all(HhSpace.gutter),
      children: [
        HhNotice(
          title: l10n.adminPricingTitle,
          message: l10n.adminPricingBody,
          iconPath: HhIconPath.coin,
        ),
        const SizedBox(height: HhSpace.lg),

        _Field(
          field: PricingField.coinPrice,
          label: l10n.adminPricingCoinPrice,
          controller: _fields[PricingField.coinPrice]!,
          errorText: _fieldError(PricingField.coinPrice, l10n),
          // `walletUzs`, not `formatPay`: that one words a vacancy's
          // *range* and renders an exact figure as "10 000 – 10 000".
          declared: l10n.walletUzs(widget.pricing.declared.coinPriceUzs),
          overridden: widget.pricing.isOverridden(PricingField.coinPrice),
          onReset: () => _reset(PricingField.coinPrice),
        ),

        _Field(
          field: PricingField.unlockCost,
          label: l10n.adminPricingUnlockCost,
          controller: _fields[PricingField.unlockCost]!,
          errorText: _fieldError(PricingField.unlockCost, l10n),
          declared: l10n.adminPricingCoins(
            widget.pricing.declared.candidateUnlockCoins,
          ),
          overridden: widget.pricing.isOverridden(PricingField.unlockCost),
          onReset: () => _reset(PricingField.unlockCost),
        ),

        _Field(
          field: PricingField.registrationBonus,
          label: l10n.adminPricingBonus,
          controller: _fields[PricingField.registrationBonus]!,
          errorText: _fieldError(PricingField.registrationBonus, l10n),
          declared: l10n.adminPricingCoins(
            widget.pricing.declared.registrationBonusCoins,
          ),
          overridden: widget.pricing.isOverridden(
            PricingField.registrationBonus,
          ),
          onReset: () => _reset(PricingField.registrationBonus),
        ),

        // A preview of what is being set, from the two fields above it — not a
        // quote, never sent, and gone the moment either field is unreadable.
        if (_valid) ...[
          Text(
            l10n.adminPricingUnlockValue(l10n.walletUzs(_unlockUzs)),
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),
          const SizedBox(height: HhSpace.lg),
        ],

        HhTextField(
          label: l10n.adminPricingReason,
          controller: _reason,
          maxLines: 2,
        ),
        const SizedBox(height: HhSpace.lg),

        if (_error case final message?) ...[
          Text(
            message,
            style: HhTypography.caption.copyWith(color: HhColors.error),
          ),
          const SizedBox(height: HhSpace.sm),
        ],

        if (changes.isEmpty && _valid)
          Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.sm),
            child: Text(
              l10n.adminPricingNothingChanged,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),
          ),

        HhButton(
          label: l10n.commonSave,
          loading: _saving,
          // Derived from the same map the submit path sends, so the button and
          // what pressing it would do cannot disagree.
          onPressed: changes.isEmpty || _saving ? null : () => _save(changes),
        ),
      ],
    );
  }

  void _reset(PricingField field) {
    // Typing the declared value back is enough: the server writes only what
    // differs, and a value equal to the default leaves no override behind.
    _fields[field]!.text = field.read(widget.pricing.declared).toString();
  }

  Future<void> _save(Map<PricingField, int> changes) async {
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final reason = _reason.text.trim();
      await ref
          .read(adminRepositoryProvider)
          .setPricing(changes, reason: reason.isEmpty ? null : reason);

      ref.invalidate(platformPricingProvider);
      _reason.clear();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminPricingSaved)),
      );
    } on ApiException catch (e) {
      // The server's words. `admin.pricing_out_of_range` is the one that
      // matters, and it names the setting and the floor.
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// One setting: its value, the deployment default, and a way back to it.
class _Field extends StatelessWidget {
  const _Field({
    required this.field,
    required this.label,
    required this.controller,
    required this.declared,
    required this.overridden,
    required this.onReset,
    this.errorText,
  });

  final PricingField field;
  final String label;
  final TextEditingController controller;
  final String? errorText;

  /// Already formatted — money through `walletUzs`, Coins through the plural.
  final String declared;

  final bool overridden;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: HhSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HhTextField(
            label: label,
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: errorText,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.adminPricingDefault(declared),
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),

          // On its own line rather than beside the default: the three together
          // overflow a 360dp screen, and this is the half a reader most needs.
          if (overridden)
            Row(
              children: [
                // A word, never colour alone — "12000" and "10000" are
                // otherwise indistinguishable, and nothing on screen would say
                // which one the deployment chose. Not `HhBadge`: that
                // vocabulary is the five domain statuses, and this is a marker
                // on a form field.
                // Expanded so a long translation ellipsizes rather than
                // overflowing: the button beside it is the fixed part.
                Expanded(
                  child: Text(
                    l10n.adminPricingChanged,
                    style: HhTypography.caption.copyWith(
                      color: HhColors.warning,
                    ),
                  ),
                ),
                const SizedBox(width: HhSpace.sm),
                HhButton.text(
                  label: l10n.adminPricingReset,
                  onPressed: onReset,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
