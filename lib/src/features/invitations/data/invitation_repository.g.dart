// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(invitationRepository)
final invitationRepositoryProvider = InvitationRepositoryProvider._();

final class InvitationRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<InvitationRepository>,
          InvitationRepository,
          FutureOr<InvitationRepository>
        >
    with
        $FutureModifier<InvitationRepository>,
        $FutureProvider<InvitationRepository> {
  InvitationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invitationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invitationRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<InvitationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InvitationRepository> create(Ref ref) {
    return invitationRepository(ref);
  }
}

String _$invitationRepositoryHash() =>
    r'6a7c7a7b186019f57e82c3971bf730a9eb751a1f';

/// The candidate's invitation inbox (§8.2).

@ProviderFor(receivedInvitations)
final receivedInvitationsProvider = ReceivedInvitationsProvider._();

/// The candidate's invitation inbox (§8.2).

final class ReceivedInvitationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Invitation>>,
          List<Invitation>,
          FutureOr<List<Invitation>>
        >
    with $FutureModifier<List<Invitation>>, $FutureProvider<List<Invitation>> {
  /// The candidate's invitation inbox (§8.2).
  ReceivedInvitationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receivedInvitationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receivedInvitationsHash();

  @$internal
  @override
  $FutureProviderElement<List<Invitation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Invitation>> create(Ref ref) {
    return receivedInvitations(ref);
  }
}

String _$receivedInvitationsHash() =>
    r'ac0b28d15080f67145550447afb7c084dfa55ef3';

/// Invitations this employer has sent, optionally narrowed server-side (§8.2).

@ProviderFor(sentInvitations)
final sentInvitationsProvider = SentInvitationsFamily._();

/// Invitations this employer has sent, optionally narrowed server-side (§8.2).

final class SentInvitationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Invitation>>,
          List<Invitation>,
          FutureOr<List<Invitation>>
        >
    with $FutureModifier<List<Invitation>>, $FutureProvider<List<Invitation>> {
  /// Invitations this employer has sent, optionally narrowed server-side (§8.2).
  SentInvitationsProvider._({
    required SentInvitationsFamily super.from,
    required ({String? vacancyId, String? status}) super.argument,
  }) : super(
         retry: null,
         name: r'sentInvitationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sentInvitationsHash();

  @override
  String toString() {
    return r'sentInvitationsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Invitation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Invitation>> create(Ref ref) {
    final argument = this.argument as ({String? vacancyId, String? status});
    return sentInvitations(
      ref,
      vacancyId: argument.vacancyId,
      status: argument.status,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SentInvitationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sentInvitationsHash() => r'a877b9e193577801a83dd278aea58f5e81985f29';

/// Invitations this employer has sent, optionally narrowed server-side (§8.2).

final class SentInvitationsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Invitation>>,
          ({String? vacancyId, String? status})
        > {
  SentInvitationsFamily._()
    : super(
        retry: null,
        name: r'sentInvitationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Invitations this employer has sent, optionally narrowed server-side (§8.2).

  SentInvitationsProvider call({String? vacancyId, String? status}) =>
      SentInvitationsProvider._(
        argument: (vacancyId: vacancyId, status: status),
        from: this,
      );

  @override
  String toString() => r'sentInvitationsProvider';
}

/// Today's remaining invitations, or null on a server without the cap.
///
/// Watched by the send screen rather than fetched once, so sending — which
/// invalidates it — redraws the counter.

@ProviderFor(invitationQuota)
final invitationQuotaProvider = InvitationQuotaProvider._();

/// Today's remaining invitations, or null on a server without the cap.
///
/// Watched by the send screen rather than fetched once, so sending — which
/// invalidates it — redraws the counter.

final class InvitationQuotaProvider
    extends
        $FunctionalProvider<
          AsyncValue<InvitationQuota?>,
          InvitationQuota?,
          FutureOr<InvitationQuota?>
        >
    with $FutureModifier<InvitationQuota?>, $FutureProvider<InvitationQuota?> {
  /// Today's remaining invitations, or null on a server without the cap.
  ///
  /// Watched by the send screen rather than fetched once, so sending — which
  /// invalidates it — redraws the counter.
  InvitationQuotaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invitationQuotaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invitationQuotaHash();

  @$internal
  @override
  $FutureProviderElement<InvitationQuota?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InvitationQuota?> create(Ref ref) {
    return invitationQuota(ref);
  }
}

String _$invitationQuotaHash() => r'8dcc40a12e9355afa5b58d2a4f63c5a877aac457';

/// §7.4's invitation counts for one vacancy.

@ProviderFor(invitationCounts)
final invitationCountsProvider = InvitationCountsFamily._();

/// §7.4's invitation counts for one vacancy.

final class InvitationCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          FutureOr<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $FutureProvider<Map<String, int>> {
  /// §7.4's invitation counts for one vacancy.
  InvitationCountsProvider._({
    required InvitationCountsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'invitationCountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$invitationCountsHash();

  @override
  String toString() {
    return r'invitationCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, int>> create(Ref ref) {
    final argument = this.argument as String;
    return invitationCounts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InvitationCountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$invitationCountsHash() => r'8e9bccd625015381a2ac8334d1d9af2f133d8e5b';

/// §7.4's invitation counts for one vacancy.

final class InvitationCountsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, int>>, String> {
  InvitationCountsFamily._()
    : super(
        retry: null,
        name: r'invitationCountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// §7.4's invitation counts for one vacancy.

  InvitationCountsProvider call(String vacancyId) =>
      InvitationCountsProvider._(argument: vacancyId, from: this);

  @override
  String toString() => r'invitationCountsProvider';
}

/// BR-08's trail for one invitation, for whichever side is looking.

@ProviderFor(invitationHistory)
final invitationHistoryProvider = InvitationHistoryFamily._();

/// BR-08's trail for one invitation, for whichever side is looking.

final class InvitationHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InvitationEvent>>,
          List<InvitationEvent>,
          FutureOr<List<InvitationEvent>>
        >
    with
        $FutureModifier<List<InvitationEvent>>,
        $FutureProvider<List<InvitationEvent>> {
  /// BR-08's trail for one invitation, for whichever side is looking.
  InvitationHistoryProvider._({
    required InvitationHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'invitationHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$invitationHistoryHash();

  @override
  String toString() {
    return r'invitationHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<InvitationEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InvitationEvent>> create(Ref ref) {
    final argument = this.argument as String;
    return invitationHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InvitationHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$invitationHistoryHash() => r'3bb2686864a601c0a44a55c11d389aaa0f547c4b';

/// BR-08's trail for one invitation, for whichever side is looking.

final class InvitationHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<InvitationEvent>>, String> {
  InvitationHistoryFamily._()
    : super(
        retry: null,
        name: r'invitationHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// BR-08's trail for one invitation, for whichever side is looking.

  InvitationHistoryProvider call(String id) =>
      InvitationHistoryProvider._(argument: id, from: this);

  @override
  String toString() => r'invitationHistoryProvider';
}
