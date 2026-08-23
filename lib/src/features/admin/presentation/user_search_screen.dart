import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/core/router/routes.dart';
import 'package:jobbridge_app/src/features/admin/data/admin_repository.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_user.dart';
import 'package:jobbridge_app/src/features/admin/domain/user_search_filters.dart';
import 'package:jobbridge_app/src/features/admin/presentation/account_status_badge.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';
import 'package:jobbridge_app/src/shared/widgets/iso_date_field.dart';

/// §10.4's user search: the tab an administrator finds a person from (UAT-14).
///
/// ## The screen does not search on open
///
/// Every other §10 tab loads its list on arrival. This one waits, and the
/// reason is the one that keeps the verification queue from prefetching
/// evidence: §11.1 logs every read of protected data, `GET /admin/users`
/// answers with phone numbers, and a tab that searched on open would write a
/// log line nobody asked for every time somebody passed through it.
///
/// The one exception proves the rule rather than breaking it — arriving from a
/// dashboard counter *is* an administrator asking, and the question is in the
/// location (see [Routes.adminUserStatusParam]).
///
/// ## Paging bites before the filters do
///
/// Results are newest registration first, then `limit`/`offset`. So an account
/// registered two years ago that matches a broad filter sits **past the page
/// rather than outside the filter**, and from here those look identical. The
/// screen therefore says how the list is ordered whenever there is more of it,
/// rather than letting an administrator page through a hundred rows and
/// conclude somebody does not exist. Narrow filters beat large pages, and the
/// phone box says so: the match is a substring, so the last four digits of a
/// number find an account that a mistyped full number never will.
///
/// ## Two fields are the search; four are refinements
///
/// Phone and name are what an administrator arrives holding. Role, status and
/// the registration window sit behind a disclosure, because six controls above
/// a result list is a web panel's layout and §10 puts this on a phone. The
/// disclosure opens itself when something inside it is filtering, so a list can
/// never be narrowed by a control that is out of sight.
class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _phone = TextEditingController();
  final _name = TextEditingController();

  AppRole? _role;
  UserAccountStatus? _status;
  String? _registeredFrom;
  String? _registeredTo;

  bool _showRefinements = false;

  /// The `?status=` this screen has already acted on.
  ///
  /// Compared against rather than read fresh on every build, because adopting
  /// it runs a search: a rebuild for any other reason — a keystroke, a chip —
  /// must not re-ask the server the question it already answered.
  String? _adoptedStatus;
  bool _hasAdopted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final raw = GoRouterState.of(
      context,
    ).uri.queryParameters[Routes.adminUserStatusParam];
    if (_hasAdopted && raw == _adoptedStatus) return;

    _hasAdopted = true;
    _adoptedStatus = raw;
    if (raw == null) return;

    setState(() {
      // Everything else is cleared. A counter says "show me the restricted
      // accounts", not "show me the restricted accounts among the ones I was
      // looking for ten minutes ago" — and a filter left over from an earlier
      // search would narrow a list the administrator never asked to narrow.
      _phone.clear();
      _name.clear();
      _role = null;
      _registeredFrom = null;
      _registeredTo = null;
      _status = UserAccountStatus.fromWire(raw);
      _showRefinements = true;
    });

    // After the frame: a provider must not be written while the tree that
    // depends on it is being built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_run());
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    _name.dispose();
    super.dispose();
  }

  UserSearchFilters get _filters => UserSearchFilters(
    phone: _phone.text,
    name: _name.text,
    role: _role,
    status: _status,
    registeredFrom: _registeredFrom,
    registeredTo: _registeredTo,
  );

  Future<void> _run() =>
      ref.read(userSearchProvider.notifier).search(_filters);

  void _clear() {
    setState(() {
      _phone.clear();
      _name.clear();
      _role = null;
      _status = null;
      _registeredFrom = null;
      _registeredTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final filters = _filters;
    final results = ref.watch(userSearchProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HhSpace.gutter),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.adminUsersTitle,
                    style: HhTypography.title,
                  ),
                ),
                // §10.4 is "user management **and** audit", and this is the
                // only way to the log that is not about somebody in
                // particular. It costs a header row rather than a tab: the
                // shell is capped at five and all five are spoken for.
                HhButton.text(
                  label: l10n.adminAuditTitle,
                  onPressed: () =>
                      GoRouter.of(context).go(Routes.adminAudit),
                ),
              ],
            ),
            const SizedBox(height: HhSpace.md),

            HhTextField(
              label: l10n.adminUserSearchPhone,
              controller: _phone,
              hintText: l10n.adminUserSearchPhoneHint,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.search,
              // Live rather than on submit: the button is disabled while this
              // shows, so the field has to say why before it is pressed.
              errorText: filters.phoneIsTooShort
                  ? l10n.adminUserSearchPhoneTooShort
                  : null,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (filters.isRunnable) unawaited(_run());
              },
            ),
            const SizedBox(height: HhSpace.md),
            HhTextField(
              label: l10n.adminUserSearchName,
              controller: _name,
              hintText: l10n.adminUserSearchNameHint,
              textInputAction: TextInputAction.search,
              errorText: filters.nameIsTooShort
                  ? l10n.adminUserSearchNameTooShort
                  : null,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (filters.isRunnable) unawaited(_run());
              },
            ),

            const SizedBox(height: HhSpace.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: HhButton.text(
                label: _showRefinements
                    ? l10n.adminUserSearchFewer
                    : l10n.adminUserSearchMore,
                onPressed: () =>
                    setState(() => _showRefinements = !_showRefinements),
              ),
            ),

            if (_showRefinements) ...[
              const SizedBox(height: HhSpace.sm),
              _Refinements(
                role: _role,
                status: _status,
                registeredFrom: _registeredFrom,
                registeredTo: _registeredTo,
                datesAreReversed: filters.datesAreReversed,
                onRole: (role) => setState(() => _role = role),
                onStatus: (status) => setState(() => _status = status),
                onFrom: (day) => setState(() => _registeredFrom = day),
                onTo: (day) => setState(() => _registeredTo = day),
              ),
            ],

            const SizedBox(height: HhSpace.lg),
            HhButton(
              label: l10n.adminUserSearchRun,
              loading: results.isLoading,
              // Disabled rather than refused: the server's minimums are on the
              // fields, so a search that would come back 400 never leaves.
              onPressed: filters.isRunnable && !results.isLoading
                  ? _run
                  : null,
            ),
            if (!filters.isEmpty) ...[
              const SizedBox(height: HhSpace.sm),
              HhButton.text(
                label: l10n.adminUserSearchClear,
                onPressed: _clear,
              ),
            ],

            const SizedBox(height: HhSpace.lg),
            // Error first: with retry disabled app-wide a failed search is a
            // terminal state, and matching loading first would spin over it.
            switch (results) {
              AsyncValue(hasError: true, :final error?) => HhErrorState(
                title: l10n.stateErrorTitle,
                message: error is ApiException
                    ? error.message
                    : l10n.stateErrorBody,
                retryLabel: l10n.commonRetry,
                onRetry: _run,
              ),
              // Null is not empty. "Nothing has been searched for" and "nothing
              // matches this" are different answers, and §10.4's paging makes
              // them the two an administrator most needs told apart.
              AsyncData(value: null) => HhEmptyState(
                title: l10n.adminUserSearchIdle,
                message: l10n.adminUserSearchIdleBody,
              ),
              AsyncData(value: final page?) => _Results(page: page),
              _ => const Padding(
                padding: EdgeInsets.only(top: HhSpace.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
          ],
        ),
      ),
    );
  }
}

