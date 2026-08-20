import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_picker.dart';
import 'package:jobbridge_app/src/features/invitations/data/invitation_repository.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_quota.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invite_outcome.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/invitation_format.dart';
import 'package:jobbridge_app/src/features/vacancy/data/vacancy_repository.dart';
import 'package:jobbridge_app/src/features/vacancy/domain/vacancy.dart';
import 'package:jobbridge_app/src/features/vacancy/presentation/vacancy_status.dart';

/// Opens §8.2's send-invitation form for one candidate.
///
/// Returns the outcome so the caller can reflect it — a sent invitation changes
/// what the candidate's profile should offer.
Future<InviteOutcome?> showComposeInvitation(
  BuildContext context, {
  required String candidateUserId,
  String? candidateName,
}) => Navigator.of(context, rootNavigator: true).push<InviteOutcome>(
  MaterialPageRoute(
    builder: (_) => ComposeInvitationScreen(
      candidateUserId: candidateUserId,
      candidateName: candidateName,
    ),
  ),
);

/// §8.2's two invitation shapes, as the employer chooses between them.
enum _Shape { vacancy, general }

/// Send an invitation to one candidate (§8.2, UAT-07).
///
/// ## Sending is free, and that was a decision
///
/// §8.2's prose reads "the employer must have a Candidate Unlock … an
/// invitation **may then** be attached to an active vacancy or sent as a
/// general work invitation", which makes the unlock a precondition of sending.
/// Two other sections and the server disagree: §7.3 lists "Send invitation"
/// beside "View profile" and "Save", both free; §7.4's own worked example fills
/// twenty openings by sending invitations, which at 2 Coins each would cost
/// over a million som before a single reply; and the server checks BR-03 and
/// BR-02 and nothing else.
///
/// The client confirmed the lenient reading on 2026-08-19: **sending is free
/// and the candidate's acceptance is what opens contact.** So there is no price
/// on this screen and no unlock in this file. What replaces the price is a
/// daily cap — see below.
///
/// ## The cap is the server's, and this screen may not have one yet
///
/// [InvitationQuota] is rendered when the server sends one and simply absent
/// otherwise. The client holds no number and refuses no send on its own
/// authority: a guessed limit would refuse sends the API would have accepted,
/// which is a worse failure than no counter. The 409 is handled either way,
/// because the count can move between this frame and the tap.
class ComposeInvitationScreen extends ConsumerStatefulWidget {
  const ComposeInvitationScreen({
    required this.candidateUserId,
    super.key,
    this.candidateName,
  });

  final String candidateUserId;

  /// Who is being invited. Carried through so nobody sends an invitation to
  /// "this candidate" — the same reason the unlock sheet names them.
  final String? candidateName;

  @override
  ConsumerState<ComposeInvitationScreen> createState() =>
      _ComposeInvitationScreenState();
}

