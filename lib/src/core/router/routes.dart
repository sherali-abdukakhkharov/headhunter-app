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

  // --- Candidate shell -----------------------------------------------------

  static const candidateHome = '/candidate/home';
  static const candidateVacancies = '/candidate/vacancies';
  static const candidateApplications = '/candidate/applications';
  static const candidateMessages = '/candidate/messages';
  static const candidateProfile = '/candidate/profile';

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
