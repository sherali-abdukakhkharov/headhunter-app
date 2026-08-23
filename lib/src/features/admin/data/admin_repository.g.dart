// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminRepository)
final adminRepositoryProvider = AdminRepositoryProvider._();

final class AdminRepositoryProvider
    extends
        $FunctionalProvider<AdminRepository, AdminRepository, AdminRepository>
    with $Provider<AdminRepository> {
  AdminRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdminRepository create(Ref ref) {
    return adminRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRepository>(value),
    );
  }
}

String _$adminRepositoryHash() => r'e369349b36a30b5bfe413df6ec69f6dad14f8c00';

/// The period the §10.1 dashboard is showing, or null for the server's default.
///
/// A provider of its own rather than a field on the dashboard notifier, so that
/// refreshing the figures keeps the period. Folding the two together would make
/// a pull-to-refresh silently reset the range an administrator had chosen —
/// same numbers, different question, and nothing on screen to say so.

@ProviderFor(DashboardRangeController)
final dashboardRangeControllerProvider = DashboardRangeControllerProvider._();

/// The period the §10.1 dashboard is showing, or null for the server's default.
///
/// A provider of its own rather than a field on the dashboard notifier, so that
/// refreshing the figures keeps the period. Folding the two together would make
/// a pull-to-refresh silently reset the range an administrator had chosen —
/// same numbers, different question, and nothing on screen to say so.
final class DashboardRangeControllerProvider
    extends $NotifierProvider<DashboardRangeController, DashboardRange?> {
  /// The period the §10.1 dashboard is showing, or null for the server's default.
  ///
  /// A provider of its own rather than a field on the dashboard notifier, so that
  /// refreshing the figures keeps the period. Folding the two together would make
  /// a pull-to-refresh silently reset the range an administrator had chosen —
  /// same numbers, different question, and nothing on screen to say so.
  DashboardRangeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardRangeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardRangeControllerHash();

  @$internal
  @override
  DashboardRangeController create() => DashboardRangeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardRange? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardRange?>(value),
    );
  }
}

String _$dashboardRangeControllerHash() =>
    r'ffea0c834677b387cbec697a2e2cc859de99cdd3';

/// The period the §10.1 dashboard is showing, or null for the server's default.
///
/// A provider of its own rather than a field on the dashboard notifier, so that
/// refreshing the figures keeps the period. Folding the two together would make
/// a pull-to-refresh silently reset the range an administrator had chosen —
/// same numbers, different question, and nothing on screen to say so.