class _ComposeInvitationScreenState
    extends ConsumerState<ComposeInvitationScreen> {
  _Shape _shape = _Shape.vacancy;

  String? _vacancyId;
  String? _occupationId;
  String? _regionId;
  String? _districtId;
  String? _salaryPeriodId;
  bool _negotiable = false;

  final _salaryFrom = TextEditingController();
  final _salaryTo = TextEditingController();
  final _schedule = TextEditingController();
  final _message = TextEditingController();

  bool _busy = false;

  /// The server's refusal, held on the screen rather than thrown at a snackbar.
  ///
  /// Both of §8.2's meaningful refusals change what the screen should offer —
  /// one says "not today", the other "you already did this" — and a message
  /// that disappears after four seconds is the wrong container for either.
  InviteOutcome? _refusal;

  @override
  void dispose() {
    _salaryFrom.dispose();
    _salaryTo.dispose();
    _schedule.dispose();
    _message.dispose();
    super.dispose();
  }

  /// Whether the form carries enough for the shape it is in.
  ///
  /// Mirrors the server's `invitation.shape_invalid` rule — exactly one of
  /// `vacancyId` and `occupationId` — so the refusal is unreachable rather than
  /// merely unlikely. Everything else on a general invitation is optional,
  /// because §8.2 makes it a message rather than a posting.
  bool get _complete => switch (_shape) {
    _Shape.vacancy => _vacancyId != null,
    _Shape.general => _occupationId != null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final quota = ref.watch(invitationQuotaProvider);

    // Two different nulls collapse here on purpose. `AsyncData(null)` is "this
    // server has no cap"; anything else is "not loaded, or the request failed".
    // Neither may block the form, because **the server is the only thing that
    // may refuse a send** — a form disabled by a counter that did not load
    // would stop an employer for a reason that is not a rule.
    final remaining = switch (quota) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final blockedByQuota = remaining != null && !remaining.hasRemaining;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invitationSendTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            if (widget.candidateName case final name? when name.isNotEmpty)
              Text(name, style: HhTypography.subtitle),
            const SizedBox(height: HhSpace.xs),
            Text(
              l10n.invitationSendFree,
              style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
            ),

            if (remaining != null) ...[
              const SizedBox(height: HhSpace.md),
              _QuotaCard(quota: remaining),
            ],

            const SizedBox(height: HhSpace.lg),
            HhSegmented(
              labels: [l10n.invitationToVacancy, l10n.invitationGeneral],
              selectedIndex: _shape.index,
              onChanged: (i) => setState(() {
                _shape = _Shape.values[i];
                // The shapes are mutually exclusive on the wire, so switching
                // clears the other one's binding rather than leaving a value
                // the server would refuse.
                _vacancyId = null;
                _occupationId = null;
                _refusal = null;
              }),
            ),
            const SizedBox(height: HhSpace.lg),

            if (_shape == _Shape.vacancy)
              _VacancyChoice(
                selected: _vacancyId,
                onChanged: (id) => setState(() => _vacancyId = id),
              )
            else
              ..._generalFields(l10n),

            const SizedBox(height: HhSpace.lg),
            HhTextField(
              label: l10n.invitationMessageLabel,
              controller: _message,
              hintText: l10n.invitationMessageHint,
              maxLines: 4,
              // §8.2's own ceiling, so the field stops where the API would
              // have refused rather than after it.
              maxLength: 2000,
              enabled: !_busy,
            ),

            if (_refusal case final refusal?) ...[
              const SizedBox(height: HhSpace.md),
              _Refusal(outcome: refusal),
            ],

            const SizedBox(height: HhSpace.lg),
            HhButton(
              label: l10n.invitationSend,
              loading: _busy,
              onPressed: _complete && !blockedByQuota && !_busy ? _send : null,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _generalFields(AppL10n l10n) => [
    HhDictionaryPicker(
      label: l10n.invitationOccupation,
      type: DictionaryType.occupation,
      value: _occupationId,
      enabled: !_busy,
      onChanged: (id) => setState(() => _occupationId = id),
    ),
    const SizedBox(height: HhSpace.md),
    HhDictionaryPicker(
      label: l10n.invitationRegion,
      type: DictionaryType.region,
      value: _regionId,
      enabled: !_busy,
      onChanged: (id) => setState(() {
        _regionId = id;
        // A district outlives its region only as a wrong answer, so changing
        // the parent clears the child — the same rule the profile cascade uses.
        _districtId = null;
      }),
    ),
    if (_regionId case final region?) ...[
      const SizedBox(height: HhSpace.md),
      HhDictionaryPicker(
        label: l10n.invitationDistrict,
        type: DictionaryType.region,
        parentId: region,
        parentScoped: true,
        value: _districtId,
        enabled: !_busy,
        onChanged: (id) => setState(() => _districtId = id),
      ),
    ],
    const SizedBox(height: HhSpace.md),
    HhSwitchRow(
      label: l10n.invitationNegotiable,
      value: _negotiable,
      onChanged: (v) => setState(() {
        _negotiable = v;
        // Negotiable and a range are different answers, not a figure with a
        // caveat — so choosing one discards the other rather than sending both.
        if (v) {
          _salaryFrom.clear();
          _salaryTo.clear();
          _salaryPeriodId = null;
        }
      }),
    ),
    if (!_negotiable) ...[
      const SizedBox(height: HhSpace.md),
      Row(
        children: [
          Expanded(
            child: HhTextField(
              label: l10n.invitationSalaryFrom,
              controller: _salaryFrom,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !_busy,
            ),
          ),
          const SizedBox(width: HhSpace.sm),
          Expanded(
            child: HhTextField(
              label: l10n.invitationSalaryTo,
              controller: _salaryTo,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !_busy,
            ),
          ),
        ],
      ),
      const SizedBox(height: HhSpace.md),
      HhDictionaryPicker(
        label: l10n.invitationSalaryPeriod,
        type: DictionaryType.paymentPeriod,
        value: _salaryPeriodId,
        enabled: !_busy,
        onChanged: (id) => setState(() => _salaryPeriodId = id),
      ),
    ],
    const SizedBox(height: HhSpace.md),
    HhTextField(
      label: l10n.invitationSchedule,
      controller: _schedule,
      hintText: l10n.invitationScheduleHint,
      maxLines: 2,
      maxLength: 500,
      enabled: !_busy,
    ),
  ];

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final general = _shape == _Shape.general;

    try {
      final repository = await ref.read(invitationRepositoryProvider.future);
      final outcome = await repository.invite(
        candidateUserId: widget.candidateUserId,
        vacancyId: general ? null : _vacancyId,
        occupationId: general ? _occupationId : null,
        regionId: general ? _regionId : null,
        districtId: general ? _districtId : null,
        salaryFrom: general ? _int(_salaryFrom) : null,
        salaryTo: general ? _int(_salaryTo) : null,
        salaryPeriodId: general ? _salaryPeriodId : null,
        salaryIsNegotiable: general && _negotiable ? true : null,
        scheduleNote: general ? _text(_schedule) : null,
        message: _text(_message),
      );

      // The quota moved on a send, and it also moved on a refusal that named a
      // new figure — so it is invalidated either way rather than adjusted here.
      // §12.3.1: the count is the server's, and one that this screen
      // decremented itself would disagree with it the moment a second device
      // sent one.
      ref
        ..invalidate(invitationQuotaProvider)
        ..invalidate(sentInvitationsProvider);

      if (!mounted) return;

      switch (outcome) {
        case InviteSent():
          navigator.pop(outcome);
        case InviteQuotaReached() || InviteAlreadySent():
          setState(() {
            _refusal = outcome;
            _busy = false;
          });
      }
    } on ApiException catch (e) {
      // BR-03's 403, `shape_invalid`, `vacancy_not_open` and an unknown
      // candidate all land here in the server's own words, which name which
      // rule refused. None of them changes what the screen offers.
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _busy = false);
    }
  }

  /// A digits-only field as an int, or null when it is empty.
  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  String? _text(TextEditingController c) {
    final value = c.text.trim();
    return value.isEmpty ? null : value;
  }
}

