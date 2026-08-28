import 'package:jobbridge_app/src/core/auth/app_role.dart';

/// Every route path in the app, in one place.
///
/// Never inline a path string at a call site: a typo in
/// `context.go('/canidate')` is a silent no-op redirect, and the whole redirect
/// chain becomes untestable once paths are scattered.
///
/// ## Two naming rules the router depends on
///
/// 1. **A shell route begins with its role's [AppRole.pathPrefix].** That is
///    how [AppRole.fromLocation] decides which role a deep link needs, so a
///    path that does not follow it becomes unreachable for a user in another
///    role. `routes_test.dart` asserts the constants below against the enum,
///    because these are string literals - `AppRole.candidate.pathPrefix` is an
///    instance getter and cannot appear in a `const`.
/// 2. **A leading underscore marks a development surface.** [isDevelopmentPath]
///    paths sit outside the redirect chain entirely, are never linked from
///    product UI, and are not registered at all in the production flavor.
abstract final class Routes {
  /// Cold start. Held here while the session is still being restored, so a
  /// signed-in user never sees a frame of onboarding.
  static const splash = '/';

  // --- Pre-session ---------------------------------------------------------

  /// Language choice, terms acceptance and phone entry (§4.1). M1.
  ///
  /// Sign-in is **phone + OTP**, as §4.1 and UAT-01 specify. Telegram login was
  /// tried and deprecated on 2026-08-05; docs/TELEGRAM_LOGIN.md records why and
  /// what remains.
  static const onboarding = '/onboarding';

  /// Code entry, the second step of sign-in (§4.1).
  ///
  /// **A child of [onboarding], and that is load-bearing twice.** It gives the
  /// user a real back gesture to the phone field for free, and it keeps the
  /// whole pre-session flow under one prefix so the redirect chain can admit it
  /// with `startsWith` rather than growing a list of exceptions.
  ///
  /// Not deep-linkable in any useful sense: it needs a phone number that only
  /// the previous screen has, so reaching it cold bounces back to [onboarding].
  static const otpVerification = '$onboarding/verify';

  /// Candidate / employer / both (§2.3). Reached when an account holds no role.
  static const roleSelection = '/role-selection';

  /// BR-10: the account is blocked and the app must say so rather than fail
  /// mysteriously.
  static const blocked = '/blocked';

  /// §12.4: there are tokens and the server could not be reached to exchange
  /// them, so the app knows it has an account and cannot yet describe it.
  ///
  /// Its own path rather than a flag on onboarding, because it is a different
  /// answer: onboarding asks for a phone number, and this screen has nothing to
  /// ask for — it has a retry.
  static const offline = '/offline';

  // --- Candidate shell -----------------------------------------------------

  static const candidateHome = '/candidate/home';
  static const candidateVacancies = '/candidate/vacancies';
  static const candidateApplications = '/candidate/applications';
  static const candidateMessages = '/candidate/messages';
  static const candidateProfile = '/candidate/profile';

  /// One schema section of the candidate profile, by its **schema code**.
  ///
  /// A path parameter rather than one route per section, because the section
  /// list is the server's: §5.2 makes the form depend on the work category, and
  /// §10.3 lets an administrator add a category at runtime. A route table
  /// naming today's ten sections would be a second copy of the schema, wrong
  /// the first time one is added.
  ///
  /// A code the schema does not carry lands on the hub rather than on an empty
  /// page — see `ProfileSectionScreen`.
  static String candidateProfileSection(String code) =>
      '$candidateProfile/$code';

  /// The attachment slots (§4.5) and the visibility switch (BR-02), which are
  /// pages beside the schema's sections without being schema sections.
  ///
  /// **Literal paths, registered before the `:section` parameter**, so they
  /// win the match. That does mean a schema section code of `files` or
  /// `visibility` would be unreachable; neither exists, and the collision is
  /// cheaper than a second parameter to disambiguate.
  static const candidateProfileFiles = '$candidateProfile/files';
  static const candidateProfileVisibility = '$candidateProfile/visibility';

