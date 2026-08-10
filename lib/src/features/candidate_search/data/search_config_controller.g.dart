// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_config_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The employer's current search configuration, kept between sessions.
///
/// ## Why it is persisted
///
/// §7.1's filter set has thirty-four fields. An employer who narrows a search
/// to eight of them and closes the app has done real work, and losing it is the
/// reason people stop using a filter builder and go back to scrolling.
///
/// ## The restrictions are persisted too, deliberately
///
/// A restored set includes any BR-12 age or gender filter **and the
/// justification it was declared with** — the two are stored together and
/// neither survives without the other ([CandidateSearchFilters.removing]). The
/// alternative, quietly dropping them on restore, trades one surprise for a
/// worse one: filters the employer set and can no longer see. What makes this
/// safe is that a restriction is never invisible — it is always one of the
/// applied-filter chips, and the server logs every search that uses one.
///
/// Stored in plain preferences rather than secure storage: a filter set is the
/// employer's own search, not anyone's personal data. No candidate appears in
/// it — only dictionary ids, numbers and dates.

@ProviderFor(SearchConfigController)
final searchConfigControllerProvider = SearchConfigControllerProvider._();

/// The employer's current search configuration, kept between sessions.
///
/// ## Why it is persisted
///
/// §7.1's filter set has thirty-four fields. An employer who narrows a search
/// to eight of them and closes the app has done real work, and losing it is the
/// reason people stop using a filter builder and go back to scrolling.
///
/// ## The restrictions are persisted too, deliberately
///
/// A restored set includes any BR-12 age or gender filter **and the
/// justification it was declared with** — the two are stored together and
/// neither survives without the other ([CandidateSearchFilters.removing]). The
/// alternative, quietly dropping them on restore, trades one surprise for a
/// worse one: filters the employer set and can no longer see. What makes this
/// safe is that a restriction is never invisible — it is always one of the
/// applied-filter chips, and the server logs every search that uses one.
///
/// Stored in plain preferences rather than secure storage: a filter set is the
/// employer's own search, not anyone's personal data. No candidate appears in
/// it — only dictionary ids, numbers and dates.
final class SearchConfigControllerProvider
    extends $AsyncNotifierProvider<SearchConfigController, SearchConfig> {
  /// The employer's current search configuration, kept between sessions.
  ///
  /// ## Why it is persisted
  ///
  /// §7.1's filter set has thirty-four fields. An employer who narrows a search
  /// to eight of them and closes the app has done real work, and losing it is the
  /// reason people stop using a filter builder and go back to scrolling.
  ///
  /// ## The restrictions are persisted too, deliberately
  ///
  /// A restored set includes any BR-12 age or gender filter **and the
  /// justification it was declared with** — the two are stored together and
  /// neither survives without the other ([CandidateSearchFilters.removing]). The
  /// alternative, quietly dropping them on restore, trades one surprise for a
  /// worse one: filters the employer set and can no longer see. What makes this
  /// safe is that a restriction is never invisible — it is always one of the
  /// applied-filter chips, and the server logs every search that uses one.
  ///
  /// Stored in plain preferences rather than secure storage: a filter set is the
  /// employer's own search, not anyone's personal data. No candidate appears in
  /// it — only dictionary ids, numbers and dates.
  SearchConfigControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchConfigControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchConfigControllerHash();

  @$internal
  @override
  SearchConfigController create() => SearchConfigController();
}

String _$searchConfigControllerHash() =>
    r'4f5167ef042a5554a674b3a68b0faa220c812c98';

/// The employer's current search configuration, kept between sessions.
///
/// ## Why it is persisted
///
/// §7.1's filter set has thirty-four fields. An employer who narrows a search
/// to eight of them and closes the app has done real work, and losing it is the
/// reason people stop using a filter builder and go back to scrolling.
///
/// ## The restrictions are persisted too, deliberately
///
/// A restored set includes any BR-12 age or gender filter **and the
/// justification it was declared with** — the two are stored together and
/// neither survives without the other ([CandidateSearchFilters.removing]). The
/// alternative, quietly dropping them on restore, trades one surprise for a
/// worse one: filters the employer set and can no longer see. What makes this
/// safe is that a restriction is never invisible — it is always one of the
/// applied-filter chips, and the server logs every search that uses one.
///
/// Stored in plain preferences rather than secure storage: a filter set is the
/// employer's own search, not anyone's personal data. No candidate appears in
/// it — only dictionary ids, numbers and dates.

abstract class _$SearchConfigController extends $AsyncNotifier<SearchConfig> {
  FutureOr<SearchConfig> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SearchConfig>, SearchConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SearchConfig>, SearchConfig>,
              AsyncValue<SearchConfig>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
