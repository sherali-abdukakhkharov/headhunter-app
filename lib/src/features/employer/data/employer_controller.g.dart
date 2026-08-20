// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and writes the employer profile (§6.1).

@ProviderFor(EmployerEditor)
final employerEditorProvider = EmployerEditorProvider._();

/// Loads and writes the employer profile (§6.1).
final class EmployerEditorProvider
    extends $AsyncNotifierProvider<EmployerEditor, EmployerEditorState> {
  /// Loads and writes the employer profile (§6.1).
  EmployerEditorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'employerEditorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$employerEditorHash();

  @$internal
  @override
  EmployerEditor create() => EmployerEditor();
}

String _$employerEditorHash() => r'0ab8750ffdd8e56187d0e087a0229c03eca69266';

/// Loads and writes the employer profile (§6.1).

abstract class _$EmployerEditor extends $AsyncNotifier<EmployerEditorState> {
  FutureOr<EmployerEditorState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<EmployerEditorState>, EmployerEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EmployerEditorState>, EmployerEditorState>,
              AsyncValue<EmployerEditorState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Verification state and history (§6.1).
///
/// Separate from [EmployerEditor] because it is read far more often than the
/// profile is written, and because submitting must refresh it without
/// disturbing a form the user may be halfway through.

@ProviderFor(Verification)
final verificationProvider = VerificationProvider._();

/// Verification state and history (§6.1).
///
/// Separate from [EmployerEditor] because it is read far more often than the
/// profile is written, and because submitting must refresh it without
/// disturbing a form the user may be halfway through.
final class VerificationProvider
    extends $AsyncNotifierProvider<Verification, VerificationState> {
  /// Verification state and history (§6.1).
  ///
  /// Separate from [EmployerEditor] because it is read far more often than the
  /// profile is written, and because submitting must refresh it without
  /// disturbing a form the user may be halfway through.
  VerificationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verificationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verificationHash();

  @$internal
  @override
  Verification create() => Verification();
}

String _$verificationHash() => r'4c11106d5a6f4883dd660048de6abddf49988d94';

/// Verification state and history (§6.1).
///
/// Separate from [EmployerEditor] because it is read far more often than the
/// profile is written, and because submitting must refresh it without
/// disturbing a form the user may be halfway through.

abstract class _$Verification extends $AsyncNotifier<VerificationState> {
  FutureOr<VerificationState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<VerificationState>, VerificationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VerificationState>, VerificationState>,
              AsyncValue<VerificationState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