  /// Which of §5.5's three feeds the vacancies tab is showing.
  ///
  /// In the **location** rather than in the screen's state, and the reason is
  /// the one `?queue=` records: a `StatefulShellRoute` keeps each branch, so a
  /// segment held in a `State` survives a later `go` and ignores it. Home links
  /// to two of the three feeds, and without this both would land on whichever
  /// one was last looked at.
  ///
  /// The value is a `Feed` wire name; anything unrecognised — or absent —
  /// reads as recommended, which is what an unqualified "vacancies" means.
  static const candidateFeedParam = 'feed';

  /// The vacancies tab, showing one named feed.
  static String candidateVacanciesWith(String feed) =>
      '$candidateVacancies?$candidateFeedParam=$feed';

  // --- Employer shell ------------------------------------------------------

  static const employerHome = '/employer/home';
  static const employerVacancies = '/employer/vacancies';
  static const employerCandidates = '/employer/candidates';
  static const employerMessages = '/employer/messages';
  static const employerCompany = '/employer/company';

  // --- Admin shell ---------------------------------------------------------

  static const adminDashboard = '/admin/dashboard';
  static const adminQueue = '/admin/queue';
  static const adminComplaints = '/admin/complaints';
  static const adminUsers = '/admin/users';
  static const adminDictionaries = '/admin/dictionaries';

  /// §10.3's items for one dictionary type.
  ///
  /// The type travels in the **path** rather than the query, unlike the two
  /// filters the admin shell carries: it is not a filter on a list, it is
  /// which list. A type code is a stable identifier and there is nothing else
  /// under this tab for it to collide with.
  static String adminDictionaryFor(String type) =>
      '$adminDictionaries/$type';

  /// Which of §10.2's two queues the moderation tab is showing.
  ///
  /// **A query parameter rather than screen state**, and that is the whole
  /// reason it exists. The shell keeps a branch's state across tab switches, so
  /// a segment held in a `State` would ignore a later `go` — §10.1's dashboard
  /// has a counter per queue, and both would land on whichever one was last
  /// looked at. Putting it in the location keeps the rule this router already
  /// runs on: the destination decides what is shown.
  static const adminQueueParam = 'queue';
  static const adminQueueVerification = 'verification';
  static const adminQueueVacancies = 'vacancies';

  /// The moderation tab, showing one named queue.
  static String adminQueueWith(String queue) =>
      '$adminQueue?$adminQueueParam=$queue';

  /// §10.2's vacancy review, a child of the moderation tab so it keeps the
  /// shell's nav bar and the back gesture returns to the queue.
  static String adminVacancyReviewFor(String vacancyId) =>
      '$adminQueue/$adminQueueVacancies/$vacancyId';

  /// §10.2's complaint review, a child of the complaints tab for the same
  /// reason: back returns to the queue with its place kept.
  static String adminComplaintFor(String complaintId) =>
      '$adminComplaints/$complaintId';

  /// Which account status §10.4's user tab is showing, when it was reached
  /// from a dashboard counter.
  ///
  /// **Only status, and only from a counter.** §10.4 has six filters and five
  /// of them are questions a person types on the screen; this one is the only
  /// one a *destination* names — §10.1's "restricted users" and "blocked
  /// users" are places, and a counter that leads nowhere is the thing the
  /// dashboard's own rule forbids. It is in the location rather than in state
  /// for the reason `?queue=` is: the shell keeps a branch across tab
  /// switches, so two counters writing screen state would both land on
  /// whichever was tapped first.
  static const adminUserStatusParam = 'status';

  /// §10.4's user list, filtered to one account status.
  static String adminUsersWithStatus(String status) =>
      '$adminUsers?$adminUserStatusParam=$status';

  /// §10.4's user screen, a child of the users tab so back returns to the
  /// results the administrator searched for.
  static String adminUserFor(String userId) => '$adminUsers/$userId';

