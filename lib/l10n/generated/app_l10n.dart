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

  /// Adds the candidate to a vacancy’s shortlist (§7.3).
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get searchShortlist;

  /// Already on the shortlist; tapping removes.
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

  /// Shown when an employer taps a candidate attachment they are entitled to. BR-09 has granted the file and the server serves it at the file's own `downloadPath`; what is missing is the client, which has no way to open a downloaded file without a plugin the team has deliberately not added. Says so rather than doing nothing, the same way section 6.7's top-up does — a row that looks like a file and answers nothing reads as a broken app.
  ///
  /// In en, this message translates to:
  /// **'Opening attachments is not available in the app yet.'**
  String get candidateFileDownloadSoon;
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
