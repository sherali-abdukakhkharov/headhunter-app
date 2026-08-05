// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HeadHunter';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get stateLoading => 'Loading…';

  @override
  String get stateEmptyTitle => 'Nothing here yet';

  @override
  String get stateEmptyBody => 'There is nothing to show on this screen yet.';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateErrorBody =>
      'The request could not be completed. Please try again.';

  @override
  String get stateOfflineTitle => 'No connection';

  @override
  String get stateOfflineBody => 'Check your connection and try again.';

  @override
  String get statePermissionDeniedTitle => 'Permission needed';

  @override
  String get statePermissionDeniedBody =>
      'Grant permission in Settings to continue.';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get roleCandidate => 'Candidate';

  @override
  String get roleEmployer => 'Employer';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get navHome => 'Home';

  @override
  String get navVacancies => 'Vacancies';

  @override
  String get navApplications => 'Applications';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profile';

  @override
  String get navCandidates => 'Candidates';

  @override
  String get navCompany => 'Company';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navQueue => 'Moderation';

  @override
  String get navComplaints => 'Complaints';

  @override
  String get navUsers => 'Users';

  @override
  String get navDictionaries => 'Dictionaries';

  @override
  String get blockedTitle => 'Account blocked';

  @override
  String get blockedBody =>
      'An administrator has blocked this account. You cannot use the app until the block is lifted.';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authPhoneHint => '90 123 45 67';

  @override
  String get authPhoneInvalid =>
      'Enter a 9-digit number, for example 90 123 45 67.';

  @override
  String get authSendCode => 'Get a code';

  @override
  String get authCodeTitle => 'Enter the code';

  @override
  String authCodeSentTo(String phone) {
    return 'We sent a code to $phone.';
  }

  @override
  String get authCodeLabel => 'Code';

  @override
  String authCodeInvalid(int length) {
    return 'Enter the $length-digit code.';
  }

  @override
  String get authVerifyCode => 'Confirm';

  @override
  String get authChangePhone => 'Change number';

  @override
  String get authResendCode => 'Send again';

  @override
  String authResendIn(int seconds) {
    return 'Send again in $seconds s';
  }

  @override
  String get authCodeResent => 'A new code is on its way.';

  @override
  String get authTelegramSignIn => 'Log in with Telegram';

  @override
  String get authTermsAgree =>
      'I accept the Terms of Service and the Privacy Policy';

  @override
  String get authSignInFailed =>
      'Could not sign in with Telegram. Please try again.';

  @override
  String get authSignInNoConnection =>
      'No connection to Telegram. Check your internet and try again.';

  @override
  String get authSignInUnavailable =>
      'Telegram sign-in is not available in this build.';
}
