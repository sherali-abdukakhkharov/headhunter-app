import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/features/notifications/domain/app_notification.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_repository.g.dart';

/// How many notifications one page holds. The server caps a page at 100.
const notificationPageSize = 20;

/// §9.2's in-app notifications, and the device registration push needs.
///
/// ## The two halves are independent on purpose
///
/// Everything above [registerDevice] works with no Firebase project, no
/// notification permission and no Play services: the records exist server-side
/// whether or not a push was ever delivered. That is what let the in-app half
/// ship on 2026-08-24 while `google-services.json` still named the pre-rename
/// package, and it is why a phone that cannot receive push is a degraded
/// install rather than a broken one.
class NotificationRepository {
  const NotificationRepository(this._dio);

  final Dio _dio;

  /// `GET /notifications` — newest first (§9.2).
  Future<List<AppNotification>> list({
    bool unreadOnly = false,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/notifications',
        queryParameters: {
          'limit': notificationPageSize,
          'offset': offset,
          if (unreadOnly) 'unreadOnly': true,
        },
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return items
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /notifications/unread-count` — what the badge shows.
  ///
  /// Its own endpoint over a partial index, because it is read far more often
  /// than the list is opened. So the badge costs one small query rather than a
  /// page of rows nobody looked at.
  Future<int> unreadCount() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/notifications/unread-count',
      );

      return (response.data?['count'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT /notifications/:id/read`.
  ///
  /// **`PUT`, not `POST`.** Both read routes were written as `POST` and every
  /// one of them 404'd against the real server for a whole release — see the
  /// note on [markAllRead] for why nothing caught it.
  ///
  /// A 404 is `notification.not_found` — **including somebody else's**, which
  /// is how the route refuses to confirm that another user's notification
  /// exists. That made the wrong method indistinguishable from a legitimate
  /// refusal at the one place anybody would have looked.
  Future<void> markRead(String id) async {
    try {
      await _dio.put<void>('/notifications/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT /notifications/read` — all of them.
  ///
  /// Returns how many were still unread, which is the only way to say
  /// "nothing to do" honestly: marking an already-read list is a success that
  /// changed nothing.
  ///
  /// **This route and [markRead] shipped as `POST` in 1.10.0 and 1.11.0**, so
  /// the notification centre could be read but never marked read. The tests
  /// faked this repository rather than the transport, so the *method* was the
  /// one property in the file nothing asserted; `notification_repository_test`
  /// now pins the verb and the path of every route here, and cross-checks them
  /// against the backend's own decorators when that repo is checked out.
  Future<int> markAllRead() async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/notifications/read',
      );

      return (response.data?['marked'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /notifications/preferences` — all five categories (§9.2).
  Future<List<NotificationPreference>> preferences() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/notifications/preferences',
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return items
          .whereType<Map<String, dynamic>>()
          .map(NotificationPreference.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT /notifications/preferences/:category`.
  ///
  /// **A disabled category stores nothing at all** — not a hidden row — so the
  /// badge cannot count what somebody asked not to receive. That is why
  /// switching one off is not undoable in the sense of getting the missed
  /// notifications back, and why the screen says so.
  ///
  /// `account` is refused with `notification.category_not_disableable`; the
  /// client never offers it, so reaching that refusal means the category list
  /// moved under the screen.
  Future<void> setPreference(
    NotificationCategory category, {
    required bool enabled,
  }) async {
    try {
      await _dio.put<void>(
        '/notifications/preferences/${category.wire}',
        data: {'enabled': enabled},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /notifications/devices` — this installation can receive push.
  ///
  /// Idempotent, and re-registering a token that belonged to another account
  /// **moves** it. That is not a quirk to work around: an FCM token identifies
  /// an app installation rather than a person, and phones in this market are
  /// handed on, resold and shared. If two accounts could hold one token the
  /// second person would receive the first's interview times.
  ///
  /// Called after every sign-in and after every token rotation, because the
  /// server has no other way to learn either.
  Future<void> registerDevice({
    required String token,
    String? appVersion,
  }) async {
    try {
      await _dio.post<void>(
        '/notifications/devices',
        data: {
          'token': token,
          // The only platform this build runs on. iOS is out of scope by
          // owner direction and there is no second value to derive.
          'platform': 'android',
          // Omitted rather than sent as null when the platform cannot say:
          // the field is optional and the server stores what it is given.
          'appVersion': ?appVersion,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `DELETE /notifications/devices/:token` — stop pushing to this phone.
  ///
  /// **Must run before the tokens are cleared**, which is why sign-out calls
  /// it rather than a listener on the session: afterwards there is no
  /// credential to authorise it with. A session that ends without this —
  /// expiry, a refused refresh — leaves the row, and the next person to sign
  /// in on the device moves it. The gap is a phone nobody signs into again
  /// still receiving the previous user's notifications, which is exactly what
  /// the deliberate call at sign-out prevents.
  Future<void> unregisterDevice(String token) async {
    try {
      await _dio.delete<void>('/notifications/devices/$token');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

/// Kept alive, unlike most repositories here.
///
/// `PushRegistration` is itself kept alive — it holds the token the server was
/// told about for the whole session — and a kept-alive provider reading an
/// auto-disposing one keeps it alive anyway, just without saying so. This is
/// a stateless wrapper over the equally kept-alive [dioProvider], so there is
/// nothing to dispose and the declaration now matches the lifetime.
@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) =>
    NotificationRepository(ref.watch(dioProvider));

/// One loaded stretch of the notification list.
@immutable
class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<AppNotification> items;

  /// Whether the last page came back full, which is the only evidence the
  /// client has that another exists — the endpoint returns no total.
  final bool hasMore;

  final bool isLoadingMore;

  NotificationPage copyWith({
    List<AppNotification>? items,
    bool? isLoadingMore,
  }) => NotificationPage(
    items: items ?? this.items,
    hasMore: hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// §9.2's list, newest first.
///
/// Keyed by [unreadOnly] so switching the filter is a different question
/// rather than a refetch of the same one — and switching back costs nothing.
@riverpod
class Notifications extends _$Notifications {
  @override
  Future<NotificationPage> build({bool unreadOnly = false}) async {
    final items = await ref
        .watch(notificationRepositoryProvider)
        .list(unreadOnly: unreadOnly);

    return NotificationPage(
      items: items,
      hasMore: items.length == notificationPageSize,
    );
  }

  /// Appends the next page, and **rethrows** so the caller can say so over a
  /// list that is still on screen.
  Future<void> loadMore() async {
    final page = state.value;
    if (page == null || page.isLoadingMore || !page.hasMore) return;

    state = AsyncData(page.copyWith(isLoadingMore: true));

    try {
      final next = await ref
          .read(notificationRepositoryProvider)
          .list(unreadOnly: unreadOnly, offset: page.items.length);

      state = AsyncData(
        NotificationPage(
          items: [...page.items, ...next],
          hasMore: next.length == notificationPageSize,
        ),
      );
    } on ApiException {
      state = AsyncData(page.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  /// Marks one read, and does not re-read the list.
  ///
  /// The route answers 204, so a refetch would spend a request learning what
  /// the request just did — and on the unread-only list it would make the row
  /// vanish under the finger that tapped it. It stays, marked, until the
  /// filter is asked again.
  Future<void> markRead(String id) async {
    final page = state.value;
    if (page == null) return;

    await ref.read(notificationRepositoryProvider).markRead(id);

    state = AsyncData(
      page.copyWith(
        items: [
          for (final item in page.items)
            if (item.id == id) item.read else item,
        ],
      ),
    );
    ref.invalidate(unreadNotificationCountProvider);
  }

  /// Marks everything read, and returns how many actually were unread.
  Future<int> markAllRead() async {
    final marked = await ref
        .read(notificationRepositoryProvider)
        .markAllRead();

    final page = state.value;
    if (page != null) {
      state = AsyncData(
        page.copyWith(items: [for (final item in page.items) item.read]),
      );
    }

    ref.invalidate(unreadNotificationCountProvider);
    return marked;
  }
}

/// The badge (§9.2).
///
/// Deliberately its own provider rather than a count over the list: the list
/// is one page and the count is all of them, so counting the page would
/// under-report the moment there are more than twenty.
@riverpod
Future<int> unreadNotificationCount(Ref ref) =>
    ref.watch(notificationRepositoryProvider).unreadCount();

/// §9.2's five per-category switches.
@riverpod
class NotificationPreferences extends _$NotificationPreferences {
  @override
  Future<List<NotificationPreference>> build() =>
      ref.watch(notificationRepositoryProvider).preferences();

  /// Switches one category, updating the row before the request so the toggle
  /// does not lag the finger — and putting it back if the server refuses.
  Future<void> set(
    NotificationCategory category, {
    required bool enabled,
  }) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(_withEnabled(current, category, enabled: enabled));

    try {
      await ref
          .read(notificationRepositoryProvider)
          .setPreference(category, enabled: enabled);
      // A disabled category stores nothing at all, so the badge can only have
      // gone down.
      ref.invalidate(unreadNotificationCountProvider);
    } on ApiException {
      state = AsyncData(_withEnabled(current, category, enabled: !enabled));
      rethrow;
    }
  }

  List<NotificationPreference> _withEnabled(
    List<NotificationPreference> from,
    NotificationCategory category, {
    required bool enabled,
  }) => [
    for (final row in from)
      if (row.category == category)
        NotificationPreference(
          category: row.category,
          enabled: enabled,
          canDisable: row.canDisable,
        )
      else
        row,
  ];
}
