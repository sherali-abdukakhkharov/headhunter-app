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

  /// Heading of the sign-in screen (§4.1).
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTitle;

  /// The primary sign-in action. 'Telegram' is a product name and stays untranslated in every locale, including the Cyrillic ones.
  ///
  /// In en, this message translates to:
  /// **'Log in with Telegram'**
  String get authTelegramSignIn;

  /// §4.1 step 2. Consent must be given before sign-in, and it is not optional - the button stays disabled until this is checked. Telegram does not collect this for us.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Service and the Privacy Policy'**
  String get authTermsAgree;

  /// Telegram or its SDK failed for a reason the user cannot act on beyond retrying. Deliberately does not expose the SDK's own English error text.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Telegram. Please try again.'**
  String get authSignInFailed;

  /// Network failure while contacting Telegram, as distinct from our own server being unreachable - the user can act on this one.
  ///
  /// In en, this message translates to:
  /// **'No connection to Telegram. Check your internet and try again.'**
  String get authSignInNoConnection;

  /// This build's application id has no redirect URI registered with BotFather, so a login cannot start. Should never reach a real user; shown instead of failing silently.
  ///
  /// In en, this message translates to:
  /// **'Telegram sign-in is not available in this build.'**
  String get authSignInUnavailable;
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
