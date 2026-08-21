import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_dashboard.dart';
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
  /// Throws [VerificationAlreadyDecided] on that 409, because it is the normal
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
      final conflict = _alreadyDecided(e);
      if (conflict != null) throw conflict;

      throw ApiException.fromDioException(e);
    }
  }

  /// The 409 that means the queue moved, or null for anything else.
  ///
  /// Matched on `code` and not on the status alone. 409 is also what a
  /// concurrent write elsewhere in this API means, and telling an administrator
  /// "somebody decided it already" about a different conflict would send them
  /// looking for a decision nobody made.
  VerificationAlreadyDecided? _alreadyDecided(DioException e) {
    if (e.response?.statusCode != 409) return null;

    final data = e.response?.data;
    if (data is! Map || data['code'] != 'employer.verification_not_pending') {
      return null;
    }

    return VerificationAlreadyDecided(ApiException.fromDioException(e).message);
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

/// One loaded stretch of §10.2's verification queue.
///
/// The same shape as the Coin ledger's page, and for the same reason: an append
/// that fails leaves the items already on screen perfectly valid, so folding
/// the failure into `AsyncError` would replace a working queue with an error
/// page over one missing page.
@immutable
class VerificationQueuePage {
  const VerificationQueuePage({
    required this.items,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<VerificationQueueItem> items;

  /// Whether the last page came back **full**, which is the only evidence the
  /// client has that another one exists — the endpoint returns no total.
  final bool hasMore;

  final bool isLoadingMore;

  VerificationQueuePage copyWith({bool? isLoadingMore}) =>
      VerificationQueuePage(
        items: items,
        hasMore: hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

/// §10.2's verification queue, oldest first.
@riverpod
class VerificationQueue extends _$VerificationQueue {
  @override
  Future<VerificationQueuePage> build() async {
    final items = await ref
        .watch(adminRepositoryProvider)
        .verificationQueue();

    return VerificationQueuePage(
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
        VerificationQueuePage(
          items: [...page.items, ...next],
          hasMore: next.length == adminPageSize,
        ),
      );
    } on ApiException {
      state = AsyncData(page.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  /// Drops one item without re-reading the queue.
  ///
  /// A decision removes exactly the row that was decided, and the server's
  /// ordering means everything above it is *older* — so a refetch would
  /// reshuffle nothing and cost a request. It would also move the list under
  /// the finger of an administrator working down a page, which is how the
  /// second item gets decided by accident.
  ///
  /// The dashboard's counter is invalidated by the caller instead, because that
  /// figure genuinely did change.
  void remove(String employerUserId) {
    final page = state.value;
    if (page == null) return;

    state = AsyncData(
      VerificationQueuePage(
        items: page.items
            .where((item) => item.employerUserId != employerUserId)
            .toList(),
        hasMore: page.hasMore,
      ),
    );
  }
}
