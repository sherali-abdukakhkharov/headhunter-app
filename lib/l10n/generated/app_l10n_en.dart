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
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

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
  String get profileCompleteness => 'Profile completeness';

  @override
  String profileMissingRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count required fields left',
      one: '$count required field left',
    );
    return '$_temp0';
  }

  @override
  String get profileSearchable => 'Visible in search';

  @override
  String get profileNotSearchable => 'Not yet in search';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileSectionElsewhere =>
      'This section has its own editor and is not part of this build yet.';

  @override
  String get profileFieldNotEditableYet =>
      'This field is not editable in this version of the app.';

  @override
  String get profileChooseParentFirst => 'Choose the field above first';

  @override
  String get profileDateHint => 'YYYY-MM-DD';

  @override
  String get profileSalaryFrom => 'From';

  @override
  String get profileSalaryTo => 'To';

  @override
  String get profileSalaryNegotiable => 'Negotiable';

  @override
  String get historyDeleteTitle => 'Delete this entry?';

  @override
  String get historyDeleteMessage => 'It will be removed from your profile.';

  @override
  String get experienceEmpty => 'No work experience yet';

  @override
  String get experienceAdd => 'Add experience';

  @override
  String get experienceEmployer => 'Employer';

  @override
  String get experienceRole => 'Position';

  @override
  String get experienceOccupation => 'Occupation';

  @override
  String get experienceStarted => 'Start date';

  @override
  String get experienceEnded => 'End date';

  @override
  String get experienceCurrent => 'I work here now';

  @override
  String get experienceResponsibilities => 'Responsibilities';

  @override
  String get experiencePresent => 'Present';

  @override
  String get educationEmpty => 'No education yet';

  @override
  String get educationAdd => 'Add education';

  @override
  String get educationLevel => 'Level of education';

  @override
  String get educationInstitution => 'Institution';

  @override
  String get educationSpecialization => 'Specialization';

  @override
  String get educationYear => 'Graduation year';

  @override
  String get leveledChangeLevel => 'Level';

  @override
  String get pickerChoose => 'Choose';

  @override
  String get pickerAdd => 'Add';

  @override
  String get pickerSearchHint => 'Start typing to filter';

  @override
  String get pickerNoMatches => 'Nothing matches that search.';

  @override
  String get pickerNothingSelected => 'Nothing selected yet';

  @override
  String get pickerUnknownValue => 'Unavailable value';

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
