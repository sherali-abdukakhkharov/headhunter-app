import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation_status.dart';

Invitation _invitation({
  required String status,
  String? vacancyId,
  String? occupationId,
  int? salaryFrom,
  int? salaryTo,
  bool salaryIsNegotiable = false,
  String? respondedAt,
}) => Invitation.fromJson({
  'id': 'inv-1',
  'employerUserId': 'emp-1',
  'candidateUserId': 'cand-1',
  'status': status,
  'vacancyId': vacancyId,
  'occupationId': occupationId,
  'regionId': null,
  'districtId': null,
  'salaryFrom': salaryFrom,
  'salaryTo': salaryTo,
  'salaryPeriodId': null,
  'salaryIsNegotiable': salaryIsNegotiable,
  'scheduleNote': null,
  'message': null,
  'responseNote': null,
  'respondedAt': respondedAt,
  'createdAt': '2026-08-18T09:30:00+05:00',
  'updatedAt': '2026-08-18T09:30:00+05:00',
});

void main() {
  group('§8.2 mirrors the server, and a test says so', () {
    // These four lists are the same rule written twice in two languages —
    // `invitation-status.ts` on the server and `InvitationStatus` here. Pinned
    // because they are the sort of thing that drifts silently: nothing fails at
    // compile time when the client keeps offering a transition the server has
    // stopped accepting.
    test('the four statuses are exactly the server enum', () {
      expect(
        {
          InvitationStatus.sent,
          InvitationStatus.detailsRequested,
          InvitationStatus.accepted,
          InvitationStatus.declined,
        },
        {'sent', 'details_requested', 'accepted', 'declined'},
      );
    });

    test('only accepted and declined are terminal', () {
      expect(InvitationStatus.terminal, {'accepted', 'declined'});
    });

    test('details_requested is a question, not an ending', () {
      // The reason this matters: a candidate who asks for details must still be
      // able to answer. Treating the question as terminal would strand them.
      expect(
        InvitationStatus.terminal.contains(InvitationStatus.detailsRequested),
        isFalse,
      );
      expect(
        InvitationStatus.responsesFor(InvitationStatus.detailsRequested),
        containsAll([InvitationStatus.accepted, InvitationStatus.declined]),
      );
    });

    test('asking twice is refused', () {
      // `to != from` is what does this, and it is also what refuses accepting
      // something already accepted — which a retrying client would otherwise
      // turn into a second history row.
      expect(
        InvitationStatus.canRespond(
          InvitationStatus.detailsRequested,
          InvitationStatus.detailsRequested,
        ),
        isFalse,
      );
      expect(
        InvitationStatus.responsesFor(InvitationStatus.detailsRequested),
        isNot(contains(InvitationStatus.detailsRequested)),
      );
    });

    test('an answered invitation offers nothing', () {
      for (final status in InvitationStatus.terminal) {
        expect(
          InvitationStatus.responsesFor(status),
          isEmpty,
          reason: '$status is terminal and must offer no action',
        );
      }
    });

    test('an unrecognised status offers nothing rather than throwing', () {
      // A fifth status from a newer server should grey the controls, not crash
      // the inbox — the same rule as an unknown schema field kind. It is not
      // terminal either, so it is deliberately *not* treated as answered.
      expect(
        InvitationStatus.canRespond('escalated', InvitationStatus.accepted),
        isTrue,
        reason: 'unknown is not terminal, so responding is still allowed',
      );
      expect(
        InvitationStatus.canRespond(InvitationStatus.accepted, 'escalated'),
        isFalse,
        reason: 'the client must never invent a transition',
      );
    });

    test('the client never offers a status the candidate cannot set', () {
      // Everything reachable from any starting point is one of §8.2's three
      // candidate actions. `sent` is the employer's and must never appear.
      final offered = {
        for (final from in [
          InvitationStatus.sent,
          InvitationStatus.detailsRequested,
          'escalated',
        ])
          ...InvitationStatus.responsesFor(from),
      };

      expect(offered, isNot(contains(InvitationStatus.sent)));
      expect(
        offered.difference(InvitationStatus.candidateResponses.toSet()),
        isEmpty,
      );
    });
  });

  group('the two shapes of §8.2', () {
    test('a vacancy id makes it a vacancy invitation', () {
      final invitation = _invitation(
        status: InvitationStatus.sent,
        vacancyId: 'vac-1',
      );

      expect(invitation.isGeneral, isFalse);
      expect(invitation.vacancyId, 'vac-1');
    });

    test('no vacancy id makes it general', () {
      // `isGeneral` is a null test rather than a flag the server sends: a flag
      // could disagree with the ids beside it, and this cannot.
      final invitation = _invitation(
        status: InvitationStatus.sent,
        occupationId: 'occ-1',
      );

      expect(invitation.isGeneral, isTrue);
    });
  });

  group('acceptance is what opens contact (BR-09)', () {
    test('only accepted opens it', () {
      for (final status in [
        InvitationStatus.sent,
        InvitationStatus.detailsRequested,
        InvitationStatus.declined,
      ]) {
        expect(
          _invitation(status: status, vacancyId: 'v').opensContact,
          isFalse,
          reason: '$status must not read as an entitlement',
        );
      }

      expect(
        _invitation(
          status: InvitationStatus.accepted,
          vacancyId: 'v',
        ).opensContact,
        isTrue,
      );
    });

    test('a merely sent invitation is not an interaction the candidate agreed '
        'to', () {
      // The server agrees: on a sent-but-unanswered invitation it answers
      // `exposureReason: unlock_required`, not `accepted_invitation`. Inviting
      // somebody is not consent from them.
      final sent = _invitation(status: InvitationStatus.sent, vacancyId: 'v');

      expect(sent.opensContact, isFalse);
      expect(sent.isOpen, isTrue);
    });
  });

  group('timestamps keep the platform wall clock (§8.3)', () {
    test('the offset is retained rather than normalised away', () {
      // `DateTime.parse` would return 04:30 UTC and `.toLocal()` would then
      // render in the *device* zone — two hours early for a candidate in
      // Moscow, which is the one bug in this feature that costs somebody a job.
      final invitation = _invitation(
        status: InvitationStatus.sent,
        vacancyId: 'v',
      );

      expect(invitation.createdAt.wallClock.hour, 9);
      expect(invitation.createdAt.wallClock.minute, 30);
      expect(invitation.createdAt.offset, const Duration(hours: 5));
    });

    test('respondedAt is null until it is answered, and parsed when it is', () {
      expect(
        _invitation(status: InvitationStatus.sent, vacancyId: 'v').respondedAt,
        isNull,
      );

      final answered = _invitation(
        status: InvitationStatus.accepted,
        vacancyId: 'v',
        respondedAt: '2026-08-19T14:05:00+05:00',
      );

      expect(answered.respondedAt?.wallClock.hour, 14);
    });
  });
}
