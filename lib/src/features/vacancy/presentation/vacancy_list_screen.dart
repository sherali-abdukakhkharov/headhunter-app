import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/vacancy/data/vacancy_repository.dart';
import 'package:jobbridge_app/src/features/vacancy/domain/vacancy.dart';
import 'package:jobbridge_app/src/features/vacancy/presentation/vacancy_status.dart';

/// The employer's own vacancies, every status (§6.2).
///
/// **Closed ones included.** BR-11 removes a closed vacancy from discovery and
/// keeps it in the employer's history, so filtering it out here would hide
/// something the contract deliberately preserves.
class VacancyListScreen extends ConsumerWidget {
  const VacancyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final vacancies = ref.watch(myVacanciesProvider);

    return Scaffold(
      body: SafeArea(
        child: switch (vacancies) {
          // hasError first: retry is disabled app-wide, so a failure is
          // terminal and matching loading first spins over it forever.
          AsyncValue(hasError: true, :final error?) => Padding(
            padding: const EdgeInsets.all(HhSpace.gutter),
            child: HhErrorState(
              title: l10n.stateErrorTitle,
              message: error is ApiException
                  ? error.message
                  : l10n.stateErrorBody,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(myVacanciesProvider),
            ),
          ),
          AsyncData(:final value) => _List(vacancies: value),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _List extends ConsumerStatefulWidget {
  const _List({required this.vacancies});

  final List<Vacancy> vacancies;

  @override
  ConsumerState<_List> createState() => _ListState();
}

class _ListState extends ConsumerState<_List> {
  bool _creating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(HhSpace.gutter),
          child: HhButton(
            label: l10n.vacancyNew,
            iconPath: HhIconPath.plus,
            loading: _creating,
            onPressed: _creating ? null : _create,
          ),
        ),

        Expanded(
          child: widget.vacancies.isEmpty
              ? HhEmptyState(
                  title: l10n.stateEmptyTitle,
                  message: l10n.vacancyNone,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HhSpace.gutter,
                  ),
                  itemCount: widget.vacancies.length,
                  itemBuilder: (context, index) =>
                      _Row(vacancy: widget.vacancies[index]),
                ),
        ),
      ],
    );
  }

  Future<void> _create() async {
    setState(() => _creating = true);

    try {
      await createVacancyAndOpen(context, ref);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.vacancy});

  final Vacancy vacancy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: HhSpace.sm),
      child: HhCard(
        onTap: () =>
            context.go('${Routes.employerVacancies}/${vacancy.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // A draft may genuinely have no title yet; saying so beats an
              // empty row that looks like a rendering failure.
              vacancyTitle(vacancy, l10n),
              style: HhTypography.body.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: HhSpace.sm),
            Row(
              children: [
                vacancyBadge(vacancy.status, l10n),
                if (vacancy.isOpenForApplications) ...[
                  const SizedBox(width: HhSpace.sm),
                  Flexible(
                    child: Text(
                      l10n.vacancyOpenForApplications,
                      style: HhTypography.caption.copyWith(
                        color: HhColors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Creates an empty draft and opens its editor (§6.3).
///
/// Shared by the vacancy list and §6.2's dashboard, because the interesting
/// part is not the two lines of navigation: **BR-03 is checked at creation as
/// well as at submit**, so this is where an unverified employer finds out —
/// before filling in a form, which is the whole point of the server checking
/// twice. Two copies of that refusal path would eventually word it differently.
///
/// Returns false when the server refused, so a caller can leave its button
/// enabled.
Future<bool> createVacancyAndOpen(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);

  try {
    final created = await ref.read(vacancyRepositoryProvider).create();
    ref.invalidate(myVacanciesProvider);
    router.go('${Routes.employerVacancies}/${created.id}');
    return true;
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return false;
  }
}