/// The four filters an administrator narrows with once the first two have not
/// been enough.
class _Refinements extends StatelessWidget {
  const _Refinements({
    required this.role,
    required this.status,
    required this.registeredFrom,
    required this.registeredTo,
    required this.datesAreReversed,
    required this.onRole,
    required this.onStatus,
    required this.onFrom,
    required this.onTo,
  });

  final AppRole? role;
  final UserAccountStatus? status;
  final String? registeredFrom;
  final String? registeredTo;
  final bool datesAreReversed;
  final ValueChanged<AppRole?> onRole;
  final ValueChanged<UserAccountStatus?> onStatus;
  final ValueChanged<String?> onFrom;
  final ValueChanged<String?> onTo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "Holds", never "is": §2.3 lets one account hold several roles, so a
        // candidate who also employs is matched by either. A label reading
        // "Role" would invite an administrator to conclude the opposite from
        // an employer row that answers a candidate search.
        Text(l10n.adminUserSearchRole, style: HhTypography.label),
        const SizedBox(height: HhSpace.sm),
        Wrap(
          spacing: HhSpace.sm,
          runSpacing: HhSpace.sm,
          children: [
            for (final value in AppRole.values)
              HhFilterChip(
                label: _roleLabel(value, l10n),
                selected: role == value,
                // Tapping the lit chip clears it — with no "any" chip, this is
                // the only way back to no constraint, and it is the behaviour
                // a lit toggle already implies.
                onTap: () => onRole(role == value ? null : value),
              ),
          ],
        ),

