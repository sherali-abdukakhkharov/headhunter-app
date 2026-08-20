import 'package:jobbridge_app/src/features/interviews/data/interview_repository.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview_status.dart';

/// An `InterviewRepository` that answers from memory (§8.3).
///
/// Shared rather than private to one test file because §8.3 now renders inside
/// **two** screens that other features own — the candidate's applications list
/// and the employer's applicants list — so any test pumping either of those has
/// to override this provider or the widget reaches for the network and leaves a
/// pending timer behind. That failure reads as a broken filter test rather than
/// as a missing override, which is exactly why the fake is importable.
class FakeInterviews implements InterviewRepository {
  FakeInterviews({this.items = const []});

  List<Interview> items;

  final responses = <(String id, String status, String? note)>[];

  /// Every write the employer side made, as the repository would have sent it.
  final scheduled = <Map<String, Object?>>[];
  final cancellations = <(String id, String? reason)>[];

  @override
  Future<List<Interview>> mine() async => items;

  @override
  Future<Interview> respond(String id, String status, {String? note}) async {
    responses.add((id, status, note));
    return items.firstWhere((i) => i.id == id);
  }

  @override
  Future<Interview> schedule(
    String applicationId, {
    required String type,
    required DateTime scheduledAt,
    String? location,
    String? meetingLink,
    String? instructions,
  }) async {
    scheduled.add({
      'applicationId': applicationId,
      'type': type,
      'scheduledAt': scheduledAt,
      'location': location,
      'meetingLink': meetingLink,
      'instructions': instructions,
    });
    return items.first;
  }

  @override
  Future<Interview> reschedule(
    String id, {
    required String type,
    required DateTime scheduledAt,
    String? location,
    String? meetingLink,
    String? instructions,
  }) async {
    scheduled.add({
      'id': id,
      'type': type,
      'scheduledAt': scheduledAt,
      'location': location,
      'meetingLink': meetingLink,
      'instructions': instructions,
    });
    return items.first;
  }

  @override
  Future<void> cancel(String id, {String? reason}) async =>
      cancellations.add((id, reason));

  @override
  Future<List<Interview>> forApplication(String applicationId) async =>
      items.where((i) => i.applicationId == applicationId).toList();

  @override
  Future<List<InterviewEvent>> history(String id) =>
      throw UnsupportedError('no history surface yet');
}

/// An interview fixture. Defaults to a phone interview awaiting an answer.
Interview interviewFixture({
  String id = 'iv-1',
  String applicationId = 'app-1',
  String type = InterviewType.phone,
  String status = InterviewStatus.scheduled,
  String scheduledAt = '2026-08-25T14:00:00+05:00',
  String? location,
  String? meetingLink,
  String? instructions,
  String? responseNote,
}) => Interview.fromJson({
  'id': id,
  'applicationId': applicationId,
  'type': type,
  'scheduledAt': scheduledAt,
  'location': location,
  'meetingLink': meetingLink,
  'instructions': instructions,
  'status': status,
  'responseNote': responseNote,
  'respondedAt': null,
  'createdAt': '2026-08-20T09:00:00+05:00',
  'updatedAt': '2026-08-20T09:00:00+05:00',
});
