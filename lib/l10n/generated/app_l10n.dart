import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_l10n_en.dart';
import 'app_l10n_ru.dart';
import 'app_l10n_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn'),
  ];

  /// Application name. Brand term - left untranslated in every locale.
  ///
  /// In en, this message translates to:
  /// **'JobBridge'**
  String get appTitle;

  /// Action on an error state. Every error state must offer one.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// Dismisses a dialog or sheet without applying changes.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Commits a form.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Advances a multi-step flow.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// Returns to the previous step.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Closes a sheet or full-screen surface.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Placeholder for a search input.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// Opens an existing record for editing. Used on the repeating profile sections (§5.1).
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Removes a record. Always behind a confirmation, because it cannot be undone.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Ends the session at the user's request. Distinct from an expired session, which the user did not choose.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// Accessible label for a loading state. Read by screen readers where the spinner itself carries no text.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get stateLoading;

  /// Heading for an empty list, as distinct from an error.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get stateEmptyTitle;

  /// Body for an empty list.
  ///
  /// In en, this message translates to:
  /// **'There is nothing to show on this screen yet.'**
  String get stateEmptyBody;

  /// Heading for a failed request.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get stateErrorTitle;

  /// Generic error body, used when the server sent no localized message of its own.
  ///
  /// In en, this message translates to:
  /// **'The request could not be completed. Please try again.'**
  String get stateErrorBody;

  /// Heading shown when the device is offline. Distinct from a server error - the user can act on this one.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get stateOfflineTitle;

  /// Body for the offline state.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get stateOfflineBody;

  /// Heading when an OS permission was refused.
  ///
  /// In en, this message translates to:
  /// **'Permission needed'**
  String get statePermissionDeniedTitle;

  /// Body when an OS permission was refused.
  ///
  /// In en, this message translates to:
  /// **'Grant permission in Settings to continue.'**
  String get statePermissionDeniedBody;

  /// Shown when refresh fails and the user is returned to onboarding.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpired;

  /// Label for the interface-language setting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Role name. Someone looking for work.
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get roleCandidate;

  /// Role name. Someone posting vacancies - a company or an individual.
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get roleEmployer;

  /// Role name. Platform moderator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// Bottom-nav tab. Candidate and employer home. LENGTH-CRITICAL: the bar reserves two label lines at a constant 70pt and clips beyond them - keep to two lines at 320pt and 2.0x text scale, or add a soft hyphen.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom-nav tab. The vacancy feed for a candidate, the employer's own vacancies for an employer. Length-critical - see navHome.
  ///
  /// In en, this message translates to:
  /// **'Vacancies'**
  String get navVacancies;

  /// Bottom-nav tab, candidate. The candidate's own applications and their stages (§8.1). Length-critical - see navHome.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get navApplications;

  /// Bottom-nav tab. Conversations (§9.1). Length-critical - see navHome.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// Bottom-nav tab, candidate. Their own profile (§5). Length-critical - see navHome.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Bottom-nav tab, employer. Candidate search and saved candidates (§7). Length-critical - see navHome.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get navCandidates;

  /// Bottom-nav tab, employer. The employer's own profile and verification state (§6.1) - used for an individual employer too, so avoid wording that implies a legal entity.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get navCompany;

  /// Bottom-nav tab, administrator. The counters of §10.1. Length-critical - see navHome.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Bottom-nav tab, administrator. Covers both queues of §10.2 - employer verification and vacancy moderation - so it must not name only one of them. Length-critical - see navHome.
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get navQueue;

  /// Bottom-nav tab, administrator. The complaint review queue (§10.2). Length-critical - see navHome.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get navComplaints;

  /// Bottom-nav tab, administrator. User search and warn/restrict/block (§10.2, UAT-14). Length-critical - the Uzbek and Russian words are far longer than the English and carry a soft hyphen.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get navUsers;

  /// Bottom-nav tab, administrator. Dictionary management with all four localized labels (§10.3). Length-critical - see navHome.
  ///
  /// In en, this message translates to:
  /// **'Dictionaries'**
  String get navDictionaries;

  /// BR-10. Heading of the screen a blocked account is held on. The app must explain the restriction rather than fail mysteriously.
  ///
  /// In en, this message translates to:
  /// **'Account blocked'**
  String get blockedTitle;

  /// BR-10. Shown only when the administrator supplied no reason; when they did, their reason is displayed verbatim instead and is never translated client-side (§2.4).
  ///
  /// In en, this message translates to:
  /// **'An administrator has blocked this account. You cannot use the app until the block is lifted.'**
  String get blockedBody;

  /// §5.3. Heading of the completeness ring on the candidate profile.
  ///
  /// In en, this message translates to:
  /// **'Profile completeness'**
  String get profileCompleteness;

  /// How many fields still block searchability (BR-02). Counts only the blocking ones, not everything that would raise the percentage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} required field left} other{{count} required fields left}}'**
  String profileMissingRequired(int count);

  /// BR-02 satisfied: employers can find this profile. Paired with an icon - status is never colour alone.
  ///
  /// In en, this message translates to:
  /// **'Visible in search'**
  String get profileSearchable;

  /// BR-02 not yet satisfied. Deliberately not phrased as an error: an incomplete profile is a normal state, not a failure.
  ///
  /// In en, this message translates to:
  /// **'Not yet in search'**
  String get profileNotSearchable;

  /// Success toast after a profile write lands.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// A `bespoke` schema section (work history, education) owns its own sub-resource. Stated plainly rather than rendered as an empty section, which would read as finished.
  ///
  /// In en, this message translates to:
  /// **'This section has its own editor and is not part of this build yet.'**
  String get profileSectionElsewhere;

  /// A field kind the app cannot draw yet. Shown rather than hidden, because a silently missing field makes the completeness percentage inexplicable.
  ///
  /// In en, this message translates to:
  /// **'This field is not editable in this version of the app.'**
  String get profileFieldNotEditableYet;

  /// A cascading picker whose parent is unset - a district before a region. The schema names the parent, so this wording stays generic.
  ///
  /// In en, this message translates to:
  /// **'Choose the field above first'**
  String get profileChooseParentFirst;

  /// Placeholder in a date field. The stored value is always ISO; this is not a localized display format.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get profileDateHint;

  /// Lower bound of a money_range field (§4.3).
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get profileSalaryFrom;

  /// Upper bound of a money_range field (§4.3).
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get profileSalaryTo;

  /// money_range fields that allow it: the candidate would rather discuss than state a figure.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get profileSalaryNegotiable;

  /// §5.3's last meaningful update. The date is ISO because §8.3's display policy is still open and the value is data, not prose.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String profileLastUpdated(String date);

  /// Accessibility label on a missing-field chip that scrolls to the field it names.
  ///
  /// In en, this message translates to:
  /// **'Fill in'**
  String get profileFixField;

  /// Heading of the search-visibility control (UAT-12, §5.5). Its own section because it is not a schema field.
  ///
  /// In en, this message translates to:
  /// **'Who can find you'**
  String get profileVisibilityTitle;

  /// visibility=searchable. Note this is the setting, not the effect - BR-02 still requires a complete profile.
  ///
  /// In en, this message translates to:
  /// **'Visible in search'**
  String get profileVisibilitySearchable;

  /// Explains the searchable option.
  ///
  /// In en, this message translates to:
  /// **'Employers can find you in candidate search.'**
  String get profileVisibilitySearchableHint;

  /// visibility=hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden from search'**
  String get profileVisibilityHidden;

  /// Explains that hiding does not disable the account - the distinction UAT-12 turns on.
  ///
  /// In en, this message translates to:
  /// **'You can still browse vacancies and apply. Employers cannot find you.'**
  String get profileVisibilityHiddenHint;

  /// visibility=visible_after_apply.
  ///
  /// In en, this message translates to:
  /// **'Visible after I apply'**
  String get profileVisibilityAfterApply;

  /// Explains the visible_after_apply option.
  ///
  /// In en, this message translates to:
  /// **'Only employers whose vacancy you applied to can see your profile.'**
  String get profileVisibilityAfterApplyHint;

  /// Candidate home tab: vacancies matched to the profile (§5.6). Ranking is server-side.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get feedRecommended;

  /// Candidate home tab: newest vacancies.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get feedRecent;

  /// Candidate home tab: vacancies the candidate bookmarked.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get feedSaved;

  /// Empty state of a candidate feed.
  ///
  /// In en, this message translates to:
  /// **'No vacancies to show yet'**
  String get feedEmpty;

  /// §5.6 shows verification on the vacancy itself, so a candidate can weigh it without opening the employer.
  ///
  /// In en, this message translates to:
  /// **'Verified employer'**
  String get vacancyVerifiedEmployer;

  /// Salary is open to discussion. A negotiable vacancy also passes a minimum-pay filter, because it has not said no to the figure.
  ///
  /// In en, this message translates to:
  /// **'Pay negotiable'**
  String get vacancyNegotiablePay;

  /// The application deadline. ISO, because §8.3's display policy is still open.
  ///
  /// In en, this message translates to:
  /// **'Apply by {date}'**
  String vacancyDeadline(String date);

  /// Submits an application (§5.6). Carries a persisted idempotency key, because BR-07 allows one active application per vacancy.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get vacancyApply;

  /// Shown instead of Apply once the candidate has an application on this vacancy (BR-07).
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get vacancyApplied;

  /// UAT-15: the vacancy is closed, paused, or past its deadline. BR-06 is computed server-side and rendered as given.
  ///
  /// In en, this message translates to:
  /// **'Not accepting applications'**
  String get vacancyClosedToApplications;

  /// Bookmarks a vacancy.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get vacancySave;

  /// The vacancy is bookmarked; tapping removes it.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get vacancySaved;

  /// Reports a vacancy for review (§10.2).
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get vacancyReport;

  /// Title of the report sheet.
  ///
  /// In en, this message translates to:
  /// **'Report this vacancy'**
  String get vacancyReportTitle;

  /// Free text: a candidate reporting a fake vacancy should not have to find their objection on a list.
  ///
  /// In en, this message translates to:
  /// **'What is wrong with it?'**
  String get vacancyReportHint;

  /// Confirmation after reporting.
  ///
  /// In en, this message translates to:
  /// **'Thank you. A moderator will review it.'**
  String get vacancyReported;

  /// Heading of the candidate application list (§8.1).
  ///
  /// In en, this message translates to:
  /// **'Your applications'**
  String get applicationsMine;

  /// Empty state of the application list.
  ///
  /// In en, this message translates to:
  /// **'You have not applied to anything yet'**
  String get applicationsEmpty;

  /// §8.1's candidate-only transition. Offered only while the application is live.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get applicationWithdraw;

  /// Confirmation before withdrawing.
  ///
  /// In en, this message translates to:
  /// **'Withdraw this application?'**
  String get applicationWithdrawTitle;

  /// application stage=submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get stageSubmitted;

  /// application stage=viewed.
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get stageViewed;

  /// application stage=shortlisted.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get stageShortlisted;

  /// application stage=interview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get stageInterview;

  /// application stage=offer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get stageOffer;

  /// application stage=hired.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get stageHired;

  /// application stage=rejected. Worded plainly rather than harshly - it is read by the person it happened to.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get stageRejected;

  /// application stage=withdrawn, by the candidate.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get stageWithdrawn;

  /// Heading of the employer's own vacancy list (§6.2). Includes closed ones - BR-11 keeps them in history.
  ///
  /// In en, this message translates to:
  /// **'Your vacancies'**
  String get vacancyMine;

  /// Creates an empty draft. BR-03 is checked here, so an employer who cannot publish is told before filling in a form.
  ///
  /// In en, this message translates to:
  /// **'New vacancy'**
  String get vacancyNew;

  /// Empty state of the employer vacancy list.
  ///
  /// In en, this message translates to:
  /// **'No vacancies yet'**
  String get vacancyNone;

  /// Stands in for a draft whose title has not been filled in yet.
  ///
  /// In en, this message translates to:
  /// **'Untitled vacancy'**
  String get vacancyUntitled;

  /// vacancy status=draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get vacancyStatusDraft;

  /// vacancy status=under_moderation.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get vacancyStatusModeration;

  /// vacancy status=active.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get vacancyStatusActive;

  /// vacancy status=paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get vacancyStatusPaused;

  /// vacancy status=closed. Terminal (BR-11).
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get vacancyStatusClosed;

  /// vacancy status=rejected. Editing returns it to draft, which is §6.4's correction path.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get vacancyStatusRejected;

  /// Sends a draft to moderation (§6.4).
  ///
  /// In en, this message translates to:
  /// **'Submit for publication'**
  String get vacancySubmit;

  /// Employer transition: active -> paused.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get vacancyPause;

  /// Employer transition: paused -> active.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get vacancyResume;

  /// Employer transition to closed.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get vacancyClose;

  /// Confirmation before closing.
  ///
  /// In en, this message translates to:
  /// **'Close this vacancy?'**
  String get vacancyCloseTitle;

  /// BR-11 stated before the fact, because closing cannot be undone.
  ///
  /// In en, this message translates to:
  /// **'Closing is permanent. The vacancy leaves search and stays in your history.'**
  String get vacancyCloseMessage;

  /// Turns the server's missingForSubmit into a checklist shown before the refusal rather than after.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} field to fill before publishing} other{{count} fields to fill before publishing}}'**
  String vacancyMissingForSubmit(int count);

  /// Shown while a vacancy is under moderation or closed - the server refuses the write, so the form is read-only rather than accepting keystrokes it cannot save.
  ///
  /// In en, this message translates to:
  /// **'This vacancy cannot be edited right now.'**
  String get vacancyNotEditable;

  /// BR-06 satisfied: active, and no deadline or one that has not passed.
  ///
  /// In en, this message translates to:
  /// **'Accepting applications'**
  String get vacancyOpenForApplications;

  /// Title of the BR-12 notice on the vacancy form.
  ///
  /// In en, this message translates to:
  /// **'Age and gender restrictions'**
  String get vacancyRestrictionTitle;

  /// BR-12, stated on the form rather than discovered at submit.
  ///
  /// In en, this message translates to:
  /// **'Age and gender restrictions need a justification and are always reviewed by a moderator.'**
  String get vacancyRestrictionWarning;

  /// Asked before the form exists. §6.1's type decides which fields apply, so there is no neutral employer profile to render first.
  ///
  /// In en, this message translates to:
  /// **'What kind of employer are you?'**
  String get employerChooseType;

  /// employer type=company.
  ///
  /// In en, this message translates to:
  /// **'A company'**
  String get employerTypeCompany;

  /// Explains the company option.
  ///
  /// In en, this message translates to:
  /// **'Registered business hiring under a company name.'**
  String get employerTypeCompanyHint;

  /// employer type=individual — §6.1's private person hiring for their own work.
  ///
  /// In en, this message translates to:
  /// **'An individual'**
  String get employerTypeIndividual;

  /// Explains the individual option.
  ///
  /// In en, this message translates to:
  /// **'Hiring for your own household or private work.'**
  String get employerTypeIndividualHint;

  /// Warning shown while the type is still choosable. The server refuses a later change, because it would strand the other type's answers and the evidence verification was granted against.
  ///
  /// In en, this message translates to:
  /// **'Chosen once and cannot be changed later.'**
  String get employerTypeFixed;

  /// Heading of the employer form (§6.1).
  ///
  /// In en, this message translates to:
  /// **'Employer details'**
  String get employerDetails;

  /// Companies: the name on the registration.
  ///
  /// In en, this message translates to:
  /// **'Registered name'**
  String get employerLegalName;

  /// Companies: the name on a vacancy card, which often differs from the registered one.
  ///
  /// In en, this message translates to:
  /// **'Name shown to candidates'**
  String get employerPublicName;

  /// Individual employers.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get employerFullName;

  /// Companies: binds an industry dictionary id.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get employerIndustry;

  /// Companies: §6.1's named contact.
  ///
  /// In en, this message translates to:
  /// **'Contact person'**
  String get employerContactPerson;

  /// The number a candidate should call. Deliberately separate from the sign-in number, which BR-01 verified and which must not be overwritten by a business detail.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get employerContactPhone;

  /// Employer location, top level of the region hierarchy (§5.1). Its own key rather than the candidate form's, which comes from the schema.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get employerRegion;

  /// Employer location, the child of the chosen region.
  ///
  /// In en, this message translates to:
  /// **'District or city'**
  String get employerDistrict;

  /// Free text address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get employerAddress;

  /// A company description, or for an individual employer §6.1's short description of the work being offered.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get employerDescription;

  /// Heading of the verification card (§6.1).
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get employerVerification;

  /// verification status=not_submitted.
  ///
  /// In en, this message translates to:
  /// **'Not submitted'**
  String get employerVerificationNotSubmitted;

  /// verification status=under_review.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get employerVerificationUnderReview;

  /// verification status=verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get employerVerificationVerified;

  /// verification status=rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get employerVerificationRejected;

  /// verification status=changes_required — §6.1's correction path, distinct from a rejection because the employer can act on it.
  ///
  /// In en, this message translates to:
  /// **'Changes required'**
  String get employerVerificationChangesRequired;

  /// Sends the collected evidence for review.
  ///
  /// In en, this message translates to:
  /// **'Submit for verification'**
  String get employerSubmitVerification;

  /// Heading of the required-evidence list. The list is served rather than hardcoded, because §6.1 leaves the policy open.
  ///
  /// In en, this message translates to:
  /// **'Documents to provide'**
  String get employerEvidence;

  /// Marks a document a submission is refused without.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get employerEvidenceRequired;

  /// Marks a document that may be supplied but is not demanded.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get employerEvidenceOptional;

  /// BR-03 stated plainly. Both conditions, because the rule is the conjunction and an employer who meets only one needs to know which is missing.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile and get verified before posting a vacancy or inviting a candidate.'**
  String get employerCannotPublish;

  /// BR-03 satisfied.
  ///
  /// In en, this message translates to:
  /// **'You can post vacancies and invite candidates.'**
  String get employerCanPublish;

  /// Shown when the form has unsaved changes: the server verifies what it has stored, not what is on screen.
  ///
  /// In en, this message translates to:
  /// **'Save your details before submitting for verification.'**
  String get employerSaveFirst;

  /// Heading of the file section (§5.4). Covers the CV, photo, certificates and supporting documents, because the slots come from the schema rather than being listed here.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get attachmentsTitle;

  /// Adds a file to a slot that has room.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get attachmentUpload;

  /// Shown instead of Upload on a full single-file slot. §5.4's replace: the new file supersedes the old one, which the server does by retiring the oldest.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get attachmentReplace;

  /// UAT-03 asks for progress. A percentage rather than a spinner, because a large CV on a slow connection is exactly where an indeterminate spinner reads as a hang.
  ///
  /// In en, this message translates to:
  /// **'Uploading… {percent}%'**
  String attachmentUploading(String percent);

  /// Empty state of one file slot.
  ///
  /// In en, this message translates to:
  /// **'Nothing uploaded yet'**
  String get attachmentNone;

  /// Refused before sending. The server enforces the limit too, but bouncing it here saves uploading a file that cannot land.
  ///
  /// In en, this message translates to:
  /// **'That file is larger than {limit} MB.'**
  String attachmentTooLarge(String limit);

  /// Refused before sending. The accepted extensions come from the schema's accept list, so they are never hardcoded.
  ///
  /// In en, this message translates to:
  /// **'Choose a {types} file.'**
  String attachmentWrongType(String types);

  /// Confirmation before deleting an uploaded file.
  ///
  /// In en, this message translates to:
  /// **'Delete this file?'**
  String get attachmentDeleteTitle;

  /// Confirmation before deleting a work-experience or education record (§5.1).
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get historyDeleteTitle;

  /// Body of the delete confirmation. States the consequence rather than asking again.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from your profile.'**
  String get historyDeleteMessage;

  /// Empty state of the work-experience section. Not an error - a first-time candidate has none.
  ///
  /// In en, this message translates to:
  /// **'No work experience yet'**
  String get experienceEmpty;

  /// Opens the editor for a new work-experience record.
  ///
  /// In en, this message translates to:
  /// **'Add experience'**
  String get experienceAdd;

  /// Optional: §5.1 asks for simplified entry for informal or seasonal work, where there is often no employer to name.
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get experienceEmployer;

  /// What the person did. The one field a work-experience record cannot omit.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get experienceRole;

  /// Binds an occupation dictionary id, so §7.1's 'years in the selected occupation' is computed rather than guessed from the title text.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get experienceOccupation;

  /// Required. The other half of what makes a record countable.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get experienceStarted;

  /// Disabled while 'I work here now' is on - the server treats the two as mutually exclusive.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get experienceEnded;

  /// Marks the role as ongoing. Mutually exclusive with an end date.
  ///
  /// In en, this message translates to:
  /// **'I work here now'**
  String get experienceCurrent;

  /// Free text describing the role. Never translated (§2.4).
  ///
  /// In en, this message translates to:
  /// **'Responsibilities'**
  String get experienceResponsibilities;

  /// Stands in for the end date on an ongoing role, in the date range shown on a record.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get experiencePresent;

  /// Empty state of the education section. Optional for the categories where §5.1 says it is not relevant.
  ///
  /// In en, this message translates to:
  /// **'No education yet'**
  String get educationEmpty;

  /// Opens the editor for a new education record.
  ///
  /// In en, this message translates to:
  /// **'Add education'**
  String get educationAdd;

  /// Binds an education_level dictionary id. The one required field of an education record.
  ///
  /// In en, this message translates to:
  /// **'Level of education'**
  String get educationLevel;

  /// Free text: the school or university. Never translated (§2.4).
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get educationInstitution;

  /// Free text: what was studied.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get educationSpecialization;

  /// A year, not a date. An expected graduation in the future is accepted.
  ///
  /// In en, this message translates to:
  /// **'Graduation year'**
  String get educationYear;

  /// Opens the proficiency picker on a dictionary_leveled row - a skill level or a CEFR grade (§4.4). Short because it sits inline on the row beside the value it changes.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get leveledChangeLevel;

  /// Placeholder in a dictionary-backed field before anything is selected (§3.3).
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get pickerChoose;

  /// Opens the list on a multi-select picker — skills, languages, employment types.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get pickerAdd;

  /// Hint in a picker's search box. Search matches the displayed label, which is the one place matching on a label is correct - it is what the user is reading.
  ///
  /// In en, this message translates to:
  /// **'Start typing to filter'**
  String get pickerSearchHint;

  /// Shown inside a picker when the search filters everything out. Distinct from the dictionary being empty, which would be a server problem.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches that search.'**
  String get pickerNoMatches;

  /// Stands in for the chip row of a multi-select picker while it is empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected yet'**
  String get pickerNothingSelected;

  /// A stored dictionary id the server could not resolve even through the resolve-by-id endpoint. Rare: retired and merged items still resolve forever (§10.3). Shown instead of a raw UUID.
  ///
  /// In en, this message translates to:
  /// **'Unavailable value'**
  String get pickerUnknownValue;

  /// Heading of the sign-in screen (§4.1).
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTitle;

  /// Persistent label above the phone field (§4.1 step 3). The +998 country code is a static prefix inside the field, so this labels the national part only.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhoneLabel;

  /// Placeholder showing the nine-digit shape of an Uzbek subscriber number. Digits only - do not translate, and do not localize the grouping.
  ///
  /// In en, this message translates to:
  /// **'90 123 45 67'**
  String get authPhoneHint;

  /// Client-side check before the send call: the national part is not nine digits. Checked here only to save the user a round trip; the server validates independently.
  ///
  /// In en, this message translates to:
  /// **'Enter a 9-digit number, for example 90 123 45 67.'**
  String get authPhoneInvalid;

  /// Primary action on the phone screen (§4.1). Deliberately not 'Sign in' or 'Register' - phone-only identity makes those the same act, and the user does not yet know which one this is.
  ///
  /// In en, this message translates to:
  /// **'Get a code'**
  String get authSendCode;

  /// Heading of the code screen, the second step of sign-in (§4.1).
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get authCodeTitle;

  /// Confirms which number the code went to, so a mistyped digit is caught here rather than after the code fails to arrive.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone}.'**
  String authCodeSentTo(String phone);

  /// Persistent label above the one-time code field.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get authCodeLabel;

  /// Client-side check before the verify call: the field does not hold a complete code. Length is a placeholder because OTP_LENGTH is server configuration (§4.2) - never hardcode six.
  ///
  /// In en, this message translates to:
  /// **'Enter the {length}-digit code.'**
  String authCodeInvalid(int length);

  /// Primary action on the code screen.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get authVerifyCode;

  /// Returns to the phone field. Present because the number is shown above it and a user who spots a typo needs somewhere to go that is not the back gesture.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get authChangePhone;

  /// Requests a fresh code. Enabled only once the server's resend delay has passed (§4.2).
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get authResendCode;

  /// The resend action while the delay is still running. Shows the remaining seconds so the user knows the button is waiting rather than broken.
  ///
  /// In en, this message translates to:
  /// **'Send again in {seconds} s'**
  String authResendIn(int seconds);

  /// Confirmation after a successful resend. Needed because the visible result of a resend is otherwise only the countdown restarting.
  ///
  /// In en, this message translates to:
  /// **'A new code is on its way.'**
  String get authCodeResent;

  /// DEPRECATED 2026-08-05, kept with the Telegram sign-in code it labels; nothing renders it. 'Telegram' is a product name and stays untranslated in every locale, including the Cyrillic ones.
  ///
  /// In en, this message translates to:
  /// **'Log in with Telegram'**
  String get authTelegramSignIn;

  /// §4.1 step 2. Consent must be given before sign-in, and it is not optional - the button stays disabled until this is checked.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Service and the Privacy Policy'**
  String get authTermsAgree;

  /// DEPRECATED with the Telegram flow. Telegram or its SDK failed for a reason the user cannot act on beyond retrying.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Telegram. Please try again.'**
  String get authSignInFailed;

  /// DEPRECATED with the Telegram flow. Network failure while contacting Telegram, as distinct from our own server being unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to Telegram. Check your internet and try again.'**
  String get authSignInNoConnection;

  /// DEPRECATED with the Telegram flow. This build's application id has no redirect URI registered with BotFather, so a login cannot start.
  ///
  /// In en, this message translates to:
  /// **'Telegram sign-in is not available in this build.'**
  String get authSignInUnavailable;

  /// Heading of the employer view of one vacancy’s applications (§6.5).
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get vacancyApplicants;

  /// Empty state.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get vacancyApplicantsEmpty;

  /// §6.5: hires counted against BR-05’s required worker count.
  ///
  /// In en, this message translates to:
  /// **'{hired} of {required} hired'**
  String applicationsHired(int hired, int required);

  /// Used when the vacancy states no worker count.
  ///
  /// In en, this message translates to:
  /// **'{hired} hired'**
  String applicationsHiredNoTarget(int hired);

  /// Opens the stage picker. §8.1 allows forward moves only, skipping permitted.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get applicationMoveTo;

  /// §8.1’s optional standard message on a rejection. Recorded in the BR-08 history whatever the stage.
  ///
  /// In en, this message translates to:
  /// **'Reason (shown to the candidate)'**
  String get applicationRejectReason;

  /// BR-09: null is a normal answer, not an error, so the absence is stated rather than left blank.
  ///
  /// In en, this message translates to:
  /// **'Phone not available'**
  String get candidatePhoneHidden;

  /// Explains that the server decided, not the app.
  ///
  /// In en, this message translates to:
  /// **'The candidate’s privacy settings decide when an employer can see it.'**
  String get candidatePhoneHiddenWhy;

  /// BR-09, §5.4: the server sends no files when the employer may not download them.
  ///
  /// In en, this message translates to:
  /// **'Files not available'**
  String get candidateFilesHidden;

  /// How complete the candidate’s profile is.
  ///
  /// In en, this message translates to:
  /// **'Profile {percent}% complete'**
  String candidateCompleteness(int percent);

  /// §8.2: the employer’s private notes on an application.
  ///
  /// In en, this message translates to:
  /// **'Private notes'**
  String get notesTitle;

  /// States that the candidate cannot see them.
  ///
  /// In en, this message translates to:
  /// **'Only you can see these'**
  String get notesHint;

  /// Adds a note.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get notesAdd;

  /// Heading of employer candidate search (§7.1).
  ///
  /// In en, this message translates to:
  /// **'Find candidates'**
  String get searchCandidates;

  /// Runs the search after the count has been seen.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchRun;

  /// §7.2: how many candidates match, shown before the results.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} candidate} other{{count} candidates}}'**
  String searchCountExact(int count);

  /// §7.2: the server capped the count, so it is rendered as "200+". The cap comes from isExact, never from comparing the number.
  ///
  /// In en, this message translates to:
  /// **'{count}+ candidates'**
  String searchCountCapped(int count);

  /// Empty result set - not an error.
  ///
  /// In en, this message translates to:
  /// **'No candidates match these filters'**
  String get searchNoResults;

  /// §7.3: candidates this employer bookmarked.
  ///
  /// In en, this message translates to:
  /// **'Saved candidates'**
  String get searchSaved;

  /// §7.3’s weighted requirement match.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String searchMatch(int percent);

  /// Total years summed from the experience rows.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, one{{years} year of experience} other{{years} years of experience}}'**
  String searchExperienceYears(int years);

  /// §7.3: puts this candidate on the shortlist of the vacancy the card was produced for. Offered only where there is such a vacancy — a shortlist is per-vacancy, so elsewhere there is nothing to add to.
  ///
  /// In en, this message translates to:
  /// **'Add to shortlist'**
  String get searchShortlist;

  /// The candidate is on this vacancy's shortlist; tapping removes them. Same wording as the application stage of the same name (stageShortlisted), which is the same idea reached a different way.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get searchShortlisted;

  /// Title of §7.1’s filter builder.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// Closes the filter builder and re-counts (§7.2).
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get filtersApply;

  /// Clears every filter inside the builder.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filtersReset;

  /// Opens the filter builder from the results screen.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersEdit;

  /// Removes every applied-filter chip at once.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get filtersClearAll;

  /// Shown in place of the chips when nothing is filtered. Names BR-02’s gate rather than saying "all candidates", which would be untrue.
  ///
  /// In en, this message translates to:
  /// **'No filters — every searchable candidate'**
  String get filtersNone;

  /// BR-12: heading of the notice blocking Apply while a restriction is unjustified.
  ///
  /// In en, this message translates to:
  /// **'Cannot search yet'**
  String get filtersBlockedTitle;

  /// Filter-builder section heading (§7.1).
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get filtersOccupation;

  /// Filter-builder section heading (§7.1).
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get filtersSkills;

  /// Filter-builder section heading (§7.1).
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get filtersExperience;

  /// Filter-builder section heading (§7.1).
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get filtersLanguages;

  /// Filter-builder section heading (§7.1).
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get filtersEducation;

  /// Filter-builder section heading (§7.1).
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filtersLocation;

  /// Filter-builder section heading (§7.1).
  ///
  /// In en, this message translates to:
  /// **'Work preferences'**
  String get filtersPreferences;

  /// Filter-builder section heading (§7.1).
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get filtersAvailability;

  /// Filter-builder section heading — §6.3’s attribute dictionary.
  ///
  /// In en, this message translates to:
  /// **'Additional requirements'**
  String get filtersAttributes;

  /// Filter-builder section heading: completeness and recency (§7.1).
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get filtersProfile;

  /// Filter-builder section heading for BR-12’s conditional filters.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get filtersRestrictions;

  /// Filter-builder section heading for §7.3’s ordering.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filtersSort;

  /// Multi-select of occupation dictionary ids.
  ///
  /// In en, this message translates to:
  /// **'Occupations'**
  String get filterOccupations;

  /// Restricts the occupation match to the candidate’s main one.
  ///
  /// In en, this message translates to:
  /// **'Primary occupation only'**
  String get filterPrimaryOnly;

  /// Explains what the switch changes.
  ///
  /// In en, this message translates to:
  /// **'Match the candidate’s main occupation, not every one they listed'**
  String get filterPrimaryOnlyHint;

  /// §7.1’s "professional level where applicable".
  ///
  /// In en, this message translates to:
  /// **'Professional level'**
  String get filterOccupationLevels;

  /// §7.1: the occupation of the candidate’s current job.
  ///
  /// In en, this message translates to:
  /// **'Current or last role'**
  String get filterCurrentOccupations;

  /// Multi-select of skill dictionary ids.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get filterSkills;

  /// Label of §7.1’s match-all / match-any control.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get filterMatchMode;

  /// Any one of the chosen items is enough. The default: a vacancy naming eight skills would otherwise match nobody.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filterMatchAny;

  /// Every chosen item is required.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterMatchAll;

  /// §7.4’s floor on an ordered scale — "B2 or better".
  ///
  /// In en, this message translates to:
  /// **'Minimum level'**
  String get filterMinLevel;

  /// No floor. Also what a scale that failed to load falls back to.
  ///
  /// In en, this message translates to:
  /// **'Any level'**
  String get filterLevelAny;

  /// Total years summed from the candidate’s experience rows.
  ///
  /// In en, this message translates to:
  /// **'Total years, minimum'**
  String get filterExperienceYearsMin;

  /// Years within the chosen occupations, which it therefore requires.
  ///
  /// In en, this message translates to:
  /// **'Years in this occupation, minimum'**
  String get filterOccupationExperience;

  /// The server’s search.occupation_required, said before the request instead of after it.
  ///
  /// In en, this message translates to:
  /// **'Choose an occupation first'**
  String get filterOccupationExperienceNeedsOccupation;

  /// Multi-select of language dictionary ids; each chosen language then gets its own floor.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get filterLanguages;

  /// §7.1’s "certificate availability", per language.
  ///
  /// In en, this message translates to:
  /// **'Certificate required'**
  String get filterLanguageCertificate;

  /// A set of acceptable levels rather than a floor — the education row stores no rank.
  ///
  /// In en, this message translates to:
  /// **'Education level'**
  String get filterEducationLevels;

  /// §7.1’s "specialization where relevant", as dictionary ids (BR-13).
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get filterSpecializations;

  /// Top level of the region dictionary — the districts are its children.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get filterRegion;

  /// Children of the chosen region.
  ///
  /// In en, this message translates to:
  /// **'Districts'**
  String get filterDistricts;

  /// Cascading picker with no parent chosen. Without it the list would show every district in the country.
  ///
  /// In en, this message translates to:
  /// **'Choose a region first'**
  String get filterDistrictsNeedRegion;

  /// §7.1. Remote-work readiness is not here — it is a work_format id.
  ///
  /// In en, this message translates to:
  /// **'Willing to relocate'**
  String get filterWillingToRelocate;

  /// §7.1’s travel readiness.
  ///
  /// In en, this message translates to:
  /// **'Ready to travel'**
  String get filterWillingToTravel;

  /// Where to be near, for the proximity sort. Separate from the district filter, which would exclude everyone else and leave the sort nothing to order.
  ///
  /// In en, this message translates to:
  /// **'Near this district'**
  String get filterProximityDistrict;

  /// Hint on the proximity picker.
  ///
  /// In en, this message translates to:
  /// **'Used by the “Nearest” sort'**
  String get filterProximityHint;

  /// employment_type dictionary ids.
  ///
  /// In en, this message translates to:
  /// **'Employment type'**
  String get filterEmploymentTypes;

  /// work_format dictionary ids — this is where remote lives.
  ///
  /// In en, this message translates to:
  /// **'Work format'**
  String get filterWorkFormats;

  /// shift dictionary ids.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get filterShifts;

  /// The floor of the employer’s range.
  ///
  /// In en, this message translates to:
  /// **'Salary from'**
  String get filterSalaryMin;

  /// The employer’s ceiling.
  ///
  /// In en, this message translates to:
  /// **'Salary up to'**
  String get filterSalaryMax;

  /// Says what the ceiling does, including the negotiable case, which is the half people get wrong.
  ///
  /// In en, this message translates to:
  /// **'A candidate expecting more is excluded. A negotiable expectation still matches.'**
  String get filterSalaryMaxHint;

  /// A date the candidate can start by.
  ///
  /// In en, this message translates to:
  /// **'Available by'**
  String get filterAvailableBy;

  /// §7.1’s "immediately", tested against today in Asia/Tashkent.
  ///
  /// In en, this message translates to:
  /// **'Available immediately'**
  String get filterAvailableImmediately;

  /// §6.3’s attribute dictionary, which is one type covering all of these.
  ///
  /// In en, this message translates to:
  /// **'Licences, transport and tools'**
  String get filterAttributes;

  /// Candidates who can bring a crew — a physical-work filter (§2.1).
  ///
  /// In en, this message translates to:
  /// **'Can bring a crew of at least'**
  String get filterCrewSizeMin;

  /// Percentage floor on profile completeness.
  ///
  /// In en, this message translates to:
  /// **'Profile completeness, minimum (%)'**
  String get filterMinCompleteness;

  /// §7.1’s "recently updated", against last_meaningful_update_at.
  ///
  /// In en, this message translates to:
  /// **'Updated since'**
  String get filterUpdatedSince;

  /// BR-12. Permitted only with a justification.
  ///
  /// In en, this message translates to:
  /// **'Age from'**
  String get filterAgeMin;

  /// BR-12. See filterAgeMin.
  ///
  /// In en, this message translates to:
  /// **'Age to'**
  String get filterAgeMax;

  /// BR-12. Permitted only with a justification.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get filterGender;

  /// BR-12: a restriction_justification dictionary id, required as soon as an age or gender filter is used.
  ///
  /// In en, this message translates to:
  /// **'Reason for the restriction'**
  String get filterJustification;

  /// BR-12, blocking Apply. Says the logging part too: it is a fact about the feature, not a threat.
  ///
  /// In en, this message translates to:
  /// **'An age or gender filter needs a declared reason. Every use is logged.'**
  String get filterRestrictionRequired;

  /// Sits above the BR-12 section, before anything is filled in.
  ///
  /// In en, this message translates to:
  /// **'Only where the job genuinely requires it.'**
  String get filterRestrictionExplain;

  /// §7.3 sort: the weighted share of the filters each candidate satisfies.
  ///
  /// In en, this message translates to:
  /// **'Best match'**
  String get sortMatch;

  /// §7.3 sort.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get sortRecent;

  /// §7.3 sort.
  ///
  /// In en, this message translates to:
  /// **'Most experience'**
  String get sortExperience;

  /// §7.3 sort.
  ///
  /// In en, this message translates to:
  /// **'Lowest expectation'**
  String get sortSalary;

  /// §7.3 sort: tiered — same district, then same region, then the rest. With no location filter it falls through to recency.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get sortProximity;

  /// Fetches the next page of a paged list.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get commonLoadMore;

  /// An applied-filter chip for a group holding more than one value. The group is named, not its values: turning eight dictionary ids into words is eight asynchronous resolutions in a wrapping row.
  ///
  /// In en, this message translates to:
  /// **'{label} ({count})'**
  String filterChipCount(String label, int count);

  /// An applied-filter chip for a filter whose value needs no dictionary — a number, a date, a percentage. Those carry their value, because hiding a number the user can already read helps nobody.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String filterChipValue(String label, String value);

  /// UAT-06: opens candidate search with this vacancy’s mandatory requirements prefilled as filters.
  ///
  /// In en, this message translates to:
  /// **'Find candidates'**
  String get searchFromVacancy;

  /// Shown on the search screen when the config was prefilled from a vacancy (UAT-06). The prefill is a starting point, so the employer has to be able to see that it happened.
  ///
  /// In en, this message translates to:
  /// **'Filters came from a vacancy'**
  String get searchScopedToVacancy;

  /// §7.3 “View profile”. Every open is a logged read of protected data (§11.1).
  ///
  /// In en, this message translates to:
  /// **'Candidate'**
  String get candidateProfileTitle;

  /// Opens the candidate detail screen from a result card — the only place on the search screen where BR-09 can open at all.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get candidateViewProfile;

  /// Heading of the block holding the phone number, shown only when BR-09 allowed it.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get candidateContact;

  /// When the candidate can start. The date is ISO on the wire; §8.3’s display policy is still open.
  ///
  /// In en, this message translates to:
  /// **'Available from {date}'**
  String candidateAvailableFrom(String date);

  /// §5.4: the CV and any other files. The CV is an attachment, never a parsed source of profile data.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get candidateAttachments;

  /// Files are permitted but there are none — different from being withheld, and it has to read differently.
  ///
  /// In en, this message translates to:
  /// **'This candidate has not uploaded anything'**
  String get candidateNoFiles;

  /// BR-09 allowed contact but there is nothing to show. Says so plainly rather than implying something was withheld.
  ///
  /// In en, this message translates to:
  /// **'This candidate has no phone number on file.'**
  String get candidatePhoneNotOnFile;

  /// BR-09 reason not_verified_employer (§7, BR-03). Names the one thing the employer can act on.
  ///
  /// In en, this message translates to:
  /// **'Contact details open once your company is verified.'**
  String get candidateExposureNotVerified;

  /// BR-09 reason no_interaction. The common case, and the one that reads as a bug when unexplained.
  ///
  /// In en, this message translates to:
  /// **'Contact details open once this candidate applies to one of your vacancies, or accepts an invitation.'**
  String get candidateExposureNoInteraction;

  /// BR-09 reason hidden_by_candidate (§5.3). The second sentence matters: hidden means hidden from search, not unreachable.
  ///
  /// In en, this message translates to:
  /// **'This candidate has hidden their profile from search. They can still see your vacancies and apply.'**
  String get candidateExposureHidden;

  /// Empty saved list. Deliberately not “you have saved nobody” — a saved candidate who hides their profile leaves this list without having been un-saved (BR-02).
  ///
  /// In en, this message translates to:
  /// **'No saved candidates'**
  String get searchSavedEmpty;

  /// Copies a value to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// Confirms the copy.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get commonCopied;

  /// Title of §5.6’s vacancy detail screen.
  ///
  /// In en, this message translates to:
  /// **'Vacancy'**
  String get vacancyDetailTitle;

  /// Heading above the employer’s free text. Never translated (§2.4) — shown exactly as entered.
  ///
  /// In en, this message translates to:
  /// **'About the job'**
  String get vacancyDescription;

  /// §6.3’s structured requirements, grouped by schema field.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get vacancyRequirements;

  /// §6.3’s mandatory flag. Badged rather than ordered: a preference that looked like a requirement would stop people applying.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get vacancyMandatory;

  /// §6.3’s preferred flag — rewarded by the match score, never used to exclude.
  ///
  /// In en, this message translates to:
  /// **'Preferred'**
  String get vacancyPreferred;

  /// UAT-15: the vacancy closed, expired or was moderated away between the feed being drawn and this screen opening. A normal outcome, not a failure — so it must not read as one.
  ///
  /// In en, this message translates to:
  /// **'This vacancy is no longer available'**
  String get vacancyGoneTitle;

  /// Names the three reasons without claiming which: the server answers vacancy.not_found for all of them, deliberately, so telling the candidate which would be a guess.
  ///
  /// In en, this message translates to:
  /// **'It may have been filled, closed, or its deadline may have passed.'**
  String get vacancyGoneBody;

  /// Free text, matching the endpoint — a candidate reporting a fake vacancy should not have to find their objection on somebody else’s menu.
  ///
  /// In en, this message translates to:
  /// **'What is wrong with this vacancy?'**
  String get vacancyReportReason;

  /// Submits the complaint.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get vacancyReportSend;

  /// Boolean true.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// Boolean false.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// BR-05’s required worker count, which is always at least one.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} opening} other{{count} openings}}'**
  String vacancyOpenings(int count);

  /// The work window for a seasonal or fixed-date assignment (§6.3, UAT-10). ISO dates on the wire; §8.3’s display policy is still open.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String vacancyWorkWindow(String start, String end);

  /// A start date with no stated end.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String vacancyStartsOn(String date);

  /// §6.6's employer Coin wallet. Employer-only: a multi-role account switched to candidate has no wallet to read.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// Label above the Coin balance on the wallet screen.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get walletBalanceLabel;

  /// A Coin quantity. Coins are an internal service unit (§6.6) - not money, not transferable, not withdrawable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} Coin} other{{count} Coins}}'**
  String walletCoins(int count);

  /// §6.2's approximate UZS purchase value. Approximate because it is the balance at today's price and repricing must not restate history - the figure comes from the server, never from multiplying Coins here.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount} UZS'**
  String walletApproxUzs(int amount);

  /// An exact UZS figure: a price, or the value a transaction carried at the time it happened.
  ///
  /// In en, this message translates to:
  /// **'{amount} UZS'**
  String walletUzs(int amount);

  /// Heading over the server-supplied prices. "Today" is deliberate: §10.5 lets an administrator change them.
  ///
  /// In en, this message translates to:
  /// **'Prices today'**
  String get walletPrices;

  /// Row label for the price of a single Coin.
  ///
  /// In en, this message translates to:
  /// **'1 Coin'**
  String get walletCoinPriceLabel;

  /// Row label for what one Candidate Unlock costs (§6.6).
  ///
  /// In en, this message translates to:
  /// **'Candidate unlock'**
  String get walletUnlockPriceLabel;

  /// BR-15's one-time bonus. Shown with its date because "granted once" is the guarantee, and the date is the evidence.
  ///
  /// In en, this message translates to:
  /// **'Registration bonus granted {date}'**
  String walletRegistrationBonusOn(String date);

  /// §6.2's Top up action, which opens §6.7's Payme / CLICK checkout.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get walletTopUp;

  /// Shown when Top up is tapped before M13 ships. An honest sentence rather than a dead button: a control that does nothing reads as a broken app, and the ten free Coins mean nobody is stuck.
  ///
  /// In en, this message translates to:
  /// **'Top-up is not available yet. It arrives with Payme and CLICK support.'**
  String get walletTopUpUnavailable;

  /// Heading over the Coin ledger (§6.2 "recent wallet activity").
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get walletActivity;

  /// Empty ledger. Says how the list fills up, and states BR-24's append-only guarantee in passing - an employer should learn early that nothing here can be quietly rewritten.
  ///
  /// In en, this message translates to:
  /// **'Nothing has moved in this wallet yet. Credits and unlocks both appear here, and neither is ever removed.'**
  String get walletActivityEmpty;

  /// Loads the next page of ledger entries.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get walletShowMore;

  /// Shown while a further page of the ledger is in flight.
  ///
  /// In en, this message translates to:
  /// **'Loading more…'**
  String get walletLoadingMore;

  /// The balance the server recorded after one ledger entry. Read from the entry, never accumulated down the list.
  ///
  /// In en, this message translates to:
  /// **'Balance {count}'**
  String walletBalanceAfter(int count);

  /// Coins arriving. The sign is what distinguishes a credit from a debit - colour alone would fail the same rule badges are held to.
  ///
  /// In en, this message translates to:
  /// **'+{count, plural, one{{count} Coin} other{{count} Coins}}'**
  String walletAmountCredit(int count);

  /// Coins leaving, with a true minus sign (U+2212). Takes the absolute count, so the caller never renders a double negative.
  ///
  /// In en, this message translates to:
  /// **'−{count, plural, one{{count} Coin} other{{count} Coins}}'**
  String walletAmountDebit(int count);

  /// Ledger kind registration_bonus (BR-15).
  ///
  /// In en, this message translates to:
  /// **'Registration bonus'**
  String get walletKindRegistrationBonus;

  /// Ledger kind top_up (§6.7).
  ///
  /// In en, this message translates to:
  /// **'Top-up'**
  String get walletKindTopUp;

  /// Ledger kind candidate_unlock (§6.6, BR-16).
  ///
  /// In en, this message translates to:
  /// **'Candidate unlock'**
  String get walletKindCandidateUnlock;

  /// Ledger kind admin_adjustment (§10.5). Always carries a reason - the server refuses one without.
  ///
  /// In en, this message translates to:
  /// **'Administrator adjustment'**
  String get walletKindAdminAdjustment;

  /// Ledger kind reversal: a refund or an undo, recorded as its own entry rather than by deleting what it corrects (BR-24).
  ///
  /// In en, this message translates to:
  /// **'Reversal'**
  String get walletKindReversal;

  /// Fallback for a kind this build does not know. A newer server's entry still shows its amount and resulting balance, which is the part being checked.
  ///
  /// In en, this message translates to:
  /// **'Wallet activity'**
  String get walletKindOther;

  /// Marks an adjustment or reversal as correcting an earlier entry. BR-24 forbids fixing a mistake by rewriting the entry that caused it, so the correction is visible instead.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get walletCorrection;

  /// Shown on the §6.2 wallet tile when the balance could not be fetched. The tile still opens the wallet screen, which renders the failure and offers the retry - a summary beside a profile must not turn that screen into an error page.
  ///
  /// In en, this message translates to:
  /// **'Balance unavailable'**
  String get walletBalanceUnavailable;

  /// §7.3's unlock action. The Coin count is a placeholder rather than the literal "2 Coins" of §6.6, because the price is server configuration and §10.5 lets an administrator change it.
  ///
  /// In en, this message translates to:
  /// **'Unlock contact — {coins}'**
  String unlockContact(String coins);

  /// Heading of the confirmation sheet (§6.6).
  ///
  /// In en, this message translates to:
  /// **'Unlock contact'**
  String get unlockTitle;

  /// Confirmation sheet row: what the unlock costs.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get unlockCost;

  /// Confirmation sheet row: the balance before the charge.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get unlockBalanceNow;

  /// Confirmation sheet row: what the balance becomes. §6.6 requires all three figures before anything is charged, so nobody discovers the cost by paying it.
  ///
  /// In en, this message translates to:
  /// **'Balance after'**
  String get unlockBalanceAfter;

  /// The button that charges. E-44 asks for Cancel and Confirm, and the sheet title already names the purchase — repeating it on the button would be the same words twice with the cost and both balances in between.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get unlockConfirm;

  /// What the two Coins buy (§6.6, BR-16). Says the charge is one-off because UAT-18 is the reassurance an employer needs before spending anything.
  ///
  /// In en, this message translates to:
  /// **'Phone number, e-mail and CV become available, and you can start a conversation. Charged once — returning to this candidate later is free.'**
  String get unlockWhatYouGet;

  /// Confirmation after a successful unlock.
  ///
  /// In en, this message translates to:
  /// **'Contact unlocked'**
  String get unlockDone;

  /// UAT-18: shown when the entitlement already existed, so `charged` came back false. Worth saying rather than silently succeeding - an employer who tapped twice should be told the second tap was free rather than left wondering.
  ///
  /// In en, this message translates to:
  /// **'Already unlocked — nothing was charged'**
  String get unlockAlready;

  /// Shown where contact was opened by a purchase rather than by an application.
  ///
  /// In en, this message translates to:
  /// **'Unlocked {date}'**
  String unlockUnlockedOn(String date);

  /// UAT-19: replaces the confirm action when the balance is short. The unlock is blocked and the route out is top-up, not an error.
  ///
  /// In en, this message translates to:
  /// **'Top up to unlock'**
  String get unlockTopUpNeeded;

  /// The `unlock_required` reason code: a verified employer, a readable candidate, and no entitlement yet. Says both routes on purpose - §11.1 treats an application as an entitlement of its own, so an employer who is happy to wait should not be told paying is the only way. This code exists only on a server that honours the unlock, which is why it is also what the unlock control is gated on.
  ///
  /// In en, this message translates to:
  /// **'Unlock contact to reach this candidate now. It also opens free if they apply to one of your vacancies, or accept an invitation.'**
  String get candidateExposureUnlockRequired;

  /// Heading of §06's locked contact block (E-43). Names what is behind the lock rather than announcing that something is locked - an employer deciding whether to spend Coins needs to know what the Coins buy.
  ///
  /// In en, this message translates to:
  /// **'Protected information'**
  String get contactLockedTitle;

  /// The same block once BR-09 allows contact.
  ///
  /// In en, this message translates to:
  /// **'Contact details'**
  String get contactUnlockedTitle;

  /// Row label. The value beside it is masked with a fixed-width run of dots until the entitlement exists - never a mask derived from the real value, which would leak its length (§8.7).
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get contactPhone;

  /// Row label. Reserved: the candidate DTO carries no e-mail field yet, so this row is always masked today.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get contactEmail;

  /// Row label for the CV while it is locked. Once open, the real file list renders below with each file's purpose and size, so this row disappears rather than duplicating it.
  ///
  /// In en, this message translates to:
  /// **'CV file'**
  String get contactCv;

  /// Stands in for the CV's name and size while locked. Says the format, which is useful, and nothing that identifies the file.
  ///
  /// In en, this message translates to:
  /// **'PDF · locked'**
  String get contactCvLocked;

  /// §6.6 and BR-16 in two sentences, under the locked rows. The second sentence is the one that matters before a purchase: UAT-18's guarantee is the reassurance an employer needs to spend anything at all.
  ///
  /// In en, this message translates to:
  /// **'{coins} opens one new candidate\'s phone, e-mail, CV and conversation. An unlocked candidate is never charged for again.'**
  String contactLockedExplainer(String coins);

  /// Destination for the 403 refusals (`employer.not_verified`, `employer.profile_incomplete`) and for the `not_verified_employer` exposure reason. BR-03 is a precondition an employer cannot buy past, so these must route to verification and never to top-up - offering Coins there would sell access §7 is about to refuse.
  ///
  /// In en, this message translates to:
  /// **'Go to verification'**
  String get unlockGoToVerification;

  /// §06's unlock-success banner. Both figures are already-localized Coin quantities: the amount actually debited, taken from the response rather than from what the sheet predicted, and the new balance refetched from the wallet. Neither is computed here.
  ///
  /// In en, this message translates to:
  /// **'{coins} spent · balance {balance}'**
  String unlockChargedDetail(String coins, String balance);

  /// Title of the in-sheet notice when the server refuses a purchase the sheet had judged affordable - the balance moved between the sheet opening and the tap. Names the state; the server's own sentence below it carries the two numbers, which are the authority now that the displayed rows are known to be stale.
  ///
  /// In en, this message translates to:
  /// **'Not enough Coins'**
  String get unlockInsufficient;

  /// §06 puts the balance's approximate UZS value and the Coin price on one line under the balance, instead of a prices table. Both figures are the server's: `value` is `balanceValueUzs`, never coins × price, and `price` is `coinPriceUzs`.
  ///
  /// In en, this message translates to:
  /// **'≈ {value} UZS · 1 Coin = {price} UZS'**
  String walletValueAndPrice(int value, int price);

  /// What a Coin is for, in a sentence, where a price table used to be. The second half matters as much as the first: §6.6 makes search and preview free, and an employer who thinks browsing costs Coins will not browse.
  ///
  /// In en, this message translates to:
  /// **'{coins} unlocks one new candidate\'s contact. Searching candidates and viewing profiles is free.'**
  String walletCoinRule(String coins);

  /// §06's E-52, the whole ledger. Distinct from the wallet's own "recent activity": this one has filters and month headers.
  ///
  /// In en, this message translates to:
  /// **'Activity history'**
  String get walletHistoryTitle;

  /// Doubles as the filter chip on E-52 and the link from the wallet's recent-activity heading to it.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get walletHistoryAll;

  /// Filter for entries where Coins arrived. Selected by the amount's **sign**, not by kind — an administrator adjustment can be either, and a reversal is a credit that undoes a debit.
  ///
  /// In en, this message translates to:
  /// **'Topped up'**
  String get walletHistoryIncoming;

  /// Filter for entries where Coins left. Also by sign, so a sixth kind from a newer server lands on one side rather than vanishing from both.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get walletHistoryOutgoing;

  /// §11 wants an empty filter result told apart from an empty list: one is resolved by clearing the filter, the other by using the app.
  ///
  /// In en, this message translates to:
  /// **'No activity of this kind yet. Clear the filter to see everything the wallet has recorded.'**
  String get walletHistoryNoMatch;

  /// §06's E-53.
  ///
  /// In en, this message translates to:
  /// **'Activity detail'**
  String get walletDetailTitle;

  /// Heading over the detail rows.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get walletDetailSection;

  /// Mandatory on an administrator adjustment (§10.5); absent on everything else.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get walletDetailReason;

  /// The wall clock the server resolved, never re-rendered in the device zone.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get walletDetailWhen;

  /// The UZS this entry carried **at the time**, never recomputed from today's price (§10.5). Absent on an unlock or a bonus, which are priced in Coins and never touched money.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get walletDetailAmountUzs;

  /// The signed Coin amount, repeated here because it is the figure a support call is about.
  ///
  /// In en, this message translates to:
  /// **'Effect on balance'**
  String get walletDetailEffect;

  /// The balance the server recorded after this entry — read, never accumulated.
  ///
  /// In en, this message translates to:
  /// **'Balance after'**
  String get walletDetailBalanceAfter;

  /// What support can look the entry up by: the payment order behind a top-up, otherwise the entry's own id. Never an unlock's `referenceId`, which is a candidate's user id and identifies a person rather than a transaction.
  ///
  /// In en, this message translates to:
  /// **'Reference number'**
  String get walletDetailReference;

  /// Title of the support notice on E-53.
  ///
  /// In en, this message translates to:
  /// **'Something wrong with this entry?'**
  String get walletDetailSupportTitle;

  /// §06's support footnote, plus BR-24 stated plainly. The second sentence is worth the words: an employer disputing a charge should know the ledger cannot have been altered, which is exactly why the append-only guarantee exists.
  ///
  /// In en, this message translates to:
  /// **'Contact support and quote the reference number above. Nothing in this history can be edited or deleted, so the record you are looking at is the record they will see.'**
  String get walletDetailSupport;

  /// Shown on E-53 for an adjustment or a reversal. BR-24 in one sentence, at the moment an employer is most likely to wonder why they can see both entries.
  ///
  /// In en, this message translates to:
  /// **'This entry corrects an earlier one. The original stays in the history — corrections are added, never written over.'**
  String get walletCorrectionExplained;

  /// Employer invitations (§8.2). Used on the segmented control inside the candidate's Applications tab, not as a bottom-nav label — the five-tab cap is full.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get navInvitations;

  /// Invitation status: delivered and not yet answered. Also the fallback label for a status this app version does not recognise.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get invitationSent;

  /// Invitation status: the candidate asked a question, so it now waits on the employer. Not a final state — accepting or declining afterwards is allowed.
  ///
  /// In en, this message translates to:
  /// **'Details requested'**
  String get invitationDetailsRequested;

  /// Invitation status: the candidate accepted, which is what opens contact details to that employer (BR-09).
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get invitationAccepted;

  /// Invitation status: the candidate declined. Final. Shown to both sides, so the wording must not read as a reproach to the person who chose it.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get invitationDeclined;

  /// Button. A verb where invitationAccepted is a state — a past participle on a button reads as a label, not an action.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get invitationAccept;

  /// Button.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get invitationDecline;

  /// Button for §8.2's "Request details". Phrased as asking a question rather than requesting details, because that is what the candidate actually does with it and it makes the empty state of the field obvious.
  ///
  /// In en, this message translates to:
  /// **'Ask a question'**
  String get invitationRequestDetails;

  /// Empty state for the candidate's invitation inbox. Says what would fill it rather than that it is empty.
  ///
  /// In en, this message translates to:
  /// **'Employers who invite you to a vacancy will appear here.'**
  String get invitationsInboxEmpty;

  /// §8.2's second shape: an invitation to work rather than to a specific vacancy. Shown first on the card, because the absence of a posting is the first thing the candidate needs to know.
  ///
  /// In en, this message translates to:
  /// **'General invitation'**
  String get invitationGeneral;

  /// Opens the full vacancy behind a vacancy-scoped invitation.
  ///
  /// In en, this message translates to:
  /// **'Open vacancy'**
  String get invitationOpenVacancy;

  /// Placeholder line while the vacancy behind an invitation is fetched. A line of text rather than a spinner, so a list of cards does not flicker.
  ///
  /// In en, this message translates to:
  /// **'Loading the vacancy…'**
  String get invitationVacancyLoading;

  /// A real failure fetching the vacancy behind an invitation, as distinct from vacancyGoneTitle, which is the ordinary 404 for a vacancy that has closed since.
  ///
  /// In en, this message translates to:
  /// **'The vacancy could not be loaded.'**
  String get invitationVacancyUnavailable;

  /// Fallback when the vacancy behind an invitation has no title yet.
  ///
  /// In en, this message translates to:
  /// **'Vacancy'**
  String get invitationVacancyUntitled;

  /// Label above the candidate's own note, played back to them on the invitation card.
  ///
  /// In en, this message translates to:
  /// **'Your reply'**
  String get invitationYourReply;

  /// A general invitation's stated pay range. Only general invitations carry pay of their own — a vacancy invitation's lives on the vacancy.
  ///
  /// In en, this message translates to:
  /// **'{from} – {to} UZS'**
  String invitationPayRange(int from, int to);

  /// A general invitation with only a lower bound on pay.
  ///
  /// In en, this message translates to:
  /// **'From {amount} UZS'**
  String invitationPayFrom(int amount);

  /// A general invitation with only an upper bound on pay.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount} UZS'**
  String invitationPayUpTo(int amount);

  /// Title of the accept confirmation sheet.
  ///
  /// In en, this message translates to:
  /// **'Accept this invitation?'**
  String get invitationAcceptTitle;

  /// The disclosure, shown before the accept button. Names the three protected fields rather than saying "your contact details": a candidate cannot weigh a category, and these are exactly the three §11.1 protects. Also states irreversibility, because §8.2 has no transition out of accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepting shares your phone number, e-mail address and CV with this employer, and cannot be undone.'**
  String get invitationAcceptDiscloses;

  /// Title of the decline confirmation sheet.
  ///
  /// In en, this message translates to:
  /// **'Decline this invitation?'**
  String get invitationDeclineTitle;

  /// Shown before the decline button. Says what stays private, that the status is final, and that a decline is not a permanent block — the last part matters because the alternative reading is that declining once ends the relationship.
  ///
  /// In en, this message translates to:
  /// **'Your contact details stay private. Declining is final, but the employer may invite you again later.'**
  String get invitationDeclineFinal;

  /// Title of the sheet behind §8.2's "Request details".
  ///
  /// In en, this message translates to:
  /// **'Ask the employer a question'**
  String get invitationRequestDetailsTitle;

  /// Shown before the ask-a-question button. States both things the candidate needs: that asking is not a decision, and that it discloses nothing.
  ///
  /// In en, this message translates to:
  /// **'You can still accept or decline afterwards. Your contact details stay private until you accept.'**
  String get invitationRequestDetailsBody;

  /// Field label when asking for details. Required, unlike the note on the other two responses.
  ///
  /// In en, this message translates to:
  /// **'Your question'**
  String get invitationQuestionLabel;

  /// Hint under the question field. An example rather than an instruction, because the field is empty and a blank box invites a blank answer.
  ///
  /// In en, this message translates to:
  /// **'For example: where exactly is the work, and when does it start?'**
  String get invitationQuestionHint;

  /// Field label on accept and decline. Marked optional in the label itself, so a candidate declining is never left wondering whether a reason is required.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get invitationNoteLabel;

  /// Hint under the optional message field.
  ///
  /// In en, this message translates to:
  /// **'Anything you would like the employer to know.'**
  String get invitationNoteHint;

  /// Title over the server's refusal in the response sheet. §8.2's `invitation.final` and `invitation.response_not_allowed` both mean the invitation moved elsewhere — usually another device — so the sentence explains the refusal rather than blaming the tap.
  ///
  /// In en, this message translates to:
  /// **'This invitation has already been answered'**
  String get invitationAlreadyAnswered;

  /// Placeholder in a read-only field that opens a picker.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get commonChoose;

  /// Screen title for the compose form. Deliberately different wording from invitationSend, the button, so the two are distinguishable.
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get invitationSendTitle;

  /// The submit button on the compose form.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get invitationSend;

  /// States the resolution of the section 8.2 contradiction where the employer will act on it. Worth saying explicitly: an employer who thinks inviting costs Coins will not invite, and section 7.4 own example needs dozens of invitations.
  ///
  /// In en, this message translates to:
  /// **'Sending is free. Contact details open only if the candidate accepts.'**
  String get invitationSendFree;

  /// One of the two invitation shapes; the other is invitationGeneral.
  ///
  /// In en, this message translates to:
  /// **'To a vacancy'**
  String get invitationToVacancy;

  /// Label above the list of the employer open vacancies.
  ///
  /// In en, this message translates to:
  /// **'Choose a vacancy'**
  String get invitationVacancyLabel;

  /// Only open vacancies may carry an invitation (BR-06) — the server refuses the rest with invitation.vacancy_not_open.
  ///
  /// In en, this message translates to:
  /// **'No open vacancies'**
  String get invitationNoOpenVacancyTitle;

  /// A notice rather than an error, because the general shape is a way forward that needs nothing published.
  ///
  /// In en, this message translates to:
  /// **'An invitation can only point at an active vacancy. You can still send a general work invitation.'**
  String get invitationNoOpenVacancyBody;

  /// Required on a general invitation — it is what makes the invitation about something.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get invitationOccupation;

  /// Optional on a general invitation.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get invitationRegion;

  /// Optional, and scoped to the chosen region — districts are children of the region dictionary, not a type of their own.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get invitationDistrict;

  /// Excludes a range rather than qualifying one: a negotiable figure and a stated one are different answers.
  ///
  /// In en, this message translates to:
  /// **'Pay is negotiable'**
  String get invitationNegotiable;

  /// Lower bound, in som.
  ///
  /// In en, this message translates to:
  /// **'Pay from'**
  String get invitationSalaryFrom;

  /// Upper bound, in som.
  ///
  /// In en, this message translates to:
  /// **'Pay to'**
  String get invitationSalaryTo;

  /// A payment_period dictionary id — per month, per day, per shift.
  ///
  /// In en, this message translates to:
  /// **'Per'**
  String get invitationSalaryPeriod;

  /// Free text by design: a general invitation is a message, and the structured version of a schedule is what publishing a vacancy is for.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get invitationSchedule;

  /// Hint under the schedule field.
  ///
  /// In en, this message translates to:
  /// **'For example: six days a week, mornings'**
  String get invitationScheduleHint;

  /// The employer own words, shown to the candidate verbatim and never translated. Marked optional in the label.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get invitationMessageLabel;

  /// Hint under the message field.
  ///
  /// In en, this message translates to:
  /// **'What you would like the candidate to know'**
  String get invitationMessageHint;

  /// The daily cap, entirely the server figures (section 12.3.1). `limit` is the effective total — the client deliberately does not model a free tier and a purchased one, so a future purchase raises the number and this string is already correct.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {limit} invitations left today'**
  String invitationQuotaRemaining(int remaining, int limit);

  /// A calendar boundary in the platform time zone, not a rolling window — "it resets at midnight" is something an employer can plan a day around.
  ///
  /// In en, this message translates to:
  /// **'Resets at {at}'**
  String invitationQuotaResets(String at);

  /// Warning-toned rather than an error: the employer did nothing wrong and the remedy is a clock.
  ///
  /// In en, this message translates to:
  /// **'Today’s invitations are used up'**
  String get invitationQuotaSpentTitle;

  /// The server invitation.already_invited — a fact rather than a failure. One open invitation per candidate per vacancy; answering frees the slot.
  ///
  /// In en, this message translates to:
  /// **'Already invited'**
  String get invitationAlreadySentTitle;

  /// Confirmation after a successful send. A transient toast rather than an inline banner, unlike the unlock, and the difference is deliberate: an unlock carries figures somebody may want to read twice, while this carries none — the invitation itself is now in the sent list, which is where it belongs.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSentConfirm;

  /// The employer's half of section 8.2, and the title of the screen the section 7.4 counts open. Deliberately not "My invitations", which the candidate's inbox could equally be called.
  ///
  /// In en, this message translates to:
  /// **'Invitations sent'**
  String get invitationsSentTitle;

  /// The unfiltered empty list. States what would fill it rather than that it is empty, which the title above it already says.
  ///
  /// In en, this message translates to:
  /// **'Candidates you invite will appear here.'**
  String get invitationsSentEmpty;

  /// A filter that matched nothing, which is a different fact from having invited nobody: this one is fixed by clearing the filter. Telling an employer looking at "Declined" that they have invited nobody would simply be false.
  ///
  /// In en, this message translates to:
  /// **'No invitations with this status. Clear the filter to see everything you have sent.'**
  String get invitationsSentNoMatch;

  /// Shown when the list was opened from one vacancy, so the server is narrowing it. The scope is stated because the list looks identical to the unscoped one otherwise, and a short list would read as "few invitations" rather than "few on this vacancy".
  ///
  /// In en, this message translates to:
  /// **'This vacancy only'**
  String get invitationsSentForVacancy;

  /// The unfiltered choice among the four statuses. Sends no `status` parameter rather than a fifth value, matching what the server means by its absence.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get invitationFilterAll;

  /// Labels the employer's own message on their sent list. The counterpart of `invitationYourReply` on the candidate's side: the same words belong to whoever is reading, and only the label says whose they are.
  ///
  /// In en, this message translates to:
  /// **'What you wrote'**
  String get invitationYourMessage;

  /// Labels the note a candidate attached when answering — and on "Details requested" it is a question waiting for an answer, which is why it is never trimmed to a preview.
  ///
  /// In en, this message translates to:
  /// **'Candidate\'s reply'**
  String get invitationCandidateReply;

  /// Heading on an accepted invitation. BR-09 grants contact details and files on an acceptance, at the same strength as an application and without a Coin.
  ///
  /// In en, this message translates to:
  /// **'Contact is open'**
  String get invitationContactOpenTitle;

  /// Says the unlock is not needed, because an employer who has just been shown a paid unlock on every other candidate screen has every reason to assume it is. Section 11.1 grants contact on an accepted invitation, and it survives the candidate hiding their profile.
  ///
  /// In en, this message translates to:
  /// **'The candidate accepted, so their phone, e-mail and CV are on their profile. No unlock needed.'**
  String get invitationContactOpenBody;

  /// Opens section 7.3's "View profile" from a sent invitation. A tap and never a prefetch: every open is a logged access to protected data (section 11.1), so thirty rows must not resolve thirty candidates.
  ///
  /// In en, this message translates to:
  /// **'View candidate'**
  String get invitationOpenCandidate;

  /// The first two of section 7.4 step 7's four counts; interviewed and hired are application stages and sit beside this from a different endpoint. `invited` is the **sum of every status** and not the count of `sent` — a candidate who answered was still invited, so reading `byStatus.sent` would make the number fall as replies arrive.
  ///
  /// In en, this message translates to:
  /// **'{invited} invited, {accepted} accepted'**
  String invitationCounts(int invited, int accepted);

  /// Shown when an attachment downloaded fine and nothing installed can display it. Its own message rather than a generic failure: the bytes arrived and the server allowed it, so "check your connection" would send the reader looking in the wrong place. The remedy is on the device. Named for the file rather than for whose file it is — §9.1's chat attachments reach a candidate too, and the sentence is about the phone either way.
  ///
  /// In en, this message translates to:
  /// **'No app on this phone can open this file.'**
  String get fileNoViewer;

  /// Header metric on section 6.2's dashboard. Counted from `isOpenForApplications`, which the server computes from the status *and* the deadline — so a vacancy that is active with yesterday's deadline is correctly not counted.
  ///
  /// In en, this message translates to:
  /// **'Active vacancies'**
  String get dashboardActiveVacancies;

  /// Section 6.2's "total open positions": the worker counts of the active vacancies added up. A vacancy that states no worker count contributes nothing rather than one.
  ///
  /// In en, this message translates to:
  /// **'Open positions'**
  String get dashboardOpenPositions;

  /// Applications still at `submitted` — nobody has opened them. Shown as an em dash while any per-vacancy count is still in flight, because a zero that becomes 34 a moment later was a wrong number rather than a stale one.
  ///
  /// In en, this message translates to:
  /// **'New applications'**
  String get dashboardNewApplications;

  /// Heading over the dashboard's pending work. It comes before the metrics because the design says why: "a recruiter opens this app to act, not to read numbers."
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get dashboardAttention;

  /// Shown when the pending list is empty. Deliberately a plain positive line rather than an empty state with an illustration: an empty queue is the good outcome here, and drawing it as absence would read as a failure to load.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting on you.'**
  String get dashboardAttentionClear;

  /// The first pending row, and it outranks the rest: BR-03 means an unverified employer cannot publish a vacancy, search candidates or buy an unlock, so nothing else on the screen works until it is done.
  ///
  /// In en, this message translates to:
  /// **'Verification is not complete'**
  String get dashboardVerificationTitle;

  /// A vacancy a moderator sent back (section 6.4). Ranked above unread applicants because it is the only item on the list whose timing the employer does not control.
  ///
  /// In en, this message translates to:
  /// **'Changes are required'**
  String get dashboardVacancyRejected;

  /// One pending row per vacancy with applications still at `submitted`.
  ///
  /// In en, this message translates to:
  /// **'{count} applications not yet reviewed'**
  String dashboardUnreviewed(int count);

  /// Section 6.2's "candidates to review". Last in the pending list because it is a nudge rather than a blockage — nobody is waiting on it.
  ///
  /// In en, this message translates to:
  /// **'{count} saved candidates'**
  String dashboardSavedCandidates(int count);

  /// Heading over one meter per open vacancy, tracking section 7.4's counts against the target.
  ///
  /// In en, this message translates to:
  /// **'Hiring progress'**
  String get dashboardHiring;

  /// Hires against the worker count (section 6.5). Absent when the vacancy states no worker count, because a denominator nobody set is not a target to measure against.
  ///
  /// In en, this message translates to:
  /// **'{hired} of {openings}'**
  String dashboardHiredOf(int hired, int openings);

  /// Legend for the meter's first segment. The figure is in the label because an 8pt bar cannot be read off, and the design's own rule is that status is never colour alone.
  ///
  /// In en, this message translates to:
  /// **'Hired {count}'**
  String dashboardMeterHired(int count);

  /// Legend for the meter's second segment, and it counts invitations still **in the air** rather than every invitation ever sent: the three segments add up to the openings, so they have to be disjoint, and somebody already hired must not be counted twice. Non-terminal statuses only — the same set the candidate's inbox uses to decide whether an invitation can still be answered.
  ///
  /// In en, this message translates to:
  /// **'Invited {count}'**
  String dashboardMeterInvited(int count);

  /// Legend for the unfilled part of the meter. Drawn by *not* drawing it — the track showing through is the remainder — so this label is the only thing that names it.
  ///
  /// In en, this message translates to:
  /// **'Remaining {count}'**
  String dashboardMeterRemaining(int count);

  /// Heading over section 6.2's wallet widget. The Top up action it also asks for is M13 and blocked on merchant credentials, so the tile shows the balance and its som value and leads to the ledger.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get dashboardWallet;

  /// The one screen where somebody acts on the account rather than on the work: signed-in devices (section 4.2), signing out, and requesting deletion (BR-14).
  ///
  /// In en, this message translates to:
  /// **'Account and security'**
  String get accountTitle;

  /// Section 4.2's session list.
  ///
  /// In en, this message translates to:
  /// **'Signed-in devices'**
  String get accountDevices;

  /// Says what the list is *for*. A list of devices with no instruction is a list most people scroll past; the reason to read it is that one of the rows might not be theirs.
  ///
  /// In en, this message translates to:
  /// **'If you see a device you do not recognise, end its session.'**
  String get accountDevicesBody;

  /// A session whose device name and platform are both absent — an older build sent neither. Named rather than blank, because three empty lines read as a rendering failure rather than as missing data.
  ///
  /// In en, this message translates to:
  /// **'Unnamed device'**
  String get accountDeviceUnknown;

  /// The wall clock the platform recorded, never converted to the device's zone: a session opened abroad would otherwise be dated in the wrong one (section 8.3).
  ///
  /// In en, this message translates to:
  /// **'Last used {at}'**
  String accountLastUsed(String at);

  /// Marks the row belonging to the phone in the reader's hand. The server decides it by comparing against the presented token, so it is not derivable client-side — and it is the one field that must not be wrong, because revoking that row signs the reader out.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get accountThisDevice;

  /// Revokes one device. The verb, not "Remove": the device is not being removed from anything, its sign-in is being ended.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get accountRevoke;

  /// Confirmation for revoking another device.
  ///
  /// In en, this message translates to:
  /// **'End this session?'**
  String get accountRevokeTitle;

  /// States the consequence rather than asking for confirmation twice. Nothing is lost — the session ends, the account does not.
  ///
  /// In en, this message translates to:
  /// **'That device will have to sign in again.'**
  String get accountRevokeBody;

  /// Revoking the current session *is* signing out, so the confirmation says so rather than repeating "end session" — a reader who taps it should not be surprised by what happens next.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device?'**
  String get accountRevokeCurrentTitle;

  /// The row is not hidden: somebody looking at a list of their devices must be able to act on the one in their hand. So the consequence is spelled out instead.
  ///
  /// In en, this message translates to:
  /// **'This is the device you are using. You will be signed out now.'**
  String get accountRevokeCurrentBody;

  /// Section 4.2's terminate-all. Offered only when more than one device is signed in — with one, it is the same button as Sign out under a longer name.
  ///
  /// In en, this message translates to:
  /// **'End all sessions'**
  String get accountRevokeAll;

  /// Confirmation for terminate-all.
  ///
  /// In en, this message translates to:
  /// **'End every session?'**
  String get accountRevokeAllTitle;

  /// "Including this one" is the load-bearing half: "every device" is a phrase most people read as "every *other* device", and the surprise arrives after the action rather than before it.
  ///
  /// In en, this message translates to:
  /// **'Every device will be signed out, including this one.'**
  String get accountRevokeAllBody;

  /// BR-14. A section heading, and the section exists because an app that lets people create an account has to let them delete it from inside the app.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDelete;

  /// Says what is lost before the button rather than after it. Deliberately no date: the server sends `purgeAfter: null` because the retention period is an open client question, so naming one would be promising something nobody has agreed.
  ///
  /// In en, this message translates to:
  /// **'Your profile, applications and messages will be removed. This cannot be undone.'**
  String get accountDeleteBody;

  /// "Request", because that is what BR-14 does: the account moves to `deletion_requested` and a status-history row is written. Nothing is purged as the button is released, and a label saying "Delete" would describe a different operation.
  ///
  /// In en, this message translates to:
  /// **'Request deletion'**
  String get accountDeleteAction;

  /// Confirmation for BR-14.
  ///
  /// In en, this message translates to:
  /// **'Request account deletion?'**
  String get accountDeleteConfirmTitle;

  /// "Not from the app" rather than "not at all": the request is a status change an administrator can see (section 10), so claiming it is absolutely final would be a stronger promise than the system makes.
  ///
  /// In en, this message translates to:
  /// **'We will start removing your account. You will not be able to undo this from the app.'**
  String get accountDeleteConfirmBody;

  /// Shown in place of the button once BR-14 has been recorded.
  ///
  /// In en, this message translates to:
  /// **'Deletion requested'**
  String get accountDeleteRequestedTitle;

  /// Points at support rather than at a date, because the server returns `purgeAfter: null` and there is no retention period to quote yet.
  ///
  /// In en, this message translates to:
  /// **'Your request has been recorded. Support can tell you what happens next.'**
  String get accountDeleteRequestedBody;

  /// One place, not a set: the feed query takes a single `regionId`. Both are ids in the **region** dictionary, since districts are its children (section 5.1) rather than a type of their own, so choosing a district sets `regionId` to it.
  ///
  /// In en, this message translates to:
  /// **'Region or district'**
  String get filtersRegion;

  /// One of section 5.5's nine filters. Multi-select.
  ///
  /// In en, this message translates to:
  /// **'Employment type'**
  String get filtersEmploymentType;

  /// One of section 5.5's nine filters. Multi-select.
  ///
  /// In en, this message translates to:
  /// **'Work format'**
  String get filtersWorkFormat;

  /// One of section 5.5's nine filters. Multi-select.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get filtersShift;

  /// The lower half of section 5.5's pay range. There is no upper half: the feed query has no parameter for it, and a control that does nothing to the list is worse than one that is absent.
  ///
  /// In en, this message translates to:
  /// **'Pay from'**
  String get filtersSalaryFrom;

  /// The server's rule, stated where somebody would otherwise conclude the filter is broken: a negotiable vacancy passes a pay floor because it has not said no to the figure, and excluding it would hide much of the seasonal work.
  ///
  /// In en, this message translates to:
  /// **'Vacancies with negotiable pay are still shown.'**
  String get filtersSalaryNegotiableNote;

  /// Section 5.5's publication date. Matched on or after, and sent as `YYYY-MM-DD` — the server compares against the date it published in its own zone, so the client must not turn this into an instant.
  ///
  /// In en, this message translates to:
  /// **'Published from'**
  String get filtersPublishedFrom;

  /// Says out loud what section 5.5 lists and the API cannot do, rather than leaving somebody hunting for a control that is not there. Removed the day the query parameters exist.
  ///
  /// In en, this message translates to:
  /// **'Three filters are not available yet'**
  String get filtersUnavailableTitle;

  /// Names the three rather than apologising generically, and says the rest works — otherwise a reader has no way to tell which of the controls above to trust.
  ///
  /// In en, this message translates to:
  /// **'Experience, language and an upper pay limit cannot be filtered on yet. Everything else here works.'**
  String get filtersUnavailableBody;

  /// Shown above a filtered feed. A set of ids counts once however many it holds — three occupations is one narrowing decision, and a badge reading 5 for one row of chips tells nobody anything.
  ///
  /// In en, this message translates to:
  /// **'{count} filters applied'**
  String feedFilteredNote(int count);

  /// A filtered feed with no results is a different fact from an empty feed: one is fixed by changing the filters, the other by waiting for employers to publish. Telling somebody with four filters set that there are no vacancies would simply be false.
  ///
  /// In en, this message translates to:
  /// **'No vacancies match these filters. Try widening them.'**
  String get feedFilteredEmpty;

  /// Shown on the saved tab while filters are set. The other two feeds are the server choosing what to show; saved is a list the candidate curated, and a filter making a saved vacancy disappear from it reads as data loss rather than as narrowing.
  ///
  /// In en, this message translates to:
  /// **'Saved vacancies are never filtered.'**
  String get feedSavedUnfiltered;

  /// An empty note list. Nothing to explain; nothing is wrong.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get notesEmpty;

  /// The API offers GET and POST and no edit or delete, so notes are append-only and the label says "new" rather than "note": a dated observation silently rewritten later is worse than two notes, because the first one is what the employer acted on.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get notesNewLabel;

  /// A hint that shows what the field is *for*. A recruiter shown an empty box labelled "note" writes nothing; one shown this writes the thing they would have kept in their head.
  ///
  /// In en, this message translates to:
  /// **'Asked for 8m, may take 6.5 — call back Thursday'**
  String get notesNewHint;

  /// A stage with nobody in it is a different fact from a vacancy nobody applied to: one is fixed by clearing the filter, the other by waiting. Telling an employer looking at "Hired" that nobody has applied would be false.
  ///
  /// In en, this message translates to:
  /// **'Nobody is at this stage. Clear the filter to see every applicant.'**
  String get applicantsNoneAtStage;

  /// §7.3: one vacancy's shortlist, opened from that vacancy. A shortlist is always per-vacancy — an employer filling two roles keeps two.
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get shortlistTitle;

  /// Empty state. Deliberately not “you have shortlisted nobody”: BR-02 takes a candidate who hides their profile out of this list without anyone having removed them, exactly as it does the saved list.
  ///
  /// In en, this message translates to:
  /// **'Nobody is shortlisted yet'**
  String get shortlistEmpty;

  /// §2.3: the screen an account with no role lands on. A question rather than “Choose your role”, because the answer is about what the person came to do.
  ///
  /// In en, this message translates to:
  /// **'How will you use JobBridge?'**
  String get roleSelectionTitle;

  /// §2.3 allows both roles on one account and makes the choice reversible, so the screen says so before somebody agonises over it.
  ///
  /// In en, this message translates to:
  /// **'Pick one or both — you can add the other later without a second account.'**
  String get roleSelectionSubtitle;

  /// §2.2's candidate capabilities, in the order somebody meets them. Not a full list — the point is to make the word “Candidate” mean something to a first-time reader.
  ///
  /// In en, this message translates to:
  /// **'Build a profile employers can find, apply to vacancies, and answer invitations.'**
  String get roleCandidateDescription;

  /// §2.2's employer capabilities. Deliberately silent about Coins and unlocks: those are a cost, and a cost stated before anything is on offer reads as a paywall on registration.
  ///
  /// In en, this message translates to:
  /// **'Publish vacancies, search candidates, and invite the people you want to talk to.'**
  String get roleEmployerDescription;

  /// §2.3's “role-specific data and menus shall remain separated”. Shown because the fear that picking both mixes a personal job search into a company account is exactly what stops people picking both.
  ///
  /// In en, this message translates to:
  /// **'With both, one account keeps two separate spaces: your own profile and your company\'s, switched from your profile.'**
  String get roleSelectionBoth;

  /// §9.1's gate, stated as what fills the list rather than as what is missing. Deliberately role-neutral: one screen serves both sides, and picking the sentence by role would make this screen hold an opinion about §9.1 that the server already holds better.
  ///
  /// In en, this message translates to:
  /// **'A conversation opens with a hiring interaction — an application, or an invitation that was accepted.'**
  String get chatListEmpty;

  /// A thread whose counterpart has no name to show. §7.3's permitted-name rule means an absent name is sometimes the correct answer rather than a load that failed, so the row still reads as a person instead of as a gap.
  ///
  /// In en, this message translates to:
  /// **'Participant'**
  String get chatParticipantUnknown;

  /// The unread pill's numeral. A message rather than a Dart format string so the thousands separator follows the interface variant; the pill's shape carries the meaning, so there is no word here.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String chatUnreadCount(int count);

  /// What a screen reader says for the unread pill. The pill itself is a numeral, and a reader hearing only "3" would not know three of what.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} unread message} other{{count} unread messages}}'**
  String chatUnreadSemantics(int count);

  /// The preview line of a thread that was opened and never written in. A real state: opening a conversation and sending one are two requests, and somebody can do the first and change their mind.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chatNoMessages;

  /// The preview line when the last message carried a file and no text. Three cases, not two: the server sends the last message's body, and a message with only an attachment has none — which is not the same fact as a thread nobody has written in.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get chatAttachment;

  /// Badge on a thread whose hiring interaction has ended (§9.1). The word says what the reader can still do, not what they cannot: the history stays readable on purpose.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get chatReadOnly;

  /// Badge on a thread the other side blocked. A separate word from read-only because it is undone by a different thing.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get chatBlocked;

  /// Badge on a thread the reader blocked themselves. Same state, different sentence: only the person who set a block can lift it, so telling the two apart on the row is what makes the thread's own screen unsurprising.
  ///
  /// In en, this message translates to:
  /// **'You blocked this'**
  String get chatBlockedByYou;

  /// §9.1: the interaction ended, so the thread no longer accepts messages. Not "closed" — closed reads as gone, and the messages are still here.
  ///
  /// In en, this message translates to:
  /// **'This conversation is history'**
  String get chatReadOnlyTitle;

  /// Names the cause, because the remedy is not on this screen: what reopens the thread is the hiring interaction resuming, and somebody looking for a button needs to know there is not one.
  ///
  /// In en, this message translates to:
  /// **'The application or invitation it came from has ended, so no new messages can be sent. Everything already here stays readable.'**
  String get chatReadOnlyBody;

  /// Notice heading on a thread the other side blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get chatBlockedTitle;

  /// Says that it applies to both sides, because §9.1 makes a block symmetrical whoever set it — and deliberately offers no action: this block is not the reader's to lift.
  ///
  /// In en, this message translates to:
  /// **'The other person blocked this conversation. Nobody can send here while that stands, and the messages stay readable.'**
  String get chatBlockedBody;

  /// Notice heading on a thread the reader blocked.
  ///
  /// In en, this message translates to:
  /// **'You blocked this conversation'**
  String get chatBlockedByYouTitle;

  /// "Including you" is the part worth saying: somebody reaching for a block often wants a mute, and §9.1 does not have one. It also names where the control is, since the notice deliberately does not carry it — a condition and the thing that clears it are two taps apart everywhere else in this app.
  ///
  /// In en, this message translates to:
  /// **'Neither side can send while the block stands — including you. Unblock from the top of the screen to write again.'**
  String get chatBlockedByYouBody;

  /// Lifts the reader's own block. Offered only where they set it: the route cannot lift the other side's, and a control that looks like it can would be worse than none.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get chatUnblock;

  /// Confirms the block was lifted, and says what changed as a result — "unblocked" alone leaves somebody looking for the composer to find out.
  ///
  /// In en, this message translates to:
  /// **'Unblocked. You can write again.'**
  String get chatUnblocked;

  /// Opens the block sheet, and the verb on its confirm button.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get chatBlockAction;

  /// The block sheet's heading.
  ///
  /// In en, this message translates to:
  /// **'Block this conversation?'**
  String get chatBlockTitle;

  /// States the consequence before the button rather than asking "are you sure?". §9.1's block is symmetrical, and somebody reaching for it is often reaching for a mute — so the sheet says which one this is while there is still time to back out.
  ///
  /// In en, this message translates to:
  /// **'It becomes read-only for both of you — you will not be able to send either. The messages stay readable, and a moderator can review them.'**
  String get chatBlockBody;

  /// Marked optional in the label. It is for the moderator who may review the thread, and requiring a justification from somebody blocking for their own safety gets the wrong answer typed in.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get chatBlockReasonLabel;

  /// Says who reads it, which is the only thing that makes writing one worthwhile.
  ///
  /// In en, this message translates to:
  /// **'For the moderator who reviews this'**
  String get chatBlockReasonHint;

  /// §9.1's report, filed into the same complaint queue M10 reviews vacancy reports through.
  ///
  /// In en, this message translates to:
  /// **'Report this message'**
  String get chatReportTitle;

  /// Sets the expectation that nothing changes on this screen — a report is filed, not applied — and points at the block, because somebody reporting harassment usually wants the messages to stop as well and would otherwise assume reporting did that.
  ///
  /// In en, this message translates to:
  /// **'A moderator reads the report and decides. Blocking the conversation is separate, and you can do both.'**
  String get chatReportBody;

  /// Free text and required. Free because somebody objecting to a message should not have to find their objection on a list; required because the complaint lands in a queue as a row a moderator has to be able to act on.
  ///
  /// In en, this message translates to:
  /// **'What is wrong with it'**
  String get chatReportReasonLabel;

  /// A hint that shows what the field is for by naming a real thing that happens on job platforms. Somebody shown an empty box labelled "reason" writes nothing; somebody shown this writes what actually happened.
  ///
  /// In en, this message translates to:
  /// **'Asked me to pay for the job'**
  String get chatReportReasonHint;

  /// The verb on the confirm button, never "OK".
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get chatReportSubmit;

  /// Confirms the filing and says what happens next, since nothing visible changes: the message stays where it was and the thread stays open, because §9.1 gives the outcome to a moderator rather than to the reporter.
  ///
  /// In en, this message translates to:
  /// **'Report sent. A moderator will review it.'**
  String get chatReportDone;

  /// The composer's persistent label — every control in this design carries one.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatComposerLabel;

  /// The composer's placeholder.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get chatComposerHint;

  /// Sends the message. Inert only while there is nothing to send — never because of a rule about whether this person may chat, which is the server's to apply.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// Heading over the server's own refusal, beside the composer that failed. The sentence underneath is the server's, so there is exactly one wording of each refusal — and the draft is deliberately kept, because somebody who wrote three paragraphs into a thread that closed under them must be able to copy them out.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get chatSendRefusedTitle;

  /// On an outgoing message the other side has not read yet. §9.1 asks for sent / delivered / read and the server sends two of the three: delivery belongs to push (M9), and a flag written in the same statement as the timestamp would be a fabricated answer — so there is no middle state here.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get chatSent;

  /// On an outgoing message the other side has read. Shown on outgoing messages only: on an incoming one the same field answers whether the reader has read it, which they can see for themselves.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get chatRead;

  /// Fetches the page before the oldest message loaded. A control rather than an infinite scroll, so somebody on a metered connection decides when to spend the request.
  ///
  /// In en, this message translates to:
  /// **'Earlier messages'**
  String get chatEarlier;

  /// An open thread with nothing in it — the state right after somebody opened the conversation from a candidate profile.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Write the first one.'**
  String get chatThreadEmpty;

  /// The same emptiness on a thread that can no longer take messages. A different fact and a different sentence: inviting somebody to write the first message where the composer is gone would be an instruction they cannot follow.
  ///
  /// In en, this message translates to:
  /// **'No messages were sent before this conversation closed.'**
  String get chatThreadEmptyClosed;

  /// §9.1's entry point, in the contact block of §7.3's candidate profile — the same entitlement that reveals a phone number is the one that opens chat, from the same service on the server. It sits beside copy rather than replacing it: a message needs the other person to open the app, and a phone number does not.
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get chatOpenAction;

  /// §8.3's object, used as the fallback word for an interview type this build does not recognise. A newer server's fourth type still has a time and a status worth rendering, so the card says what the thing is rather than guessing which detail field to look for.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get interviewTitle;

  /// §8.3: a time has been set and the candidate has not answered. Warning-toned because the tone means "waiting on a person", and that person is whoever is reading it.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get interviewStatusScheduled;

  /// The candidate agreed to the time. Deliberately not an ending: §8.3 lets somebody who confirmed and then found a clash ask for another time, so the word is a good outcome rather than a closed door.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get interviewStatusConfirmed;

  /// The candidate asked for a different time, so it waits on the employer. Kept short because it shares a row with a full date at 320pt: "Another time requested" does not fit and a badge must never be the thing that truncates.
  ///
  /// In en, this message translates to:
  /// **'Another time asked'**
  String get interviewStatusRescheduleRequested;

  /// The employer called it off — §8.3's only ending. Neutral rather than red: a cancelled interview is not a rejected application, and the application carries its own stage.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get interviewStatusCancelled;

  /// §8.3's phone interview. The only type with no detail field of its own, which is why the word matters: without it the card would show a time and nothing else.
  ///
  /// In en, this message translates to:
  /// **'Phone call'**
  String get interviewTypePhone;

  /// §8.3's in-person interview. Carries an address, which the server requires for this type and forbids for the others.
  ///
  /// In en, this message translates to:
  /// **'In person'**
  String get interviewTypeInPerson;

  /// §8.3's external-link interview. "Video link" rather than "online": §2.4 puts a built-in video engine out of scope, so this is somebody else's meeting URL and the word should not imply the app hosts it.
  ///
  /// In en, this message translates to:
  /// **'Video link'**
  String get interviewTypeExternalLink;

  /// Shown on a phone interview because it is the one type with nothing else to show. It also answers the question it raises: BR-01 already verified the number, which is exactly why the employer was never asked to retype it.
  ///
  /// In en, this message translates to:
  /// **'The employer will call the number on your profile.'**
  String get interviewPhoneNote;

  /// Label above an in-person interview's address.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get interviewWhere;

  /// Label above an external-link interview's URL. Copyable rather than tappable: opening it needs url_launcher, and pubspec.yaml's version bounds are load-bearing — the browser takes it from the clipboard, exactly as the dialler takes a phone number.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get interviewLink;

  /// Label above §8.3's "documents or preparation notes". Named for whose words they are, because they are never translated (§2.4) and "bring your diploma" is the sentence that must survive whole.
  ///
  /// In en, this message translates to:
  /// **'From the employer'**
  String get interviewInstructions;

  /// Label above the note the candidate sent with their answer, played back to them.
  ///
  /// In en, this message translates to:
  /// **'Your reply'**
  String get interviewYourReply;

  /// Said rather than hidden: an interview whose time has gone by is still the record of what was arranged, and somebody who missed one needs to see that they did. The actions stay on offer, because the server still accepts them and refusing here would be the client deciding on the employer's behalf that it is too late.
  ///
  /// In en, this message translates to:
  /// **'This time has already passed.'**
  String get interviewPassed;

  /// Names who did it, because §8.3 gives cancelling to the employer alone and a candidate reading "cancelled" would otherwise wonder whether they had done it themselves.
  ///
  /// In en, this message translates to:
  /// **'The employer called this interview off.'**
  String get interviewCancelledNotice;

  /// §8.3's first candidate response. The filled button where it is offered, because it is the answer that lets the interview happen.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get interviewConfirm;

  /// §8.3's second candidate response. A real alternative rather than a lesser one, so it is a secondary button and never hidden — a candidate who cannot make the time must not have to hunt for the way to say so.
  ///
  /// In en, this message translates to:
  /// **'Ask for another time'**
  String get interviewRequestAnother;

  /// The confirm sheet's heading. A question, not "Are you sure?" — and no warning about finality, because confirming is not final: §8.3 lets a candidate who confirms and then finds a clash ask for another time.
  ///
  /// In en, this message translates to:
  /// **'Confirm this time?'**
  String get interviewConfirmTitle;

  /// Says what the employer will see, which is the part the candidate is actually deciding about, and then removes the fear that stops people confirming: the answer is changeable.
  ///
  /// In en, this message translates to:
  /// **'The employer will see that the time suits you. If something changes later you can still ask for another time.'**
  String get interviewConfirmBody;

  /// The reschedule sheet's heading, the same words as the button that opened it.
  ///
  /// In en, this message translates to:
  /// **'Ask for another time'**
  String get interviewRescheduleTitle;

  /// Sets the expectation that asking does not cancel anything — a candidate who thinks it does will not ask, and will miss the interview instead.
  ///
  /// In en, this message translates to:
  /// **'The interview stays booked until the employer sets a new time, and they will see what you write below.'**
  String get interviewRescheduleBody;

  /// Required, though the server takes it as optional. "The candidate wants another time" with no time attached is a message the employer cannot act on, so the interview stalls while each side waits for the other. Same judgement as the invitation sheet's "Request details".
  ///
  /// In en, this message translates to:
  /// **'Which times suit you'**
  String get interviewNoteLabel;

  /// A hint that shows what the field is for. Somebody shown an empty box writes "I can't make it"; somebody shown this writes something the employer can book.
  ///
  /// In en, this message translates to:
  /// **'Any afternoon this week, or Friday morning'**
  String get interviewNoteHint;

  /// Marked optional in the label, because a confirmation owes no explanation and asking for one implies it does.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get interviewReplyNoteLabel;

  /// Shows the field is for a courtesy rather than a justification.
  ///
  /// In en, this message translates to:
  /// **'I will be there ten minutes early'**
  String get interviewReplyNoteHint;

  /// Heading over the server's refusal when the answer no longer applies — `interview.final` after a cancellation, or `interview.response_not_allowed` for saying the same thing twice. Both mean somebody moved first, which is a sentence that belongs beside the button that failed rather than in a toast four seconds later.
  ///
  /// In en, this message translates to:
  /// **'This interview has moved on'**
  String get interviewNotAllowed;

  /// §8.3's employer action, on an applicant row. Offered independently of §8.1's stage: the interview and the stage are separate records, so neither drives the other — scheduling one is usually what happens *before* moving somebody to the interview stage.
  ///
  /// In en, this message translates to:
  /// **'Schedule an interview'**
  String get interviewSchedule;

  /// The scheduling sheet's heading.
  ///
  /// In en, this message translates to:
  /// **'Schedule an interview'**
  String get interviewScheduleTitle;

  /// The verb on the confirm button, named for what actually happens: the candidate sees the interview and is asked to confirm. "Save" would suggest a draft, and §8.3 has none.
  ///
  /// In en, this message translates to:
  /// **'Send to the candidate'**
  String get interviewScheduleSave;

  /// The same form, reached from an existing interview. "Move" rather than "edit", because the field that matters is the time and the candidate has to answer again.
  ///
  /// In en, this message translates to:
  /// **'Move this interview'**
  String get interviewRescheduleFormTitle;

  /// The verb on the confirm button when rescheduling.
  ///
  /// In en, this message translates to:
  /// **'Save the new time'**
  String get interviewRescheduleSave;

  /// The server resets the status to `scheduled` on every edit, and it is right to: a confirmation belongs to the time it was given for. But an employer nudging the time by ten minutes needs to know it costs them a confirmation, or they will do it and wonder why the badge changed.
  ///
  /// In en, this message translates to:
  /// **'The candidate will be asked to confirm again, even for a small change — an interview moved to another time has not been confirmed.'**
  String get interviewRescheduleResets;

  /// Label above the three type options. Radio rows rather than a segmented control: three segments at 360pt give each about 110pt, and "Личная встреча" does not fit that on one line — the same measurement that kept §8.2's status filters off HhSegmented.
  ///
  /// In en, this message translates to:
  /// **'Kind of interview'**
  String get interviewTypeLabel;

  /// A hint that shows what the field is *for*: an address alone leaves a candidate standing in a lobby. Required for an in-person interview and forbidden for the other two, which the server enforces both ways.
  ///
  /// In en, this message translates to:
  /// **'Amir Temur 12, 3rd floor — ask for Dilnoza at reception'**
  String get interviewWhereHint;

  /// Somebody else's meeting URL — §2.4 puts a built-in video engine out of scope. Required for a video-link interview and forbidden for the other two.
  ///
  /// In en, this message translates to:
  /// **'https://meet.example.com/abc-defg-hij'**
  String get interviewLinkHint;

  /// Label on the date picker. ISO on the wire, because §8.3's display policy for dates is still open and a format invented here would have to be undone.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get interviewDateLabel;

  /// Label on the time picker. The picked time means the **platform's** clock, which is the clock the candidate's card renders — the only reading on which the two sides agree.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get interviewTimeLabel;

  /// Twenty-four hour, as everywhere else in the app: none of the four interface variants uses an am/pm convention.
  ///
  /// In en, this message translates to:
  /// **'10:00'**
  String get interviewTimeHint;

  /// §8.3's "documents or preparation notes", labelled as the question it answers rather than as the field name. Optional, and shown to the candidate in the employer's own words — never translated (§2.4).
  ///
  /// In en, this message translates to:
  /// **'Anything they should bring or prepare'**
  String get interviewInstructionsLabel;

  /// The example that makes the field obvious. An employer shown an empty box labelled "instructions" writes nothing.
  ///
  /// In en, this message translates to:
  /// **'Bring your diploma and your work record book'**
  String get interviewInstructionsHint;

  /// Opens the form on an existing interview. Absent on a cancelled one: §8.3's only ending is cancellation, and rescheduling one would be reviving it — which the server refuses with `interview.final`.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get interviewReschedule;

  /// §8.3's employer-only ending, and the verb on the confirm button. Not "cancel", which is also the word on the button that closes the sheet without doing anything.
  ///
  /// In en, this message translates to:
  /// **'Call it off'**
  String get interviewCancelAction;

  /// The cancellation sheet's heading.
  ///
  /// In en, this message translates to:
  /// **'Call off this interview?'**
  String get interviewCancelTitle;

  /// Names the consequence rather than asking "are you sure?". Cancelling is §8.3's only ending and nothing undoes it, so the sheet says both halves of that: it is final, and a replacement is a new record.
  ///
  /// In en, this message translates to:
  /// **'This is final for both sides — the interview cannot be brought back, and a new time means scheduling a new one. The candidate will see that it was called off.'**
  String get interviewCancelBody;

  /// The parenthesis is the load-bearing part. The reason is shown to the candidate, and an employer writing "found someone closer" for their own records would be writing it to the person it is about.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional, the candidate sees it)'**
  String get interviewCancelReasonLabel;

  /// Shows the field is addressed to the candidate, by giving an example somebody would be willing to read.
  ///
  /// In en, this message translates to:
  /// **'The role has been filled — thank you for your time'**
  String get interviewCancelReasonHint;

  /// Label above the note the candidate sent with their answer, on the employer's side. Their own words (§2.4) — and the point of the whole feature, because "another time please" is useless without the times.
  ///
  /// In en, this message translates to:
  /// **'What the candidate said'**
  String get interviewCandidateReply;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'uz':
      {
        switch (locale.scriptCode) {
          case 'Cyrl':
            return AppL10nUzCyrl();
          case 'Latn':
            return AppL10nUzLatn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'ru':
      return AppL10nRu();
    case 'uz':
      return AppL10nUz();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