        const SizedBox(height: HhSpace.md),
        Text(l10n.adminUserSearchStatus, style: HhTypography.label),
        const SizedBox(height: HhSpace.sm),
        Wrap(
          spacing: HhSpace.sm,
          runSpacing: HhSpace.sm,
          children: [
            for (final value in UserAccountStatus.values)
              HhFilterChip(
                label: accountStatusLabel(value, l10n),
                selected: status == value,
                onTap: () => onStatus(status == value ? null : value),
              ),
          ],
        ),

        const SizedBox(height: HhSpace.md),
        IsoDateField(
          label: l10n.adminUserSearchRegisteredFrom,
          value: registeredFrom,
          onChanged: onFrom,
        ),
        const SizedBox(height: HhSpace.md),
        IsoDateField(
          label: l10n.adminUserSearchRegisteredTo,
          value: registeredTo,
          onChanged: onTo,
        ),
        if (datesAreReversed) ...[
          const SizedBox(height: HhSpace.sm),
          // The one filter mistake the server answers with an empty list
          // rather than a refusal — which is the answer hardest to tell from
          // "this person does not exist".
          HhNotice.restricted(
            title: l10n.adminUserSearchDatesReversed,
            message: l10n.adminUserSearchDatesReversedBody,
          ),
        ],
      ],
    );
  }

  String _roleLabel(AppRole role, AppL10n l10n) => switch (role) {
    AppRole.candidate => l10n.roleCandidate,
    AppRole.employer => l10n.roleEmployer,
    AppRole.admin => l10n.roleAdmin,
  };
}

/// One page of results, and what the administrator has to know about it.
class _Results extends ConsumerWidget {
  const _Results({required this.page});

  final AdminQueuePage<AdminUser> page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);

    if (page.items.isEmpty) {
      return HhEmptyState(
        title: l10n.adminUserSearchEmpty,
        message: l10n.adminUserSearchEmptyBody,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Only when there is more of it. Said on a short list this would be
        // noise; said on a full one it is the difference between narrowing the
        // search and concluding somebody does not exist.
        if (page.hasMore) ...[
          Text(l10n.adminUserSearchOrder, style: HhTypography.caption),
          const SizedBox(height: HhSpace.md),
        ],

        for (final user in page.items) ...[
          _UserRow(user: user),
          const SizedBox(height: HhSpace.md),
        ],

        if (page.isLoadingMore)
          HhLoadingMore(label: l10n.commonLoadingMore)
        else if (page.hasMore)
          HhButton.text(
            label: l10n.commonShowMore,
            onPressed: () => _loadMore(context, ref),
          ),
      ],
    );
  }

  Future<void> _loadMore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(userSearchProvider.notifier).loadMore();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// One account: who they are, what they hold, and what state the account is in.
class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      onTap: () => GoRouter.of(context).go(Routes.adminUserFor(user.userId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // Null is not "unnamed by choice": the server resolves a
                  // name from five columns, so nothing here means the account
                  // has none anywhere yet. Saying so beats an empty line.
                  user.name ?? l10n.adminUserNoName,
                  style: HhTypography.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: HhSpace.sm),
              accountStatusBadge(user.status.wire, l10n),
            ],
          ),

          const SizedBox(height: HhSpace.sm),
          Row(
            children: [
              const HhIcon(
                HhIconPath.phone,
                size: 15,
                color: HhColors.inkSubtle,
              ),
              const SizedBox(width: 6),
              Expanded(
                // BR-09's `admin` branch: this is the field §10.4 searches by,
                // and §11.1 answers the exposure by logging the read rather
                // than by withholding it.
                child: Text(
                  user.phone ?? l10n.adminUserNoPhone,
                  style: HhTypography.body,
                ),
              ),
              const HhIcon(
                HhIconPath.chevronRight,
                size: 18,
                color: HhColors.inkSubtle,
              ),
            ],
          ),

          const SizedBox(height: HhSpace.sm),
          Wrap(
            spacing: HhSpace.sm,
            runSpacing: HhSpace.xs,
            children: [for (final role in user.roles) roleChip(role, l10n)],
          ),

          const SizedBox(height: HhSpace.sm),
          // A caption rather than a fourth chip. `HhMetaChip` does not shrink
          // its label — its `Row` is `min` with an unconstrained `Text`, the
          // flaw `HhRemovableChip` documents and fixes — and "Registered
          // 2026-03-14" is long enough in Russian to overflow the card on a
          // 360pt phone. The chips left here are single words.
          Text(
            l10n.adminUserRegistered(wallClockDay(user.createdAt.wallClock)),
            style: HhTypography.caption,
          ),
        ],
      ),
    );
  }
}