  /// §10.4's audit log.
  ///
  /// **A sibling of `adminUserFor`, and it must be registered before it** — the
  /// user screen's path is `:id`, which would match the literal `audit` too.
  /// go_router takes the first route that matches, so the order in
  /// `app_router.dart` is load-bearing and is commented there. A user id is a
  /// uuid, so nothing else can collide.
  ///
  /// A child of the users tab rather than a tab of its own, because §10.4 owns
  /// both — "user management **and audit**" is one section — and because both
  /// questions the log answers are asked *about* somebody an administrator is
  /// already looking at. Putting it under another tab would make following a
  /// trail switch branches, and the back gesture would return to that tab
  /// instead of to the account.
  static const adminAudit = '$adminUsers/audit';

  /// §10.5's employer wallets.
  ///
  /// **A sibling of `adminUserFor` with the same ordering trap as
  /// [adminAudit]**: `:id` would match the literal `wallets` too, so this must
  /// be registered before it in `app_router.dart`.
  ///
  /// Under the users tab rather than a tab of its own, for the reason the audit
  /// log is: the shell is capped at five destinations and all five are spoken
  /// for. It is also where the question is asked from — a wallet belongs to an
  /// employer, the list *is* a list of employers, and an administrator looking
  /// at an account is one tap from its money.
  static const adminWallets = '$adminUsers/wallets';

  /// §10.5's three money settings.
  ///
  /// **The same ordering trap as [adminAudit] and [adminWallets]**: `:id` would
  /// match the literal `pricing` too, so this must be registered before it in
  /// `app_router.dart`.
  ///
  /// Beside the wallets rather than under them: the prices are the platform's,
  /// not one employer's, and `/wallets/pricing` would collide with the wallet
  /// detail route's `:userId` as well as reading as somebody's own.
  static const adminPricing = '$adminUsers/pricing';

  /// One employer's wallet and its ledger.
  static String adminWalletFor(String userId) => '$adminWallets/$userId';

  /// The log's two questions, as query parameters. Named here with every other
  /// route parameter, and read by the screen — `core/` does not import a
  /// feature's domain to learn what its own paths carry.
  static const adminAuditActorParam = 'actor';
  static const adminAuditTargetTypeParam = 'targetType';
  static const adminAuditTargetIdParam = 'targetId';

  /// "What has this administrator done" (§10.4).
  static String adminAuditByActor(String actorUserId) =>
      '$adminAudit?$adminAuditActorParam=$actorUserId';

  /// "What was done to this thing" (§10.4) — the other question.
  static String adminAuditForTarget(String targetType, String targetId) =>
      '$adminAudit?$adminAuditTargetTypeParam=$targetType'
      '&$adminAuditTargetIdParam=$targetId';

  // --- Development surfaces ------------------------------------------------

  /// Developer tools: the role switcher, the design catalogue, the health probe
  /// and the active flavor. The only way into the others.
  static const developerTools = '/_dev';

  /// Design-system catalogue. Carries unlocalized sample copy.
  static const designGallery = '/_design';

  /// Dictionary probe: the §3.3 pickers against the real API, with a language
  /// switcher beside the ids they bind. Exists because the product forms that
  /// will carry these pickers are schema-driven and arrive in M3, so until then
  /// there is nowhere else to watch one fail on a device.
  static const dictionaryProbe = '/_dictionaries';

  /// The M0 health probe. Scaffolding that proves app -> API -> Postgres; it is
  /// to be replaced by the first real feature, not built on, which is why it
  /// lives here rather than on a product route.
  static const health = '/_health';

  /// Whether [location] is a development surface, exempt from the redirect
  /// chain.
  ///
  /// Exempt deliberately: the tools have to be reachable *because* the session
  /// is in an awkward state - that is when you need them. Guarding them behind
  /// the chain they exist to debug is a locked-keys-inside problem.
  static bool isDevelopmentPath(String location) => location.startsWith('/_');

  /// First tab of [role]'s shell - where a role switch or a bounced deep link
  /// lands.
  static String homeFor(AppRole role) => switch (role) {
    AppRole.candidate => candidateHome,
    AppRole.employer => employerHome,
    AppRole.admin => adminDashboard,
  };
}
