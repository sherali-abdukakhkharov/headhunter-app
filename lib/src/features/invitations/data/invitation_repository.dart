import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/core/network/interceptors/idempotency_interceptor.dart';
import 'package:jobbridge_app/src/features/invitations/domain/invitation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'invitation_repository.g.dart';

/// One status change on an invitation (BR-08's trail).
///
/// Readable by **both** sides, which is the point of it: the employer and the
/// candidate are held to the same record of who did what and when.
class InvitationEvent {
  const InvitationEvent({
    required this.toStatus,
    required this.createdAt,
    this.fromStatus,
    this.actorRole,
    this.reason,
  });

  factory InvitationEvent.fromJson(Map<String, dynamic> json) =>
      InvitationEvent(
        toStatus: json['toStatus'] as String,
        createdAt: json['createdAt'] as String,
        fromStatus: json['fromStatus'] as String?,
        actorRole: json['actorRole'] as String?,
        reason: json['reason'] as String?,
      );

  /// Null on the first row — an invitation coming into existence has no prior
  /// status.
  final String? fromStatus;
  final String toStatus;

  /// `candidate` or `employer`. Nullable because a future administrative
  /// action (§10) would have neither.
  final String? actorRole;

  /// The note attached to the change, where there was one. A person's own
  /// words, never translated (§2.4).
  final String? reason;

  final String createdAt;
}

/// Direct employer invitations, both sides of them (§8.2).
///
/// One repository for one resource, as the server has one controller for it:
/// the asymmetry of §8.2 is *which routes each role may call*, not which
/// resource they are talking about. Splitting it in two would duplicate
/// [Invitation]'s parsing and the two halves would drift.
class InvitationRepository {
  const InvitationRepository(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  static const _keyPrefix = 'invite.idempotency.';

  // --- employer ------------------------------------------------------------

  /// `POST /invitations` — invite a candidate to a vacancy, or generally
  /// (§8.2).
  ///
  /// Exactly one of [vacancyId] and [occupationId] must be given; the server
  /// answers `invitation.shape_invalid` otherwise, and an assert catches it
  /// here first because it is a programming error rather than a user one.
  ///
  /// ## The idempotency key is persisted, and the natural key is not enough
  ///
  /// The unlock deliberately has no key, because `(employer, candidate)` is a
  /// primary key there and a retry is answered by the existing entitlement. An
  /// invitation has a **partial** unique index instead — one *open* invitation
  /// per candidate per vacancy — and that is a weaker guarantee in exactly the
  /// case that matters. A retry after the process died with the first request
  /// in flight finds the slot occupied by *its own* invitation and gets
  /// `invitation.already_invited`, which reads to the employer as "you already
  /// did this" when they have no idea whether they did. Worse, once the
  /// candidate answers, the slot frees and the same retry would create a second
  /// invitation.
  ///
  /// So the key is written against the target *before* the request and cleared
  /// only once the server has answered. The server returns the original
  /// invitation for a replay with the same key and the same body (§12.4).
  ///
  /// The target is `vacancyId ?? occupationId` scoped to the candidate, which
  /// is the same pair the unique index uses — a general invitation and a
  /// vacancy invitation to the same person are two intents and must not share a
  /// key.
  Future<Invitation> invite({
    required String candidateUserId,
    String? vacancyId,
    String? occupationId,
    String? regionId,
    String? districtId,
    int? salaryFrom,
    int? salaryTo,
    String? salaryPeriodId,
    bool? salaryIsNegotiable,
    String? scheduleNote,
    String? message,
  }) async {
    assert(
      (vacancyId == null) != (occupationId == null),
      'Exactly one of vacancyId and occupationId (§8.2). The server refuses '
      'anything else with invitation.shape_invalid.',
    );

    final target = vacancyId ?? occupationId;
    final storageKey = '$_keyPrefix$candidateUserId.$target';
    final key = _prefs.getString(storageKey) ?? const Uuid().v4();
    await _prefs.setString(storageKey, key);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/invitations',
        data: {
          'candidateUserId': candidateUserId,
          'vacancyId': ?vacancyId,
          'occupationId': ?occupationId,
          'regionId': ?regionId,
          'districtId': ?districtId,
          'salaryFrom': ?salaryFrom,
          'salaryTo': ?salaryTo,
          'salaryPeriodId': ?salaryPeriodId,
          'salaryIsNegotiable': ?salaryIsNegotiable,
          'scheduleNote': ?scheduleNote,
          'message': ?message,
        },
        options: Options(extra: {IdempotencyInterceptor.keyExtra: key}),
      );

      final invitation = _one(response.data);
      await _prefs.remove(storageKey);
      return invitation;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /invitations/sent` — what this employer has sent (§8.2).
  ///
  /// Both filters are the **server's**, unlike the ledger's client-side one:
  /// this endpoint takes them, so a filtered list here is complete rather than
  /// filtered-over-what-was-loaded.
  Future<List<Invitation>> sent({String? vacancyId, String? status}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/invitations/sent',
        queryParameters: {'vacancyId': ?vacancyId, 'status': ?status},
      );

      return _list(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /invitations/counts/:vacancyId` — §7.4's invited and accepted counts.
  ///
  /// Returned as the server's own map rather than a typed pair, because §7.4
  /// tracks counts "against the target" and the set of statuses is the server's
  /// to extend. A status this app version has never heard of still counts.
  ///
  /// Interviewed and hired are **application** stages and are deliberately not
  /// here — they come from `/vacancies/{id}/applications/counts`.
  Future<Map<String, int>> countsForVacancy(String vacancyId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/invitations/counts/$vacancyId',
      );

      final byStatus = response.data?['byStatus'];
      if (byStatus is! Map) return const {};

      return {
        for (final entry in byStatus.entries)
          if (entry.key is String && entry.value is num)
            entry.key as String: (entry.value as num).toInt(),
      };
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- candidate -----------------------------------------------------------

  /// `GET /invitations/received` — the candidate's inbox (§8.2).
  ///
  /// Deliberately **not** filtered by whether the vacancy is still visible: an
  /// invitation to a vacancy that has since closed still has to be readable,
  /// for the same reason a saved one does. So a row here may point at a vacancy
  /// that answers `vacancy.not_found`, and the screen has to survive that.
  Future<List<Invitation>> received() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/invitations/received',
      );

