import 'package:dio/dio.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/network/dio_provider.dart';
import 'package:jobbridge_app/src/features/interviews/domain/interview.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'interview_repository.g.dart';

/// One status change on an interview (BR-08's trail).
///
/// Readable by **both** sides, which is the point of it: the employer and the
/// candidate are held to the same record of who moved the time and when.
class InterviewEvent {
  const InterviewEvent({
    required this.toStatus,
    required this.createdAt,
    this.fromStatus,
    this.actorRole,
    this.reason,
  });

  factory InterviewEvent.fromJson(Map<String, dynamic> json) => InterviewEvent(
    toStatus: json['toStatus'] as String,
    createdAt: json['createdAt'] as String,
    fromStatus: json['fromStatus'] as String?,
    actorRole: json['actorRole'] as String?,
    reason: json['reason'] as String?,
  );

  /// Null on the first row — an interview coming into existence has no prior
  /// status.
  final String? fromStatus;
  final String toStatus;

  /// `candidate` or `employer`.
  final String? actorRole;

  /// The note attached to the change. A person's own words, never translated
  /// (§2.4).
  final String? reason;

  final String createdAt;
}

/// Interviews (§8.3), from whichever side is asking.
///
/// ## The two list routes are not interchangeable
///
/// `GET /interviews/mine` carries `@RequireRole('candidate')`, so an employer
/// cannot call it — and `GET /applications/:id/interviews` is open to both
/// participants. That asymmetry is the contract, not an oversight to route
/// around: a candidate wants every interview they have, and an employer wants
/// the interviews of the application in front of them.
///
/// What is genuinely missing is an employer's **aggregate** list, which is why
/// §6.2's dashboard shows the three counts it can answer instead of a
/// placeholder where "5 interviews" would go. That is a filed backend ask; it
/// blocks a metric, not this screen.
class InterviewRepository {
  const InterviewRepository(this._dio);

  final Dio _dio;

  // --- candidate -----------------------------------------------------------

