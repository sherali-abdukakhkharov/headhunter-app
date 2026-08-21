import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_dashboard.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint_action.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint_detail.dart';
import 'package:jobbridge_app/src/features/admin/domain/moderation_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/moderation_queue_item.dart';
import 'package:jobbridge_app/src/features/admin/domain/vacancy_review.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_queue_item.dart';

/// Every §10 route, refusing by default.
///
/// ## Why this exists rather than an `implements` per suite
///
/// Each admin suite fakes the whole repository and stubs the routes its screen
/// must not call with an `UnsupportedError` — which is the assertion, not
/// boilerplate: a verification test that silently fetched the moderation queue
/// would be testing something else.
///
/// The cost is that `implements AdminRepository` makes **every** suite fail to
/// compile when a route is added, so one new endpoint meant editing three
/// unrelated test files, and the complaint slice would have made that five
/// stubs each. Extending a base that refuses everything keeps the assertion —
/// an unstubbed call still throws, and still names itself — while a new route
/// is one edit here.
///
/// Subclasses override only what their screen is allowed to reach. Do not give
/// this class a working default for anything: a fake that quietly returns an
/// empty list is how a test passes without exercising the request it is about.
abstract class FakeAdminBase implements AdminRepository {
  Never _unused(String route) => throw UnsupportedError(
    'This suite must not call $route. Override it on the fake if the screen '
    'under test is meant to reach it.',
  );

  @override
  Future<AdminDashboard> dashboard({String? from, String? to}) =>
      _unused('dashboard');

  @override
  Future<List<VerificationQueueItem>> verificationQueue({int offset = 0}) =>
      _unused('verificationQueue');

  @override
  Future<void> decideVerification(
    String employerUserId,
    VerificationDecision decision, {
    String? reason,
  }) => _unused('decideVerification');

  @override
  Future<List<ModerationQueueItem>> moderationQueue({int offset = 0}) =>
      _unused('moderationQueue');

  @override
  Future<VacancyReview> vacancyForReview(String vacancyId) =>
      _unused('vacancyForReview');

  @override
  Future<void> moderateVacancy(
    String vacancyId,
    ModerationDecision decision, {
    String? reason,
  }) => _unused('moderateVacancy');

  @override
  Future<List<Complaint>> complaintQueue({
    ComplaintTarget? targetType,
    int offset = 0,
  }) => _unused('complaintQueue');

  @override
  Future<ComplaintDetail> complaint(String complaintId) =>
      _unused('complaint');

  @override
  Future<void> reviewComplaint(
    String complaintId,
    ComplaintOutcome outcome,
    String resolution,
  ) => _unused('reviewComplaint');

  @override
  Future<void> administrateVacancy(
    String vacancyId,
    VacancyAdminStatus status,
    String reason,
  ) => _unused('administrateVacancy');

  @override
  Future<void> warnUser(String userId, String reason) => _unused('warnUser');
}
