// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vacancy_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads one vacancy and the form that describes it (§6.3).
///
/// Two calls in order, because the second depends on the first: **the category
/// comes from the vacancy** and the form is per-category, exactly as the
/// candidate profile works. A vacancy with no occupation chosen yet has no
/// category, and the form still has to render — there is nowhere to choose the
/// occupation from otherwise.

@ProviderFor(VacancyEditor)
final vacancyEditorProvider = VacancyEditorFamily._();

/// Loads one vacancy and the form that describes it (§6.3).
///
/// Two calls in order, because the second depends on the first: **the category
/// comes from the vacancy** and the form is per-category, exactly as the
/// candidate profile works. A vacancy with no occupation chosen yet has no
/// category, and the form still has to render — there is nowhere to choose the
/// occupation from otherwise.
final class VacancyEditorProvider
    extends $AsyncNotifierProvider<VacancyEditor, VacancyEditorState> {
  /// Loads one vacancy and the form that describes it (§6.3).
  ///
  /// Two calls in order, because the second depends on the first: **the category
  /// comes from the vacancy** and the form is per-category, exactly as the
  /// candidate profile works. A vacancy with no occupation chosen yet has no
  /// category, and the form still has to render — there is nowhere to choose the
  /// occupation from otherwise.
  VacancyEditorProvider._({
    required VacancyEditorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vacancyEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vacancyEditorHash();

  @override
  String toString() {
    return r'vacancyEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VacancyEditor create() => VacancyEditor();

  @override
  bool operator ==(Object other) {
    return other is VacancyEditorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vacancyEditorHash() => r'0019e1a7ad103de48a30e28d055d912cea88d46b';

/// Loads one vacancy and the form that describes it (§6.3).
///
/// Two calls in order, because the second depends on the first: **the category
/// comes from the vacancy** and the form is per-category, exactly as the
/// candidate profile works. A vacancy with no occupation chosen yet has no
/// category, and the form still has to render — there is nowhere to choose the
/// occupation from otherwise.

final class VacancyEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          VacancyEditor,
          AsyncValue<VacancyEditorState>,
          VacancyEditorState,
          FutureOr<VacancyEditorState>,
          String
        > {
  VacancyEditorFamily._()
    : super(
        retry: null,
        name: r'vacancyEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads one vacancy and the form that describes it (§6.3).
  ///
  /// Two calls in order, because the second depends on the first: **the category
  /// comes from the vacancy** and the form is per-category, exactly as the
  /// candidate profile works. A vacancy with no occupation chosen yet has no
  /// category, and the form still has to render — there is nowhere to choose the
  /// occupation from otherwise.

  VacancyEditorProvider call(String id) =>
      VacancyEditorProvider._(argument: id, from: this);

  @override
  String toString() => r'vacancyEditorProvider';
}

/// Loads one vacancy and the form that describes it (§6.3).
///
/// Two calls in order, because the second depends on the first: **the category
/// comes from the vacancy** and the form is per-category, exactly as the
/// candidate profile works. A vacancy with no occupation chosen yet has no
/// category, and the form still has to render — there is nowhere to choose the
/// occupation from otherwise.

abstract class _$VacancyEditor extends $AsyncNotifier<VacancyEditorState> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<VacancyEditorState> build(String id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<VacancyEditorState>, VacancyEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VacancyEditorState>, VacancyEditorState>,
              AsyncValue<VacancyEditorState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
