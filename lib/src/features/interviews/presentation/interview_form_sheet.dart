import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/interviews/data/interview_repository.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview_status.dart';
import 'package:jobbridge_app/src/features/interviews/presentation/interview_labels.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';
import 'package:jobbridge_app/src/shared/widgets/iso_date_field.dart';

/// Schedules an interview on an application, or moves an existing one (§8.3).
///
/// Pass [existing] to reschedule. Returns the interview the server accepted, or
/// null if the employer backed out.
///
/// [platformOffset] must come from a timestamp the **server** sent — see
/// [instantForPlatformWallClock] for why the client must not carry `+05:00` of
/// its own.
Future<Interview?> showInterviewForm(
  BuildContext context, {
  required String applicationId,
  required Duration platformOffset,
  Interview? existing,
}) => showModalBottomSheet<Interview>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _InterviewForm(
    applicationId: applicationId,
    platformOffset: platformOffset,
    existing: existing,
  ),
);

/// §8.3's scheduling form, and the same form for rescheduling.
///
/// ## One form for both, because the server takes one shape for both
///
/// `PUT /interviews/:id` accepts the whole `InterviewInputDto` rather than a
/// patch, and that is not an oversight: the type decides which of the location
/// and the link may exist at all, so a partial update would let a phone
/// interview keep the address of the in-person one it used to be. Two forms
/// would drift, and the drift would show up as an interview holding a detail
/// its type forbids.
///
/// ## Rescheduling resets the candidate's answer, and the sheet says so
///
/// The server sets the status back to `scheduled` on every edit, because an
/// interview moved to another time has not been confirmed whatever was said
/// about the old one. An employer nudging the time by ten minutes needs to know
/// that it costs them a confirmation, or they will do it and wonder why the
/// badge changed.
///
/// ## The type is radio rows, not a segmented control
///
/// Three segments at 360pt give each about 110pt, and "Личная встреча" does not
/// fit that on one line — the same measurement that kept §8.2's five status
/// filters off `HhSegmented`. Radio rows also carry the persistent label and
/// the 52px height the design asks of every control.
class _InterviewForm extends ConsumerStatefulWidget {
  const _InterviewForm({
    required this.applicationId,
    required this.platformOffset,
    this.existing,
  });

  final String applicationId;
  final Duration platformOffset;
  final Interview? existing;

  @override
  ConsumerState<_InterviewForm> createState() => _InterviewFormState();
}

class _InterviewFormState extends ConsumerState<_InterviewForm> {
  late String _type;
  late String? _date;
  late TimeOfDay? _time;

  final _location = TextEditingController();
  final _link = TextEditingController();
  final _instructions = TextEditingController();

  bool _busy = false;
  String? _refusal;

  bool get _isReschedule => widget.existing != null;

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;
    _type = existing?.type ?? InterviewType.phone;

    // The **platform** wall clock, which is what the employer set and what the
    // candidate reads. Not `.toLocal()`: an employer editing from another zone
    // would otherwise see the time shift under them the moment the form opened.
    final at = existing?.scheduledAt.wallClock;
    _date = at == null ? null : wallClockDay(at);
    _time = at == null ? null : TimeOfDay(hour: at.hour, minute: at.minute);

    _location.text = existing?.location ?? '';
    _link.text = existing?.meetingLink ?? '';
    _instructions.text = existing?.instructions ?? '';

    for (final c in [_location, _link, _instructions]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _location.dispose();
    _link.dispose();
    _instructions.dispose();
    super.dispose();
  }

