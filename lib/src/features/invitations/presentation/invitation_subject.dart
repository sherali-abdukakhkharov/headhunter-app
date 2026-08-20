import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/dictionaries/data/dictionary_providers.dart';
import 'package:jobbridge_app/src/features/dictionaries/domain/dictionary_type.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';
import 'package:jobbridge_app/src/features/invitations/presentation/invitation_format.dart';

/// What a **general** invitation says, resolved from ids (§8.2, BR-13).
///
/// Shared by both sides of §8.2 for the same reason `wallClockStamp` is: the
/// candidate's inbox and the employer's sent list are two views of one
/// resource, and an employer who cannot see what the candidate is reading has
/// no way to answer a question about it.
///
/// The **vacancy** shape is deliberately *not* shared. Its subject is a
/// posting, and the only route that returns one to a candidate is
/// `GET /discovery/vacancies/:id` on a controller carrying
/// `@RequireRole('candidate')` — an employer calling it gets 403, not a title.
/// The employer's side resolves its own postings out of `myVacanciesProvider`
/// instead: one request for the whole list, then a local lookup, which is also
/// one request rather than one per row.
class InvitationGeneralSubject extends StatelessWidget {
  const InvitationGeneralSubject({required this.invitation, super.key});

  final Invitation invitation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Named as general before anything else, because the absence of a
        // vacancy is the first thing to know: there is no posting to read and
        // no deadline to meet.
        Text(l10n.invitationGeneral, style: HhTypography.overline),
        if (invitation.occupationId case final id?)
          InvitationDictionaryLine(
            type: DictionaryType.occupation,
            id: id,
            style: HhTypography.subtitle,
          ),

        // District in preference to region, as everywhere else: the narrower
        // answer is the useful one, and both are ids in the **`region`**
        // dictionary — districts are its children (§5.1), not a type of their
        // own.
        if (invitation.districtId ?? invitation.regionId case final id?)
          InvitationDictionaryLine(type: DictionaryType.region, id: id),

        if (invitationPay(invitation, l10n) case final pay?)
          Text(pay, style: HhTypography.body),

        if (invitation.scheduleNote case final note? when note.isNotEmpty)
          // Free text by design (§8.2), and the employer's words (§2.4).
          Text(note, style: HhTypography.body),
      ],
    );
  }
}

/// One dictionary id, shown as a word (BR-13).
class InvitationDictionaryLine extends ConsumerWidget {
  const InvitationDictionaryLine({
    required this.type,
    required this.id,
    super.key,
    this.style,
  });

  final String type;
  final String id;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(resolvedLabelsProvider(type, labelKey([id])));

    // An id the server cannot resolve either renders as nothing rather than as
    // a UUID: a raw id tells a reader less than an absent line does.
    return switch (labels) {
      AsyncData(:final value) when value[id] != null => Text(
        value[id]!.label,
        style: style ?? HhTypography.body,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