/// Today's remaining invitations, as the server counted them.
class _QuotaCard extends StatelessWidget {
  const _QuotaCard({required this.quota});

  final InvitationQuota quota;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    // Zero is a state with a time attached rather than a failure: the employer
    // did nothing wrong and the remedy is a clock, not an action.
    if (!quota.hasRemaining) {
      return HhNotice.pending(
        title: l10n.invitationQuotaSpentTitle,
        message: l10n.invitationQuotaResets(
          invitationStamp(quota.resetsAt.wallClock),
        ),
      );
    }

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.invitationQuotaRemaining(quota.remaining, quota.limit),
            style: HhTypography.bodyStrong,
          ),
          const SizedBox(height: HhSpace.xs),
          Text(
            l10n.invitationQuotaResets(
              invitationStamp(quota.resetsAt.wallClock),
            ),
            style: HhTypography.caption.copyWith(color: HhColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

/// The refusals that are outcomes rather than errors.
class _Refusal extends StatelessWidget {
  const _Refusal({required this.outcome});

  final InviteOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return switch (outcome) {
      // Warning-toned, not error: nothing is broken and nothing was done wrong.
      InviteQuotaReached(:final message) => HhNotice.pending(
        title: l10n.invitationQuotaSpentTitle,
        message: message,
      ),
      InviteAlreadySent(:final message) => HhNotice.pending(
        title: l10n.invitationAlreadySentTitle,
        message: message,
      ),
      InviteSent() => const SizedBox.shrink(),
    };
  }
}

/// The employer's own vacancies that are actually open (§8.2, BR-06).
///
/// Only open ones are offered, because the server refuses the rest with
/// `invitation.vacancy_not_open` — an invitation must not advertise something
/// that would turn the application away. Filtering here rather than rendering a
/// disabled row keeps the list to the choices that work.
class _VacancyChoice extends ConsumerWidget {
  const _VacancyChoice({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final vacancies = ref.watch(myVacanciesProvider);

    return switch (vacancies) {
      AsyncValue(hasError: true, :final error?) => HhErrorState(
        title: l10n.stateErrorTitle,
        message: error is ApiException ? error.message : l10n.stateErrorBody,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(myVacanciesProvider),
      ),
      AsyncData(:final value) => _openList(context, l10n, value),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _openList(BuildContext context, AppL10n l10n, List<Vacancy> all) {
    final open = all.where((v) => v.isOpenForApplications).toList();

    // A general invitation is still available, so this is a notice rather than
    // an error — the employer has a way forward without publishing anything.
    if (open.isEmpty) {
      return HhNotice.pending(
        title: l10n.invitationNoOpenVacancyTitle,
        message: l10n.invitationNoOpenVacancyBody,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.invitationVacancyLabel, style: HhTypography.label),
        const SizedBox(height: HhSpace.xs),
        for (final vacancy in open)
          HhRadioRow<String>(
            label: vacancyTitle(vacancy, l10n),
            value: vacancy.id,
            groupValue: selected,
            onChanged: onChanged,
          ),
      ],
    );
  }
}
