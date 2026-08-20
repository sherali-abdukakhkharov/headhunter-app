// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The candidate's vacancy filters, kept between sessions (§5.5).
///
/// Persisted for the same reason the employer's search config is: somebody who
/// narrows a feed to their occupation and region has done work, and losing it
/// on every cold start is why people stop using filters and go back to
/// scrolling. Plain preferences rather than secure storage — a filter set is
/// dictionary ids, a number and a date, and names nobody.
///
/// ## The feed watches this rather than taking it as an argument
///
/// `vacancyFeedProvider` is keyed on `Feed` alone and reads the filters through
/// `ref.watch`, so a filter change re-runs the query without changing the
/// provider's identity. That keeps all eight existing `invalidate` call sites
/// working: every one of them names a feed, and none of them would know which
/// filter set to name if the filters were part of the key.
///
/// It also means [FeedFilters] needs a **deep `==`** — without it `ref.watch`
/// cannot tell a changed set from the same one and the feed either never
/// refreshes or refreshes on every rebuild.

@ProviderFor(FeedFilterController)
final feedFilterControllerProvider = FeedFilterControllerProvider._();

/// The candidate's vacancy filters, kept between sessions (§5.5).
///
/// Persisted for the same reason the employer's search config is: somebody who
/// narrows a feed to their occupation and region has done work, and losing it
/// on every cold start is why people stop using filters and go back to
/// scrolling. Plain preferences rather than secure storage — a filter set is
/// dictionary ids, a number and a date, and names nobody.
///
/// ## The feed watches this rather than taking it as an argument
///
/// `vacancyFeedProvider` is keyed on `Feed` alone and reads the filters through
/// `ref.watch`, so a filter change re-runs the query without changing the
/// provider's identity. That keeps all eight existing `invalidate` call sites
/// working: every one of them names a feed, and none of them would know which
/// filter set to name if the filters were part of the key.
///
/// It also means [FeedFilters] needs a **deep `==`** — without it `ref.watch`
/// cannot tell a changed set from the same one and the feed either never
/// refreshes or refreshes on every rebuild.
final class FeedFilterControllerProvider
    extends $AsyncNotifierProvider<FeedFilterController, FeedFilters> {
  /// The candidate's vacancy filters, kept between sessions (§5.5).
  ///
  /// Persisted for the same reason the employer's search config is: somebody who
  /// narrows a feed to their occupation and region has done work, and losing it
  /// on every cold start is why people stop using filters and go back to
  /// scrolling. Plain preferences rather than secure storage — a filter set is
  /// dictionary ids, a number and a date, and names nobody.
  ///
  /// ## The feed watches this rather than taking it as an argument
  ///
  /// `vacancyFeedProvider` is keyed on `Feed` alone and reads the filters through
  /// `ref.watch`, so a filter change re-runs the query without changing the
  /// provider's identity. That keeps all eight existing `invalidate` call sites
  /// working: every one of them names a feed, and none of them would know which
  /// filter set to name if the filters were part of the key.
  ///
  /// It also means [FeedFilters] needs a **deep `==`** — without it `ref.watch`
  /// cannot tell a changed set from the same one and the feed either never
  /// refreshes or refreshes on every rebuild.
  FeedFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedFilterControllerHash();

  @$internal
  @override
  FeedFilterController create() => FeedFilterController();
}

String _$feedFilterControllerHash() =>
    r'0a00977aeb2fc2ac8b5f1c109b81a351739af375';

/// The candidate's vacancy filters, kept between sessions (§5.5).
///
/// Persisted for the same reason the employer's search config is: somebody who
/// narrows a feed to their occupation and region has done work, and losing it
/// on every cold start is why people stop using filters and go back to
/// scrolling. Plain preferences rather than secure storage — a filter set is
/// dictionary ids, a number and a date, and names nobody.
///
/// ## The feed watches this rather than taking it as an argument
///
/// `vacancyFeedProvider` is keyed on `Feed` alone and reads the filters through
/// `ref.watch`, so a filter change re-runs the query without changing the
/// provider's identity. That keeps all eight existing `invalidate` call sites
/// working: every one of them names a feed, and none of them would know which
/// filter set to name if the filters were part of the key.
///
/// It also means [FeedFilters] needs a **deep `==`** — without it `ref.watch`
/// cannot tell a changed set from the same one and the feed either never
/// refreshes or refreshes on every rebuild.

abstract class _$FeedFilterController extends $AsyncNotifier<FeedFilters> {
  FutureOr<FeedFilters> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FeedFilters>, FeedFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FeedFilters>, FeedFilters>,
              AsyncValue<FeedFilters>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
