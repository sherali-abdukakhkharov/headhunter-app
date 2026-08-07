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
  /// **'HeadHunter'**
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
