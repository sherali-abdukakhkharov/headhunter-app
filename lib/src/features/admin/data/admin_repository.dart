import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_dashboard.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint_action.dart';
import 'package:jobbridge_app/src/features/admin/domain/complaint_detail.dart';
import 'package:jobbridge_app/src/features/admin/domain/moderation_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/moderation_queue_item.dart';
import 'package:jobbridge_app/src/features/admin/domain/vacancy_review.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_decision.dart';
import 'package:jobbridge_app/src/features/admin/domain/verification_queue_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_repository.g.dart';

/// How many queue items one page holds. The server caps a page at 100.
const adminPageSize = 20;

/// §10's administration API, all of it behind `@RequireRole('admin')`.
///
/// ## There is no web panel, so these are ordinary endpoints
///
/// §2.4 rules one out permanently and §10 puts administration "inside the same
/// mobile application behind an authorized role". Nothing here is privileged in
/// a way the rest of the app is not: the acting role travels in the access
/// token, which is why a role switch has to tell the server
/// (`POST /auth/active-role`) before any of this will answer.
class AdminRepository {
  const AdminRepository(this._dio);

  final Dio _dio;

  /// `GET /admin/dashboard` — §10.1's counters in one request.
  ///
  /// Both dates are optional and **omitted by default**, because the server's
  /// default period is the last thirty days *in the platform time zone* and the
  /// client has no honest way to compute that. See [DashboardRange].
  Future<AdminDashboard> dashboard({String? from, String? to}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/admin/dashboard',
        queryParameters: {'from': ?from, 'to': ?to},
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return AdminDashboard.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /admin/verification` — employers awaiting a decision (§10.2).
  ///
  /// **Oldest first, and the client must not re-sort.** A queue that is not
  /// FIFO is a queue somebody waits in indefinitely, which is the server's own
  /// reasoning for the ordering; sorting by name here would quietly undo it.
  Future<List<VerificationQueueItem>> verificationQueue({
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/admin/verification',
        queryParameters: {'limit': adminPageSize, 'offset': offset},
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return items
          .whereType<Map<String, dynamic>>()
          .map(VerificationQueueItem.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /admin/verification/:employerUserId` — approve, reject, or send back.
  ///
  /// No idempotency key, and none is wanted: the route is a **transition**, so
  /// a retry that arrives after the first succeeded answers 409
  /// `employer.verification_not_pending` rather than deciding twice. The state
  /// machine is the natural key, exactly as `(employer, candidate)` is for a
  /// Candidate Unlock.
  ///
  /// Throws [AdminDecisionConflict] on that 409, because it is the normal
  /// outcome of two administrators working one queue rather than a fault.
  Future<void> decideVerification(
    String employerUserId,
    VerificationDecision decision, {
    String? reason,
  }) async {
    try {
      await _dio.post<void>(
        '/admin/verification/$employerUserId',
        data: {'decision': decision.wire, 'reason': ?reason},
      );
    } on DioException catch (e) {
      throw _alreadyDecided(e, 'employer.verification_not_pending') ??
          ApiException.fromDioException(e);
    }
  }

  /// `GET /admin/moderation` — vacancies awaiting a decision (§10.2, BR-04).
  ///
  /// Oldest first, like the verification queue, and for the same reason.
  Future<List<ModerationQueueItem>> moderationQueue({int offset = 0}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/admin/moderation',
        queryParameters: {'limit': adminPageSize, 'offset': offset},
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return items
          .whereType<Map<String, dynamic>>()
          .map(ModerationQueueItem.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /admin/moderation/:vacancyId` — the vacancy, in full, for review.
  ///
  /// The one route in this repository whose response is **not** a DTO: see
  /// [VacancyReview] for what arrives and why the client reads two spellings of
  /// it. A 404 means the vacancy is gone, which the caller renders as an
  /// ordinary outcome rather than a fault.
  Future<VacancyReview> vacancyForReview(String vacancyId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/admin/moderation/$vacancyId',
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return VacancyReview.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /admin/moderation/:vacancyId` — publish it, or send it back (BR-04).
  ///
  /// No idempotency key, for the same reason as the verification decision: the
  /// route is a transition, so a retry that lands after the first succeeded
  /// answers 409 `vacancy.not_under_moderation` rather than deciding twice.
  Future<void> moderateVacancy(
    String vacancyId,
    ModerationDecision decision, {
    String? reason,
  }) async {
    try {
      await _dio.post<void>(
        '/admin/moderation/$vacancyId',
        data: {'decision': decision.wire, 'reason': ?reason},
      );
    } on DioException catch (e) {
      throw _alreadyDecided(e, 'vacancy.not_under_moderation') ??
          ApiException.fromDioException(e);
    }
  }

  /// `GET /admin/complaints` — open complaints over all four target kinds.
  ///
  /// **One queue, not four**, which is the server's own design: M6 made
  /// `complaints` a generic table so §10.2 reviews reported users, vacancies,
  /// messages and profiles from one place. Oldest first, like the other two.
  ///
  /// [targetType] is the server's filter and is left unused for now — see
  /// `ComplaintQueueList` for why a four-way filter is not a segmented
  /// control. It is on the signature because the route takes it and a caller
  /// that wants one queue's worth should not have to widen this first.
  Future<List<Complaint>> complaintQueue({
    ComplaintTarget? targetType,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/admin/complaints',
        queryParameters: {
          'limit': adminPageSize,
          'offset': offset,
          // Never the `unknown` sentinel: it is a client-side fallback for a
          // value this build does not know, and sending its empty wire string
          // would be a filter the server rejects.
          if (targetType != null && targetType != ComplaintTarget.unknown)
            'targetType': targetType.wire,
        },
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return items
          .whereType<Map<String, dynamic>>()
          .map(Complaint.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /admin/complaints/:id` — the complaint and enough of its target.
  ///
  /// A 404 (`complaint.not_found`) is rendered as an outcome rather than a
  /// fault, like the vacancy review's.
  Future<ComplaintDetail> complaint(String complaintId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/admin/complaints/$complaintId',
      );

      final data = response.data;
      if (data == null) {
        throw const ApiException('The server returned an empty response.');
      }

      return ComplaintDetail.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /admin/complaints/:id/review` — action it, or dismiss it (§10.2).
  ///
  /// [resolution] is required by the server on **both** outcomes, so it is a
  /// positional argument rather than an optional one: a `String?` here would
  /// let a caller send a dismissal with nothing recorded and learn about it
  /// from a 403.
  ///
  /// Throws [AdminDecisionConflict] on 409 `complaint.not_open` — two
  /// administrators working one queue, and the work is done either way.
  Future<void> reviewComplaint(
    String complaintId,
    ComplaintOutcome outcome,
    String resolution,
  ) async {
    try {
      await _dio.post<void>(
        '/admin/complaints/$complaintId/review',
        data: {'outcome': outcome.wire, 'resolution': resolution},
      );
    } on DioException catch (e) {
      throw _alreadyDecided(e, 'complaint.not_open') ??
          ApiException.fromDioException(e);
    }
  }

  /// `PUT /admin/vacancies/:vacancyId/status` — pause or remove a **live**
  /// vacancy (§10.2).
  ///
  /// The route §10.2 asks for and nothing could reach until now: the
  /// moderation queue only ever holds `under_moderation`, and this applies to
  /// a vacancy already published. A complaint about one is the way in.
  ///
  /// Its 409 is `vacancy.transition_not_allowed` and it is **deliberately not**
  /// mapped to [AdminDecisionConflict]. That conflict means "somebody decided
  /// this before you and the work is done"; this one means the vacancy is not
  /// in a state the action applies to — already closed, never published — and
  /// telling an administrator their colleague handled it would send them
  /// looking for a decision nobody made. The server's own message says which,
  /// and the client offers the action only where the transition table allows
  /// it (see [VacancyAdminStatus.availableFor]), so this 409 means the
  /// vacancy moved under the screen.
  Future<void> administrateVacancy(
    String vacancyId,
    VacancyAdminStatus status,
    String reason,
  ) async {
    try {
      await _dio.put<void>(
        '/admin/vacancies/$vacancyId/status',
        data: {'status': status.wire, 'reason': reason},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /admin/users/:userId/warn` — the mild remedy (§10.4).
  ///
  /// Changes no account status: the audit row **is** the record, which is the
  /// proportionate answer to an upheld complaint that does not warrant
  /// restricting somebody. Restrict, block and unblock live on
  /// `PUT /admin/users/:userId/status` and land with §10.4's user screen,
  /// because a temporary restriction needs an until-date and this does not.
  Future<void> warnUser(String userId, String reason) async {
    try {
      await _dio.post<void>(
        '/admin/users/$userId/warn',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// The 409 that means the queue moved, or null for anything else.
  ///
  /// Matched on `code` and not on the status alone. 409 is also what a
  /// concurrent write elsewhere in this API means, and telling an administrator
  /// "somebody decided it already" about a different conflict would send them
  /// looking for a decision nobody made. [code] is passed in rather than
  /// matched against a set, so a route cannot accidentally accept the other
  /// route's conflict as its own.
  AdminDecisionConflict? _alreadyDecided(DioException e, String code) {
    if (e.response?.statusCode != 409) return null;

    final data = e.response?.data;
    if (data is! Map || data['code'] != code) return null;

    return AdminDecisionConflict(ApiException.fromDioException(e).message);
  }
}

@riverpod
AdminRepository adminRepository(Ref ref) =>
    AdminRepository(ref.watch(dioProvider));

/// The period the §10.1 dashboard is showing, or null for the server's default.
///
/// A provider of its own rather than a field on the dashboard notifier, so that
/// refreshing the figures keeps the period. Folding the two together would make
/// a pull-to-refresh silently reset the range an administrator had chosen —
/// same numbers, different question, and nothing on screen to say so.
@riverpod
class DashboardRangeController extends _$DashboardRangeController {
  @override
  DashboardRange? build() => null;

  /// Shows the [days]-day window ending on the day the server last echoed.
  ///
  /// [endingOn] comes from `period.to` of the response on screen, never from
  /// `DateTime.now()`: today is a platform-zone fact and the device's answer
  /// can differ by a day at each end.
  void showLastDays(int days, {required DateTime endingOn}) =>
      state = DashboardRange.lastDays(days, endingOn: endingOn);

  /// Back to whatever the server considers default.
  void reset() => state = null;
}

/// §10.1's counters for the selected period.
@riverpod
Future<AdminDashboard> adminDashboard(Ref ref) {
  final range = ref.watch(dashboardRangeControllerProvider);

  return ref
      .watch(adminRepositoryProvider)
      .dashboard(from: range?.fromWire, to: range?.toWire);
}

/// One loaded stretch of an admin queue.
///
/// The same shape as the Coin ledger's page, and for the same reason: an append
/// that fails leaves the items already on screen perfectly valid, so folding
/// the failure into `AsyncError` would replace a working queue with an error
/// page over one missing page.
///
/// Generic because §10.2 has two queues with identical paging and identical
/// removal semantics, and the only thing that differs is what identifies a row.
@immutable
class AdminQueuePage<T> {
  const AdminQueuePage({
    required this.items,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<T> items;

  /// Whether the last page came back **full**, which is the only evidence the
  /// client has that another one exists — the endpoint returns no total.
  final bool hasMore;

  final bool isLoadingMore;

  AdminQueuePage<T> copyWith({bool? isLoadingMore}) => AdminQueuePage<T>(
    items: items,
    hasMore: hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  /// The page with [items] replaced, keeping [hasMore].
  ///
  /// Used to drop a decided row **without re-reading the queue**: the server's
  /// ordering means everything above it is older, so a refetch would reshuffle
  /// nothing and cost a request — and it would move the list under the finger
  /// of an administrator working down a page, which is how the next row gets
  /// decided by accident. The dashboard's counter is invalidated instead,
  /// because that figure genuinely did change.
  AdminQueuePage<T> withItems(List<T> items) =>
      AdminQueuePage<T>(items: items, hasMore: hasMore);
}

/// §10.2's employer verification queue, oldest first.
@riverpod
class VerificationQueue extends _$VerificationQueue {
  @override
  Future<AdminQueuePage<VerificationQueueItem>> build() async {
    final items = await ref
        .watch(adminRepositoryProvider)
        .verificationQueue();

    return AdminQueuePage(
      items: items,
      hasMore: items.length == adminPageSize,
    );
  }

  /// Appends the next page, and **rethrows** so the caller can say so over a
  /// queue that is still on screen.
  Future<void> loadMore() async {
    final page = state.value;
    if (page == null || page.isLoadingMore || !page.hasMore) return;

    state = AsyncData(page.copyWith(isLoadingMore: true));

    try {
      final next = await ref
          .read(adminRepositoryProvider)
          .verificationQueue(offset: page.items.length);

      state = AsyncData(
        AdminQueuePage(
          items: [...page.items, ...next],
          hasMore: next.length == adminPageSize,
        ),
      );
    } on ApiException {
      state = AsyncData(page.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  /// Drops one decided employer — see [AdminQueuePage.withItems].
  void remove(String employerUserId) {
    final page = state.value;
    if (page == null) return;

    state = AsyncData(
      page.withItems(
        page.items
            .where((item) => item.employerUserId != employerUserId)
            .toList(),
      ),
    );
  }
}

/// §10.2's vacancy moderation queue, oldest first (BR-04).
@riverpod
class ModerationQueue extends _$ModerationQueue {
  @override
  Future<AdminQueuePage<ModerationQueueItem>> build() async {
    final items = await ref.watch(adminRepositoryProvider).moderationQueue();

    return AdminQueuePage(
      items: items,
      hasMore: items.length == adminPageSize,
    );
  }

  Future<void> loadMore() async {
    final page = state.value;
    if (page == null || page.isLoadingMore || !page.hasMore) return;

    state = AsyncData(page.copyWith(isLoadingMore: true));

    try {
      final next = await ref
          .read(adminRepositoryProvider)
          .moderationQueue(offset: page.items.length);

      state = AsyncData(
        AdminQueuePage(
          items: [...page.items, ...next],
          hasMore: next.length == adminPageSize,
        ),
      );
    } on ApiException {
      state = AsyncData(page.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  /// Drops one decided vacancy — see [AdminQueuePage.withItems].
  void remove(String vacancyId) {
    final page = state.value;
    if (page == null) return;

    state = AsyncData(
      page.withItems(
        page.items.where((item) => item.vacancyId != vacancyId).toList(),
      ),
    );
  }
}

/// §10.2's complaint queue, oldest first, all four target kinds together.
@riverpod
class ComplaintQueue extends _$ComplaintQueue {
  @override
  Future<AdminQueuePage<Complaint>> build() async {
    final items = await ref.watch(adminRepositoryProvider).complaintQueue();

    return AdminQueuePage(
      items: items,
      hasMore: items.length == adminPageSize,
    );
  }

  Future<void> loadMore() async {
    final page = state.value;
    if (page == null || page.isLoadingMore || !page.hasMore) return;

    state = AsyncData(page.copyWith(isLoadingMore: true));

    try {
      final next = await ref
          .read(adminRepositoryProvider)
          .complaintQueue(offset: page.items.length);

      state = AsyncData(
        AdminQueuePage(
          items: [...page.items, ...next],
          hasMore: next.length == adminPageSize,
        ),
      );
    } on ApiException {
      state = AsyncData(page.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  /// Drops one reviewed complaint — see [AdminQueuePage.withItems].
  void remove(String complaintId) {
    final page = state.value;
    if (page == null) return;

    state = AsyncData(
      page.withItems(
        page.items.where((item) => item.id != complaintId).toList(),
      ),
    );
  }
}

/// One complaint and its target, loaded for §10.2's review.
///
/// Keyed by id for the same reason the vacancy review is: it is read once per
/// screen, never appended to, and two reviews open in a session must not
/// overwrite each other.
@riverpod
Future<ComplaintDetail> complaintDetail(Ref ref, String complaintId) =>
    ref.watch(adminRepositoryProvider).complaint(complaintId);

/// One vacancy, loaded for §10.2's review.
///
/// A family rather than a notifier: unlike a queue this is read once per screen
/// and never appended to, and keying it by id is what lets a moderator open two
/// reviews in a session without the second overwriting the first.
@riverpod
Future<VacancyReview> vacancyForReview(Ref ref, String vacancyId) =>
    ref.watch(adminRepositoryProvider).vacancyForReview(vacancyId);
