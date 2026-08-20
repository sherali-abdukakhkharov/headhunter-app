import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/candidate_search_repository.dart';
import 'package:jobbridge_app/src/features/candidate_search/data/search_config_controller.dart';

/// UAT-06: opens candidate search with [vacancyId]'s requirements applied.
///
/// The prefill is fetched **before** navigating, so the search tab is never
/// entered showing the previous search's filters and then reshuffled a moment
/// later. A failed prefill leaves the caller where they are with a reason,
/// rather than on a search screen that quietly ignored the vacancy.
///
/// Shared by the vacancy editor and by that vacancy's shortlist — the screen
/// whose only cure for being empty is to go and find somebody, so it would
/// otherwise have needed a second copy of this.
Future<void> findCandidatesForVacancy(
  BuildContext context,
  WidgetRef ref,
  String vacancyId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);

  try {
    final filters = await ref
        .read(candidateSearchRepositoryProvider)
        .prefill(vacancyId);

    await ref
        .read(searchConfigControllerProvider.notifier)
        .prefillFrom(vacancyId, filters);

    router.go(Routes.employerCandidates);
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }
}
