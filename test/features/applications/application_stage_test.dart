import 'package:flutter_test/flutter_test.dart';
import 'package:headhunter_app/src/features/applications/domain/application.dart';
import 'package:headhunter_app/src/features/applications/domain/application_stage.dart';

/// §8.1's stage rules — who may move where.
///
/// These decide which buttons exist, so getting one wrong either offers a move
/// the server refuses or hides one it would allow.
Application _application({String status = 'submitted'}) =>
    Application.fromJson({
      'id': 'a1',
      'vacancyId': 'v1',
      'candidateUserId': 'u1',
      'status': status,
      'createdAt': '2026-08-07T12:00:00+05:00',
      'updatedAt': '2026-08-07T12:00:00+05:00',
    });

void main() {
  group('employer stage moves are forward only', () {
    test('from submitted, every later stage is offered', () {
      // Skipping is allowed — real hiring skips, so submitted → offer is a
      // legitimate move and hiding it would be inventing a rule.
      expect(ApplicationStage.nextFor('submitted'), [
        'viewed',
        'shortlisted',
        'interview',
        'offer',
        'hired',
        'rejected',
      ]);
    });

    test('from interview, the earlier stages are gone', () {
      expect(ApplicationStage.nextFor('interview'), [
        'offer',
        'hired',
        'rejected',
      ]);
    });

    test('rejected is offered from every live stage', () {
      // A decision can be made at any point. It is an exit, not a step back.
      for (final stage in ['submitted', 'viewed', 'shortlisted', 'offer']) {
        expect(
          ApplicationStage.nextFor(stage),
          contains('rejected'),
          reason: 'from $stage',
        );
      }
    });

    test('nothing moves on from a terminal stage', () {
      for (final stage in ['hired', 'rejected', 'withdrawn']) {
        expect(
          ApplicationStage.nextFor(stage),
          isEmpty,
          reason: 'from $stage',
        );
      }
    });

    test('an unrecognised stage offers nothing rather than throwing', () {
      // A server that adds a seventh stage should grey the controls, not
      // crash the list — the same rule as an unknown field kind.
      expect(ApplicationStage.nextFor('some_future_stage'), isEmpty);
    });

    test('withdrawn is never employer-settable', () {
      // §8.1: it is the candidate's alone.
      for (final stage in ApplicationStage.progression) {
        expect(
          ApplicationStage.nextFor(stage),
          isNot(contains('withdrawn')),
          reason: 'from $stage',
        );
      }
    });

    test('submitted is never offered as a target', () {
      // It is where an application starts; moving back to it is backwards.
      for (final stage in ApplicationStage.progression) {
        expect(
          ApplicationStage.nextFor(stage),
          isNot(contains('submitted')),
          reason: 'from $stage',
        );
      }
    });
  });

  group('the candidate may withdraw', () {
    test('while the application is live', () {
      for (final stage in ['submitted', 'viewed', 'shortlisted', 'offer']) {
        expect(
          _application(status: stage).canWithdraw,
          isTrue,
          reason: 'at $stage',
        );
      }
    });

    test('but not once it is finished', () {
      // Nothing to withdraw from, and the server would refuse — so the action
      // is not offered rather than offered and rejected.
      for (final stage in ['hired', 'rejected', 'withdrawn']) {
        expect(
          _application(status: stage).canWithdraw,
          isFalse,
          reason: 'at $stage',
        );
      }
    });
  });
}