  /// `GET /interviews/mine` — every interview of this candidate, across every
  /// application (§8.3).
  ///
  /// One request for the whole list rather than one per application: the
  /// candidate's applications screen shows each interview beside the
  /// application it belongs to, and grouping by `applicationId` in Dart costs
  /// nothing while a request per row costs a round trip per row.
  Future<List<Interview>> mine() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/interviews/mine',
      );

      return _list(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /interviews/:id/respond` — confirm, or ask for another time (§8.3).
  ///
  /// **Not idempotency-keyed**, and for the same reason the invitation response
  /// is not: the route is naturally idempotent because the server refuses a
  /// transition to the status the interview already holds
  /// (`interview.response_not_allowed`), so a replay cannot produce a second
  /// history row. A key would add a header and answer nothing.
  Future<Interview> respond(
    String id,
    String status, {
    String? note,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/interviews/$id/respond',
        data: {'status': status, 'note': ?note},
      );

      return _one(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // --- employer ------------------------------------------------------------

  /// `POST /applications/:id/interviews` — schedule one (§8.3).
  ///
  /// ## [scheduledAt] is an instant, and the client does not invent an offset
  ///
  /// It is sent as UTC. The employer picks a date and a time meaning the
  /// **platform's** clock — that is the clock the candidate's card renders, so
  /// it is the only reading on which the two sides agree — and
  /// `instantForPlatformWallClock` converts it using an offset taken from a
  /// timestamp the *server* sent. A `+05:00` written into Dart would be a
  /// second source of truth for the platform zone, wrong the day Uzbekistan
  /// reintroduces daylight saving, and wrong in the direction that moves every
  /// interview by an hour.
  ///
  /// ## The whole shape goes up, on create and on edit alike
  ///
  /// The fields are interdependent: the type decides which of [location] and
  /// [meetingLink] may exist at all, and the server refuses the others. A
  /// partial update would let a phone interview keep the address of the
  /// in-person one it used to be — which is why `PUT /interviews/:id` takes the
  /// same DTO rather than a patch, and why [reschedule] does too.
  Future<Interview> schedule(
    String applicationId, {
    required String type,
    required DateTime scheduledAt,
    String? location,
    String? meetingLink,
    String? instructions,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/applications/$applicationId/interviews',
        data: _body(
          type: type,
          scheduledAt: scheduledAt,
          location: location,
          meetingLink: meetingLink,
          instructions: instructions,
        ),
      );

      return _one(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `PUT /interviews/:id` — move it, or correct it (§8.3).
  ///
  /// **Rescheduling resets the candidate's answer** to `scheduled`, and the
  /// server does that rather than the client: an interview moved to another
  /// time has not been confirmed, whatever was said about the old one. So the
  /// caller sends no status and must not assume the old one survives.
  Future<Interview> reschedule(
    String id, {
    required String type,
    required DateTime scheduledAt,
    String? location,
    String? meetingLink,
    String? instructions,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/interviews/$id',
        data: _body(
          type: type,
          scheduledAt: scheduledAt,
          location: location,
          meetingLink: meetingLink,
          instructions: instructions,
        ),
      );

      return _one(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `POST /interviews/:id/cancel` — call it off (§8.3).
  ///
  /// The reason is optional and **shown to the candidate**, which is why the
  /// sheet that collects it says so: an employer writing "found someone closer"
  /// for their own records would be writing it to the person it is about.
  Future<void> cancel(String id, {String? reason}) async {
    try {
      await _dio.post<void>(
        '/interviews/$id/cancel',
        data: {'reason': ?reason},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// The shape both write routes take.
  ///
  /// Empty strings are sent as **absent**, not as empty: the server's
  /// `detailViolation` treats a blank location as missing for `in_person` and
  /// as *present* for the other two types, so a field the employer cleared
  /// would earn a refusal naming a field they thought they had emptied.
  Map<String, dynamic> _body({
    required String type,
    required DateTime scheduledAt,
    String? location,
    String? meetingLink,
    String? instructions,
  }) => {
    'type': type,
    'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    'location': ?_orNull(location),
    'meetingLink': ?_orNull(meetingLink),
    'instructions': ?_orNull(instructions),
  };

  static String? _orNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  // --- both ----------------------------------------------------------------

  /// `GET /applications/:id/interviews` — one application's interviews, for
  /// either participant.
  Future<List<Interview>> forApplication(String applicationId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/applications/$applicationId/interviews',
      );

      return _list(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET /interviews/:id/history` — BR-08's trail, for either side.
  Future<List<InterviewEvent>> history(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/interviews/$id/history',
      );

      final items = response.data?['items'];
      if (items is! List) return const [];

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) InterviewEvent.fromJson(item),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  List<Interview> _list(Map<String, dynamic>? data) {
    final items = data?['items'];
    if (items is! List) return const [];

    return [
      for (final item in items)
        if (item is Map<String, dynamic>) Interview.fromJson(item),
    ];
  }

  Interview _one(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException('The server returned an empty response.');
    }

    return Interview.fromJson(data);
  }
}

@riverpod
InterviewRepository interviewRepository(Ref ref) =>
    InterviewRepository(ref.watch(dioProvider));

/// Every interview of the signed-in candidate (§8.3).
@riverpod
Future<List<Interview>> myInterviews(Ref ref) =>
    ref.watch(interviewRepositoryProvider).mine();

/// This candidate's interviews grouped by application.
///
/// Derived from [myInterviews] rather than fetched per application, so a list
/// of applications costs one request no matter how long it is. Keyed lookups
/// return an empty list rather than null, because "this application has no
/// interview" is the common case and not an absence worth a null check at every
/// call site.
@riverpod
Future<Map<String, List<Interview>>> myInterviewsByApplication(Ref ref) async {
  final interviews = await ref.watch(myInterviewsProvider.future);
  final grouped = <String, List<Interview>>{};

  for (final interview in interviews) {
    grouped.putIfAbsent(interview.applicationId, () => []).add(interview);
  }

  return grouped;
}

/// One application's interviews, for either side (§8.3).
@riverpod
Future<List<Interview>> applicationInterviews(
  Ref ref,
  String applicationId,
) => ref.watch(interviewRepositoryProvider).forApplication(applicationId);

/// BR-08's trail for one interview, for whichever side is looking.
@riverpod
Future<List<InterviewEvent>> interviewHistory(Ref ref, String id) =>
    ref.watch(interviewRepositoryProvider).history(id);