      return _list(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /invitations/:id/respond` — accept, decline or ask (§8.2).
  ///
  /// The candidate's alone, and **not** idempotency-keyed: the route is
  /// naturally idempotent because the server refuses a transition to the status
  /// an invitation already holds (`invitation.response_not_allowed`), so a
  /// replay cannot produce a second history row. A key would add a header and
  /// answer nothing.
  Future<Invitation> respond(
    String id,
    String status, {
    String? note,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/invitations/$id/respond',
        data: {'status': status, 'note': ?note},
      );

      return _one(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- both ----------------------------------------------------------------

  /// `GET /invitations/:id` — readable by either participant.
  Future<Invitation> byId(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/invitations/$id');

      return _one(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /invitations/:id/history` — BR-08's trail, for either side.
  Future<List<InvitationEvent>> history(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/invitations/$id/history',
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) InvitationEvent.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  List<Invitation> _list(Map<String, dynamic>? data) {
    final items = data?['items'];
    if (items is! List) return const [];

    return [
      for (final item in items)
        if (item is Map<String, dynamic>) Invitation.fromJson(item),
    ];
  }

  Invitation _one(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException('The server returned an empty response.');
    }

    return Invitation.fromJson(data);
  }
}

@riverpod
Future<InvitationRepository> invitationRepository(Ref ref) async =>
    InvitationRepository(
      ref.watch(dioProvider),
      await SharedPreferences.getInstance(),
    );

/// The candidate's invitation inbox (§8.2).
@riverpod
Future<List<Invitation>> receivedInvitations(Ref ref) async =>
    (await ref.watch(invitationRepositoryProvider.future)).received();

/// Invitations this employer has sent, optionally narrowed server-side (§8.2).
@riverpod
Future<List<Invitation>> sentInvitations(
  Ref ref, {
  String? vacancyId,
  String? status,
}) async => (await ref.watch(invitationRepositoryProvider.future)).sent(
  vacancyId: vacancyId,
  status: status,
);

/// §7.4's invitation counts for one vacancy.
@riverpod
Future<Map<String, int>> invitationCounts(Ref ref, String vacancyId) async =>
    (await ref.watch(
      invitationRepositoryProvider.future,
    )).countsForVacancy(vacancyId);

/// BR-08's trail for one invitation, for whichever side is looking.
@riverpod
Future<List<InvitationEvent>> invitationHistory(Ref ref, String id) async =>
    (await ref.watch(invitationRepositoryProvider.future)).history(id);
