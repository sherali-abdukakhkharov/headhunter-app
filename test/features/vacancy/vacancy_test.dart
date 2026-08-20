import 'package:flutter_test/flutter_test.dart';
import 'package:jobbridge_app/src/features/vacancy/domain/vacancy.dart';

/// Vacancy status rules (§6.4, BR-06, BR-11).
///
/// These are the questions the buttons ask, so getting one wrong offers an
/// action the server will refuse — or hides one it would allow.
Vacancy _vacancy({
  String status = 'draft',
  List<String> missing = const [],
  bool open = false,
}) => Vacancy.fromJson({
  'id': 'v1',
  'status': status,
  'fields': const <String, dynamic>{},
  'missingForSubmit': missing,
  'isOpenForApplications': open,
  'hiredCount': 0,
});

void main() {
  group('editability', () {
    test('a draft is editable', () {
      expect(_vacancy().isEditable, isTrue);
    });

    test('a vacancy under moderation is not', () {
      // The server answers `vacancy.under_moderation`, so the form is
      // read-only rather than accepting keystrokes it cannot save.
      expect(_vacancy(status: 'under_moderation').isEditable, isFalse);
    });

    test('a closed vacancy is not', () {
      expect(_vacancy(status: 'closed').isEditable, isFalse);
    });

    test('a rejected vacancy is editable — that is the correction path', () {
      // §6.4: editing a rejected vacancy returns it to draft.
      expect(_vacancy(status: 'rejected').isEditable, isTrue);
    });
  });

  group('submitting', () {
    test('is offered from draft and from rejected', () {
      expect(_vacancy().isSubmittable, isTrue);
      expect(_vacancy(status: 'rejected').isSubmittable, isTrue);
    });

    test('is not offered from a state that cannot reach moderation', () {
      for (final status in ['under_moderation', 'active', 'paused', 'closed']) {
        expect(
          _vacancy(status: status).isSubmittable,
          isFalse,
          reason: 'from $status',
        );
      }
    });
  });

  group('§6.4 employer transitions', () {
    test('an active vacancy can be paused or closed', () {
      expect(_vacancy(status: 'active').employerTransitions, [
        'paused',
        'closed',
      ]);
    });

    test('a paused vacancy can be resumed or closed', () {
      expect(_vacancy(status: 'paused').employerTransitions, [
        'active',
        'closed',
      ]);
    });

    test('closing is terminal — nothing is offered from closed (BR-11)', () {
      // A closed vacancy leaves discovery and stays in history. Offering a
      // way back would be offering something the server refuses.
      expect(_vacancy(status: 'closed').employerTransitions, isEmpty);
    });

    test('a draft has no status transitions, only submission', () {
      expect(_vacancy().employerTransitions, isEmpty);
    });

    test('nothing is offered while under moderation', () {
      expect(_vacancy(status: 'under_moderation').employerTransitions, isEmpty);
    });
  });

  group('BR-06 is read, not re-derived', () {
    test('the server decides whether applications are accepted', () {
      // Active *and* within any deadline. The client renders the server's
      // answer rather than recomputing it from status alone, because a live
      // vacancy past its deadline is active and closed to applications at the
      // same time.
      expect(_vacancy(status: 'active').isOpenForApplications, isFalse);
      expect(
        _vacancy(status: 'active', open: true).isOpenForApplications,
        isTrue,
      );
    });
  });

  test('missingForSubmit is carried so it can be shown before the refusal', () {
    final vacancy = _vacancy(missing: const ['title', 'worker_count']);

    expect(vacancy.missingForSubmit, ['title', 'worker_count']);
  });
}
