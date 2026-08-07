import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/features/employer/data/employer_controller.dart';
import 'package:headhunter_app/src/features/employer/domain/employer_profile.dart';

/// The badge for one of §6.1's five verification states.
///
/// One function rather than a `switch` at each call site, because the design
/// system's named constructors *are* the vocabulary and a sixth state added
/// server-side should surface in one place. An unrecognised status falls back
/// to "not submitted" rather than throwing — the same rule as an unknown field
/// kind, for the same reason.
Widget verificationBadge(String status, AppL10n l10n) => switch (status) {
  'under_review' => HhBadge.verificationUnderReview(
    label: l10n.employerVerificationUnderReview,
  ),
  'verified' => HhBadge.verificationVerified(
    label: l10n.employerVerificationVerified,
  ),
  'rejected' => HhBadge.verificationRejected(
    label: l10n.employerVerificationRejected,
  ),
  'changes_required' => HhBadge.verificationChangesRequired(
    label: l10n.employerVerificationChangesRequired,
  ),
  _ => HhBadge.verificationNotSubmitted(
    label: l10n.employerVerificationNotSubmitted,
  ),
};

/// Verification state, the administrator's reason, and the submit action
/// (§6.1).
///
/// ## The reason is shown verbatim
///
/// It is human text an administrator wrote, already in the language they wrote
/// it in — **not** a translatable key, and §2.4 forbids translating
/// user-entered content. Rendering it any other way would either lose it or
/// mistranslate it.
///
/// ## What blocks submission is stated, not implied
///
/// The server refuses a submission from an incomplete profile, and refuses a
/// second one while an attempt is under review. Both are visible here rather
/// than being discovered by pressing a button that fails.
class VerificationCard extends ConsumerWidget {
  const VerificationCard({required this.dirty, super.key});

  /// True when the form has unsaved changes. The server verifies what it has
  /// stored, not what is on screen, so submitting now would review the old
  /// details — worth saying rather than silently allowing.
  final bool dirty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(verificationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.employerVerification, style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),

        switch (state) {
          AsyncValue(hasError: true, :final error?) => HhErrorState(
            title: l10n.stateErrorTitle,
            message: error is ApiException
                ? error.message
                : l10n.stateErrorBody,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(verificationProvider),
          ),
          AsyncData(:final value) => _Body(state: value, dirty: dirty),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ],
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.state, required this.dirty});

  final VerificationState state;
  final bool dirty;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = widget.state;

    return HhCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verificationBadge(state.status, l10n),

          if (state.reason case final reason? when reason.isNotEmpty) ...[
            const SizedBox(height: HhSpace.md),
            // Verbatim: the administrator's own words, never translated.
            Text(reason, style: HhTypography.body),
          ],

          if (state.requiredEvidence.isNotEmpty) ...[
            const SizedBox(height: HhSpace.lg),
            Text(
              l10n.employerEvidence,
              style: HhTypography.label.copyWith(color: HhColors.inkMuted),
            ),
            const SizedBox(height: HhSpace.sm),
            // Served rather than hardcoded — §6.1 leaves the policy open, so
            // which documents are demanded can change without a release.
            for (final evidence in state.requiredEvidence)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        evidence.purposeCode,
                        style: HhTypography.body,
                      ),
                    ),
                    Text(
                      evidence.required
                          ? l10n.employerEvidenceRequired
                          : l10n.employerEvidenceOptional,
                      style: HhTypography.caption.copyWith(
                        color: evidence.required
                            ? HhColors.warning
                            : HhColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],

          if (widget.dirty) ...[
            const SizedBox(height: HhSpace.md),
            Text(
              l10n.employerSaveFirst,
              style: HhTypography.caption.copyWith(color: HhColors.warning),
            ),
          ],

          if (state.canSubmit) ...[
            const SizedBox(height: HhSpace.md),
            HhButton.secondary(
              label: l10n.employerSubmitVerification,
              loading: _submitting,
              // Blocked while the form is dirty: the server reviews what it
              // has stored, so submitting now would put the *old* details in
              // front of an administrator.
              onPressed: widget.dirty || _submitting ? null : _submit,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _submitting = true);

    try {
      // No file ids yet: evidence upload goes through `POST /files` and is the
      // next slice. The server refuses the submission when it requires a
      // document, and says which — so the refusal is informative rather than
      // this pretending the button is not there.
      await ref.read(verificationProvider.notifier).submit(const []);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