  /// Whether the shape the server requires is satisfied.
  ///
  /// Mirrors `detailViolation` in `interview-rules.ts`: `in_person` needs a
  /// location, `external_link` needs a link, `phone` needs neither. Checked
  /// here so the button is inert rather than the request refused — but the
  /// server stays the authority, and it also enforces the *absence*, which
  /// switching the type below takes care of.
  bool get _complete {
    if (_date == null || _time == null) return false;

    return switch (_type) {
      InterviewType.inPerson => _location.text.trim().isNotEmpty,
      InterviewType.externalLink => _link.text.trim().isNotEmpty,
      _ => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        borderRadius: HhRadius.sheetTop,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: HhSpace.gutter,
            right: HhSpace.gutter,
            top: HhSpace.gutter,
            bottom: HhSpace.gutter + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: HhColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: HhSpace.lg),
                Text(
                  _isReschedule
                      ? l10n.interviewRescheduleFormTitle
                      : l10n.interviewScheduleTitle,
                  style: HhTypography.subtitle,
                ),

                if (_isReschedule) ...[
                  const SizedBox(height: HhSpace.sm),
                  Text(
                    l10n.interviewRescheduleResets,
                    style: HhTypography.body.copyWith(
                      color: HhColors.inkMuted,
                    ),
                  ),
                ],

                const SizedBox(height: HhSpace.lg),
                Text(l10n.interviewTypeLabel, style: HhTypography.label),
                const SizedBox(height: 6),
                for (final type in InterviewType.all)
                  HhRadioRow<String>(
                    label: interviewTypeLabel(type, l10n),
                    value: type,
                    groupValue: _type,
                    onChanged: _busy ? null : _pickType,
                  ),

                // The turquoise rail's one job: a block that exists because of
                // an earlier answer (§13 of the designer spec), captioned with
                // the option that revealed it.
                if (_type == InterviewType.inPerson) ...[
                  const SizedBox(height: HhSpace.md),
                  HhConditionalField(
                    trigger: interviewTypeLabel(_type, l10n),
                    child: HhTextField(
                      label: l10n.interviewWhere,
                      controller: _location,
                      hintText: l10n.interviewWhereHint,
                      maxLines: 2,
                      maxLength: 500,
                      enabled: !_busy,
                    ),
                  ),
                ],

                if (_type == InterviewType.externalLink) ...[
                  const SizedBox(height: HhSpace.md),
                  HhConditionalField(
                    trigger: interviewTypeLabel(_type, l10n),
                    child: HhTextField(
                      label: l10n.interviewLink,
                      controller: _link,
                      hintText: l10n.interviewLinkHint,
                      maxLength: 500,
                      enabled: !_busy,
                    ),
                  ),
                ],

                const SizedBox(height: HhSpace.md),
                IsoDateField(
                  label: l10n.interviewDateLabel,
                  value: _date,
                  enabled: !_busy,
                  // A past date is the server's to refuse in its own words;
                  // the picker only stops an accidental scroll back years.
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onChanged: (v) => setState(() => _date = v),
                ),

                const SizedBox(height: HhSpace.md),
                HhTextField(
                  label: l10n.interviewTimeLabel,
                  readOnly: true,
                  enabled: !_busy,
                  hintText: l10n.interviewTimeHint,
                  trailingIconPath: HhIconPath.clock,
                  trailingSemanticLabel: l10n.commonPickTime,
                  controller: TextEditingController(
                    text: _time == null
                        ? ''
                        : '${_two(_time!.hour)}:${_two(_time!.minute)}',
                  ),
                  onTap: _busy ? null : _pickTime,
                  onTrailingTap: _busy ? null : _pickTime,
                ),

                const SizedBox(height: HhSpace.md),
                HhTextField(
                  label: l10n.interviewInstructionsLabel,
                  controller: _instructions,
                  hintText: l10n.interviewInstructionsHint,
                  maxLines: 3,
                  maxLength: 2000,
                  enabled: !_busy,
                ),

                if (_refusal case final refusal?) ...[
                  const SizedBox(height: HhSpace.md),
                  HhNotice.restricted(
                    title: l10n.stateErrorTitle,
                    message: refusal,
                  ),
                ],

                const SizedBox(height: HhSpace.lg),
                HhButton(
                  label: _isReschedule
                      ? l10n.interviewRescheduleSave
                      : l10n.interviewScheduleSave,
                  loading: _busy,
                  onPressed: _complete ? _submit : null,
                ),
                const SizedBox(height: HhSpace.sm),
                HhButton.text(
                  label: l10n.commonCancel,
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Switching type **clears the other type's detail**.
  ///
  /// The server refuses a phone interview that carries a link and an in-person
  /// one that carries no address, so leaving the old value in the controller
  /// would either send a field the type forbids or hold a stale address behind
  /// a hidden field. Clearing makes `interview.detail_required` unreachable
  /// rather than merely unlikely — the same rule §8.2's compose screen applies
  /// when its invitation shape changes.
  void _pickType(String type) {
    setState(() {
      _type = type;
      if (type != InterviewType.inPerson) _location.clear();
      if (type != InterviewType.externalLink) _link.clear();
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  Future<void> _submit() async {
    final date = DateTime.parse(_date!);
    final time = _time!;

    // The picked fields are the **platform's** wall clock, and the offset comes
    // from a server timestamp. See `instantForPlatformWallClock`.
    final scheduledAt = instantForPlatformWallClock(
      wallClock: DateTime.utc(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
      platformOffset: widget.platformOffset,
    );

    setState(() {
      _busy = true;
      _refusal = null;
    });

    try {
      final repository = ref.read(interviewRepositoryProvider);
      final existing = widget.existing;

      final saved = existing == null
          ? await repository.schedule(
              widget.applicationId,
              type: _type,
              scheduledAt: scheduledAt,
              location: _location.text,
              meetingLink: _link.text,
              instructions: _instructions.text,
            )
          : await repository.reschedule(
              existing.id,
              type: _type,
              scheduledAt: scheduledAt,
              location: _location.text,
              meetingLink: _link.text,
              instructions: _instructions.text,
            );

      // The employer's own per-application list. The candidate's
      // `myInterviews` is a different account, so it is not this app's cache to
      // refresh — and BR-08's trail gained a row.
      ref
        ..invalidate(applicationInterviewsProvider(widget.applicationId))
        ..invalidate(interviewHistoryProvider(saved.id));

      if (mounted) Navigator.of(context).pop(saved);
    } on ApiException catch (e) {
      // Held in the sheet rather than thrown at a snackbar: a field violation
      // names a field, and that sentence belongs beside the form it is about.
      if (mounted) {
        setState(() {
          _refusal = e.message;
          _busy = false;
        });
      }
    }
  }
}

/// Calls an interview off, with the reason the **candidate** will read (§8.3).
///
/// Returns true when the server accepted it.
Future<bool> showCancelInterviewSheet(
  BuildContext context, {
  required Interview interview,
  required String applicationId,
}) async =>
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CancelSheet(
        interview: interview,
        applicationId: applicationId,
      ),
    ) ??
    false;

class _CancelSheet extends ConsumerStatefulWidget {
  const _CancelSheet({required this.interview, required this.applicationId});

  final Interview interview;
  final String applicationId;

  @override
  ConsumerState<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends ConsumerState<_CancelSheet> {
  final _reason = TextEditingController();
  bool _busy = false;
  String? _refusal;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        borderRadius: HhRadius.sheetTop,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: HhSpace.gutter,
            right: HhSpace.gutter,
            top: HhSpace.gutter,
            bottom: HhSpace.gutter + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: HhColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: HhSpace.lg),
                Text(
                  l10n.interviewCancelTitle,
                  style: HhTypography.subtitle,
                ),
                const SizedBox(height: HhSpace.sm),
                // Names the consequence rather than asking "are you sure?":
                // cancelling is §8.3's only ending, so nothing here can be
                // undone by either side afterwards.
                Text(
                  l10n.interviewCancelBody,
                  style: HhTypography.body.copyWith(color: HhColors.inkMuted),
                ),

                const SizedBox(height: HhSpace.lg),
                HhTextField(
                  label: l10n.interviewCancelReasonLabel,
                  controller: _reason,
                  hintText: l10n.interviewCancelReasonHint,
                  maxLines: 3,
                  maxLength: 1000,
                  enabled: !_busy,
                ),

                if (_refusal case final refusal?) ...[
                  const SizedBox(height: HhSpace.md),
                  HhNotice.restricted(
                    title: l10n.stateErrorTitle,
                    message: refusal,
                  ),
                ],

                const SizedBox(height: HhSpace.lg),
                HhButton.destructive(
                  label: l10n.interviewCancelAction,
                  loading: _busy,
                  onPressed: _cancel,
                ),
                const SizedBox(height: HhSpace.sm),
                HhButton.text(
                  label: l10n.commonCancel,
                  onPressed:
                      _busy ? null : () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cancel() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });

    final reason = _reason.text.trim();

    try {
      await ref.read(interviewRepositoryProvider).cancel(
        widget.interview.id,
        reason: reason.isEmpty ? null : reason,
      );

      ref
        ..invalidate(applicationInterviewsProvider(widget.applicationId))
        ..invalidate(interviewHistoryProvider(widget.interview.id));

      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _refusal = e.message;
          _busy = false;
        });
      }
    }
  }
}