abstract class _$DashboardRangeController extends $Notifier<DashboardRange?> {
  DashboardRange? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DashboardRange?, DashboardRange?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DashboardRange?, DashboardRange?>,
              DashboardRange?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// §10.1's counters for the selected period.

@ProviderFor(adminDashboard)
final adminDashboardProvider = AdminDashboardProvider._();

/// §10.1's counters for the selected period.

final class AdminDashboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminDashboard>,
          AdminDashboard,
          FutureOr<AdminDashboard>
        >
    with $FutureModifier<AdminDashboard>, $FutureProvider<AdminDashboard> {
  /// §10.1's counters for the selected period.
  AdminDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDashboardHash();

  @$internal
  @override
  $FutureProviderElement<AdminDashboard> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdminDashboard> create(Ref ref) {
    return adminDashboard(ref);
  }
}

String _$adminDashboardHash() => r'5c11edb05ad9248cc6955cea9dadb11e78c71683';

/// §10.2's employer verification queue, oldest first.

@ProviderFor(VerificationQueue)
final verificationQueueProvider = VerificationQueueProvider._();

/// §10.2's employer verification queue, oldest first.
final class VerificationQueueProvider
    extends
        $AsyncNotifierProvider<
          VerificationQueue,
          AdminQueuePage<VerificationQueueItem>
        > {
  /// §10.2's employer verification queue, oldest first.
  VerificationQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verificationQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verificationQueueHash();

  @$internal
  @override
  VerificationQueue create() => VerificationQueue();
}

String _$verificationQueueHash() => r'b56cffc47fa830c952b568887f6fbc540ba9cd5c';

/// §10.2's employer verification queue, oldest first.

abstract class _$VerificationQueue
    extends $AsyncNotifier<AdminQueuePage<VerificationQueueItem>> {
  FutureOr<AdminQueuePage<VerificationQueueItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AdminQueuePage<VerificationQueueItem>>,
              AdminQueuePage<VerificationQueueItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AdminQueuePage<VerificationQueueItem>>,
                AdminQueuePage<VerificationQueueItem>
              >,
              AsyncValue<AdminQueuePage<VerificationQueueItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// §10.2's vacancy moderation queue, oldest first (BR-04).

@ProviderFor(ModerationQueue)
final moderationQueueProvider = ModerationQueueProvider._();

/// §10.2's vacancy moderation queue, oldest first (BR-04).
final class ModerationQueueProvider
    extends
        $AsyncNotifierProvider<
          ModerationQueue,
          AdminQueuePage<ModerationQueueItem>
        > {
  /// §10.2's vacancy moderation queue, oldest first (BR-04).
  ModerationQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moderationQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moderationQueueHash();

  @$internal
  @override
  ModerationQueue create() => ModerationQueue();
}

String _$moderationQueueHash() => r'c94c728743e49747d38f07b550a46bba49a82e98';

/// §10.2's vacancy moderation queue, oldest first (BR-04).

abstract class _$ModerationQueue
    extends $AsyncNotifier<AdminQueuePage<ModerationQueueItem>> {
  FutureOr<AdminQueuePage<ModerationQueueItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AdminQueuePage<ModerationQueueItem>>,
              AdminQueuePage<ModerationQueueItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AdminQueuePage<ModerationQueueItem>>,
                AdminQueuePage<ModerationQueueItem>
              >,
              AsyncValue<AdminQueuePage<ModerationQueueItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// §10.2's complaint queue, oldest first, all four target kinds together.

@ProviderFor(ComplaintQueue)
final complaintQueueProvider = ComplaintQueueProvider._();

/// §10.2's complaint queue, oldest first, all four target kinds together.
final class ComplaintQueueProvider
    extends $AsyncNotifierProvider<ComplaintQueue, AdminQueuePage<Complaint>> {
  /// §10.2's complaint queue, oldest first, all four target kinds together.
  ComplaintQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'complaintQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$complaintQueueHash();

  @$internal
  @override
  ComplaintQueue create() => ComplaintQueue();
}

String _$complaintQueueHash() => r'7e1675d29799f379e03125d4d7c8c857332d1d25';

/// §10.2's complaint queue, oldest first, all four target kinds together.

abstract class _$ComplaintQueue
    extends $AsyncNotifier<AdminQueuePage<Complaint>> {
  FutureOr<AdminQueuePage<Complaint>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AdminQueuePage<Complaint>>,
              AdminQueuePage<Complaint>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AdminQueuePage<Complaint>>,
                AdminQueuePage<Complaint>
              >,
              AsyncValue<AdminQueuePage<Complaint>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One complaint and its target, loaded for §10.2's review.
///
/// Keyed by id for the same reason the vacancy review is: it is read once per
/// screen, never appended to, and two reviews open in a session must not
/// overwrite each other.

@ProviderFor(complaintDetail)
final complaintDetailProvider = ComplaintDetailFamily._();

/// One complaint and its target, loaded for §10.2's review.
///
/// Keyed by id for the same reason the vacancy review is: it is read once per
/// screen, never appended to, and two reviews open in a session must not
/// overwrite each other.

final class ComplaintDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ComplaintDetail>,
          ComplaintDetail,
          FutureOr<ComplaintDetail>
        >
    with $FutureModifier<ComplaintDetail>, $FutureProvider<ComplaintDetail> {
  /// One complaint and its target, loaded for §10.2's review.
  ///
  /// Keyed by id for the same reason the vacancy review is: it is read once per
  /// screen, never appended to, and two reviews open in a session must not
  /// overwrite each other.
  ComplaintDetailProvider._({
    required ComplaintDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'complaintDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$complaintDetailHash();

  @override
  String toString() {
    return r'complaintDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ComplaintDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ComplaintDetail> create(Ref ref) {
    final argument = this.argument as String;
    return complaintDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ComplaintDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$complaintDetailHash() => r'5f3b256dc535985a1df46fcb62e6dbd6fc6b5977';

/// One complaint and its target, loaded for §10.2's review.
///
/// Keyed by id for the same reason the vacancy review is: it is read once per
/// screen, never appended to, and two reviews open in a session must not
/// overwrite each other.

final class ComplaintDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ComplaintDetail>, String> {
  ComplaintDetailFamily._()
    : super(
        retry: null,
        name: r'complaintDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One complaint and its target, loaded for §10.2's review.
  ///
  /// Keyed by id for the same reason the vacancy review is: it is read once per
  /// screen, never appended to, and two reviews open in a session must not
  /// overwrite each other.

  ComplaintDetailProvider call(String complaintId) =>
      ComplaintDetailProvider._(argument: complaintId, from: this);

  @override
  String toString() => r'complaintDetailProvider';
}

/// One vacancy, loaded for §10.2's review.
///
/// A family rather than a notifier: unlike a queue this is read once per screen
/// and never appended to, and keying it by id is what lets a moderator open two
/// reviews in a session without the second overwriting the first.

@ProviderFor(vacancyForReview)
final vacancyForReviewProvider = VacancyForReviewFamily._();

/// One vacancy, loaded for §10.2's review.
///
/// A family rather than a notifier: unlike a queue this is read once per screen
/// and never appended to, and keying it by id is what lets a moderator open two
/// reviews in a session without the second overwriting the first.

final class VacancyForReviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<VacancyReview>,
          VacancyReview,
          FutureOr<VacancyReview>
        >
    with $FutureModifier<VacancyReview>, $FutureProvider<VacancyReview> {
  /// One vacancy, loaded for §10.2's review.
  ///
  /// A family rather than a notifier: unlike a queue this is read once per screen
  /// and never appended to, and keying it by id is what lets a moderator open two
  /// reviews in a session without the second overwriting the first.
  VacancyForReviewProvider._({
    required VacancyForReviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vacancyForReviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vacancyForReviewHash();

  @override
  String toString() {
    return r'vacancyForReviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VacancyReview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VacancyReview> create(Ref ref) {
    final argument = this.argument as String;
    return vacancyForReview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VacancyForReviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vacancyForReviewHash() => r'bfc15e47760fa7081c0d9376c420d87b959e4349';

/// One vacancy, loaded for §10.2's review.
///
/// A family rather than a notifier: unlike a queue this is read once per screen
/// and never appended to, and keying it by id is what lets a moderator open two
/// reviews in a session without the second overwriting the first.

final class VacancyForReviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VacancyReview>, String> {
  VacancyForReviewFamily._()
    : super(
        retry: null,
        name: r'vacancyForReviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One vacancy, loaded for §10.2's review.
  ///
  /// A family rather than a notifier: unlike a queue this is read once per screen
  /// and never appended to, and keying it by id is what lets a moderator open two
  /// reviews in a session without the second overwriting the first.

  VacancyForReviewProvider call(String vacancyId) =>
      VacancyForReviewProvider._(argument: vacancyId, from: this);

  @override
  String toString() => r'vacancyForReviewProvider';
}

/// §10.4's search results, or **null when nothing has been searched for**.
///
/// ## Nothing is fetched until an administrator asks
///
/// The other four §10 screens load on open. This one does not, and the reason
/// is the same one that keeps the verification queue from prefetching
/// evidence: §11.1 logs every read of protected data, and `GET /admin/users`
/// hands back phone numbers, so opening the tab must not write a log line
/// nobody asked for. A search is an act.
///
/// So `build` returns null rather than a page. Null and empty are different
/// answers and the screen says two different things about them — "nothing has
/// been searched for" and "nothing matches this" — which is the distinction
/// §10.4's own paging makes so easy to lose.
///
/// Deliberately **not** `keepAlive`, for the reason
/// `searchCandidate` gives: a list of other people's phone numbers should not
/// outlive the screen that was entitled to ask for it.

@ProviderFor(UserSearch)
final userSearchProvider = UserSearchProvider._();

/// §10.4's search results, or **null when nothing has been searched for**.
///
/// ## Nothing is fetched until an administrator asks
///
/// The other four §10 screens load on open. This one does not, and the reason
/// is the same one that keeps the verification queue from prefetching
/// evidence: §11.1 logs every read of protected data, and `GET /admin/users`
/// hands back phone numbers, so opening the tab must not write a log line
/// nobody asked for. A search is an act.
///
/// So `build` returns null rather than a page. Null and empty are different
/// answers and the screen says two different things about them — "nothing has
/// been searched for" and "nothing matches this" — which is the distinction
/// §10.4's own paging makes so easy to lose.
///
/// Deliberately **not** `keepAlive`, for the reason
/// `searchCandidate` gives: a list of other people's phone numbers should not
/// outlive the screen that was entitled to ask for it.
final class UserSearchProvider
    extends $AsyncNotifierProvider<UserSearch, AdminQueuePage<AdminUser>?> {
  /// §10.4's search results, or **null when nothing has been searched for**.
  ///
  /// ## Nothing is fetched until an administrator asks
  ///
  /// The other four §10 screens load on open. This one does not, and the reason
  /// is the same one that keeps the verification queue from prefetching
  /// evidence: §11.1 logs every read of protected data, and `GET /admin/users`
  /// hands back phone numbers, so opening the tab must not write a log line
  /// nobody asked for. A search is an act.
  ///
  /// So `build` returns null rather than a page. Null and empty are different
  /// answers and the screen says two different things about them — "nothing has
  /// been searched for" and "nothing matches this" — which is the distinction
  /// §10.4's own paging makes so easy to lose.
  ///
  /// Deliberately **not** `keepAlive`, for the reason
  /// `searchCandidate` gives: a list of other people's phone numbers should not
  /// outlive the screen that was entitled to ask for it.
  UserSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSearchHash();

  @$internal
  @override
  UserSearch create() => UserSearch();
}

String _$userSearchHash() => r'507a551613e732f3be8c41eb4bdecbdc9ea09f7a';

/// §10.4's search results, or **null when nothing has been searched for**.
///
/// ## Nothing is fetched until an administrator asks
///
/// The other four §10 screens load on open. This one does not, and the reason
/// is the same one that keeps the verification queue from prefetching
/// evidence: §11.1 logs every read of protected data, and `GET /admin/users`
/// hands back phone numbers, so opening the tab must not write a log line
/// nobody asked for. A search is an act.
///
/// So `build` returns null rather than a page. Null and empty are different
/// answers and the screen says two different things about them — "nothing has
/// been searched for" and "nothing matches this" — which is the distinction
/// §10.4's own paging makes so easy to lose.
///
/// Deliberately **not** `keepAlive`, for the reason
/// `searchCandidate` gives: a list of other people's phone numbers should not
/// outlive the screen that was entitled to ask for it.

abstract class _$UserSearch extends $AsyncNotifier<AdminQueuePage<AdminUser>?> {
  FutureOr<AdminQueuePage<AdminUser>?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AdminQueuePage<AdminUser>?>,
              AdminQueuePage<AdminUser>?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AdminQueuePage<AdminUser>?>,
                AdminQueuePage<AdminUser>?
              >,
              AsyncValue<AdminQueuePage<AdminUser>?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// One account, loaded for §10.4's screen.
///
/// A family keyed by id, and **not** `keepAlive` — reading a user is a logged
/// access to protected data (§11.1), and a cache that outlived the screen
/// would keep answering with a status somebody may since have changed.

@ProviderFor(adminUser)
final adminUserProvider = AdminUserFamily._();

/// One account, loaded for §10.4's screen.
///
/// A family keyed by id, and **not** `keepAlive` — reading a user is a logged
/// access to protected data (§11.1), and a cache that outlived the screen
/// would keep answering with a status somebody may since have changed.

final class AdminUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminUserDetail>,
          AdminUserDetail,
          FutureOr<AdminUserDetail>
        >
    with $FutureModifier<AdminUserDetail>, $FutureProvider<AdminUserDetail> {
  /// One account, loaded for §10.4's screen.
  ///
  /// A family keyed by id, and **not** `keepAlive` — reading a user is a logged
  /// access to protected data (§11.1), and a cache that outlived the screen
  /// would keep answering with a status somebody may since have changed.
  AdminUserProvider._({
    required AdminUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminUserHash();

  @override
  String toString() {
    return r'adminUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AdminUserDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdminUserDetail> create(Ref ref) {
    final argument = this.argument as String;
    return adminUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminUserHash() => r'7b8e63b05712f4262ffb6449cc568b769df144c6';

/// One account, loaded for §10.4's screen.
///
/// A family keyed by id, and **not** `keepAlive` — reading a user is a logged
/// access to protected data (§11.1), and a cache that outlived the screen
/// would keep answering with a status somebody may since have changed.

final class AdminUserFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AdminUserDetail>, String> {
  AdminUserFamily._()
    : super(
        retry: null,
        name: r'adminUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One account, loaded for §10.4's screen.
  ///
  /// A family keyed by id, and **not** `keepAlive` — reading a user is a logged
  /// access to protected data (§11.1), and a cache that outlived the screen
  /// would keep answering with a status somebody may since have changed.

  AdminUserProvider call(String userId) =>
      AdminUserProvider._(argument: userId, from: this);

  @override
  String toString() => r'adminUserProvider';
}

/// One slice of §10.4's audit log, newest first.
///
/// A family keyed by the whole [AuditQuery] rather than a single notifier,
/// because the section asks two different questions of this log and an
/// administrator following a trail asks them in sequence: "what was done to
/// this account", then "what else has that administrator done". Keying by the
/// question is what lets the second answer arrive without discarding the
/// first, and what makes going back cost no request.
///
/// Not `keepAlive`, like every other §10 read: the log carries who did what to
/// whom, and a cache that outlived the screen would keep answering after the
/// administrator had moved on.

@ProviderFor(AuditLog)
final auditLogProvider = AuditLogFamily._();

/// One slice of §10.4's audit log, newest first.
///
/// A family keyed by the whole [AuditQuery] rather than a single notifier,
/// because the section asks two different questions of this log and an
/// administrator following a trail asks them in sequence: "what was done to
/// this account", then "what else has that administrator done". Keying by the
/// question is what lets the second answer arrive without discarding the
/// first, and what makes going back cost no request.
///
/// Not `keepAlive`, like every other §10 read: the log carries who did what to
/// whom, and a cache that outlived the screen would keep answering after the
/// administrator had moved on.
final class AuditLogProvider
    extends $AsyncNotifierProvider<AuditLog, AdminQueuePage<AuditEntry>> {
  /// One slice of §10.4's audit log, newest first.
  ///
  /// A family keyed by the whole [AuditQuery] rather than a single notifier,
  /// because the section asks two different questions of this log and an
  /// administrator following a trail asks them in sequence: "what was done to
  /// this account", then "what else has that administrator done". Keying by the
  /// question is what lets the second answer arrive without discarding the
  /// first, and what makes going back cost no request.
  ///
  /// Not `keepAlive`, like every other §10 read: the log carries who did what to
  /// whom, and a cache that outlived the screen would keep answering after the
  /// administrator had moved on.
  AuditLogProvider._({
    required AuditLogFamily super.from,
    required AuditQuery super.argument,
  }) : super(
         retry: null,
         name: r'auditLogProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$auditLogHash();

  @override
  String toString() {
    return r'auditLogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AuditLog create() => AuditLog();

  @override
  bool operator ==(Object other) {
    return other is AuditLogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$auditLogHash() => r'cb1991ae2bdabc308431f899cbe7d0b15b2c6a39';

/// One slice of §10.4's audit log, newest first.
///
/// A family keyed by the whole [AuditQuery] rather than a single notifier,
/// because the section asks two different questions of this log and an
/// administrator following a trail asks them in sequence: "what was done to
/// this account", then "what else has that administrator done". Keying by the
/// question is what lets the second answer arrive without discarding the
/// first, and what makes going back cost no request.
///
/// Not `keepAlive`, like every other §10 read: the log carries who did what to
/// whom, and a cache that outlived the screen would keep answering after the
/// administrator had moved on.

final class AuditLogFamily extends $Family
    with
        $ClassFamilyOverride<
          AuditLog,
          AsyncValue<AdminQueuePage<AuditEntry>>,
          AdminQueuePage<AuditEntry>,
          FutureOr<AdminQueuePage<AuditEntry>>,
          AuditQuery
        > {
  AuditLogFamily._()
    : super(
        retry: null,
        name: r'auditLogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One slice of §10.4's audit log, newest first.
  ///
  /// A family keyed by the whole [AuditQuery] rather than a single notifier,
  /// because the section asks two different questions of this log and an
  /// administrator following a trail asks them in sequence: "what was done to
  /// this account", then "what else has that administrator done". Keying by the
  /// question is what lets the second answer arrive without discarding the
  /// first, and what makes going back cost no request.
  ///
  /// Not `keepAlive`, like every other §10 read: the log carries who did what to
  /// whom, and a cache that outlived the screen would keep answering after the
  /// administrator had moved on.

  AuditLogProvider call(AuditQuery query) =>
      AuditLogProvider._(argument: query, from: this);

  @override
  String toString() => r'auditLogProvider';
}

/// One slice of §10.4's audit log, newest first.
///
/// A family keyed by the whole [AuditQuery] rather than a single notifier,
/// because the section asks two different questions of this log and an
/// administrator following a trail asks them in sequence: "what was done to
/// this account", then "what else has that administrator done". Keying by the
/// question is what lets the second answer arrive without discarding the
/// first, and what makes going back cost no request.
///
/// Not `keepAlive`, like every other §10 read: the log carries who did what to
/// whom, and a cache that outlived the screen would keep answering after the
/// administrator had moved on.

abstract class _$AuditLog extends $AsyncNotifier<AdminQueuePage<AuditEntry>> {
  late final _$args = ref.$arg as AuditQuery;
  AuditQuery get query => _$args;

  FutureOr<AdminQueuePage<AuditEntry>> build(AuditQuery query);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AdminQueuePage<AuditEntry>>,
              AdminQueuePage<AuditEntry>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AdminQueuePage<AuditEntry>>,
                AdminQueuePage<AuditEntry>
              >,
              AsyncValue<AdminQueuePage<AuditEntry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
