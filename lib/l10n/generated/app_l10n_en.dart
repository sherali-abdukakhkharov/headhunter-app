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
  String profileLastUpdated(String date) {
    return 'Last updated $date';
  }

  @override
  String get profileFixField => 'Fill in';

  @override
  String get profileVisibilityTitle => 'Who can find you';

  @override
  String get profileVisibilitySearchable => 'Visible in search';

  @override
  String get profileVisibilitySearchableHint =>
      'Employers can find you in candidate search.';

  @override
  String get profileVisibilityHidden => 'Hidden from search';

  @override
  String get profileVisibilityHiddenHint =>
      'You can still browse vacancies and apply. Employers cannot find you.';

  @override
  String get profileVisibilityAfterApply => 'Visible after I apply';

  @override
  String get profileVisibilityAfterApplyHint =>
      'Only employers whose vacancy you applied to can see your profile.';

  @override
  String get vacancyMine => 'Your vacancies';

  @override
  String get vacancyNew => 'New vacancy';

  @override
  String get vacancyNone => 'No vacancies yet';

  @override
  String get vacancyUntitled => 'Untitled vacancy';

  @override
  String get vacancyStatusDraft => 'Draft';

  @override
  String get vacancyStatusModeration => 'Under review';

  @override
  String get vacancyStatusActive => 'Published';

  @override
  String get vacancyStatusPaused => 'Paused';

  @override
  String get vacancyStatusClosed => 'Closed';

  @override
  String get vacancyStatusRejected => 'Rejected';

  @override
  String get vacancySubmit => 'Submit for publication';

  @override
  String get vacancyPause => 'Pause';

  @override
  String get vacancyResume => 'Resume';

  @override
  String get vacancyClose => 'Close';

  @override
  String get vacancyCloseTitle => 'Close this vacancy?';

  @override
  String get vacancyCloseMessage =>
      'Closing is permanent. The vacancy leaves search and stays in your history.';

  @override
  String vacancyMissingForSubmit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields to fill before publishing',
      one: '$count field to fill before publishing',
    );
    return '$_temp0';
  }

  @override
  String get vacancyNotEditable => 'This vacancy cannot be edited right now.';

  @override
  String get vacancyOpenForApplications => 'Accepting applications';

  @override
  String get vacancyRestrictionTitle => 'Age and gender restrictions';

  @override
  String get vacancyRestrictionWarning =>
      'Age and gender restrictions need a justification and are always reviewed by a moderator.';

  @override
  String get employerChooseType => 'What kind of employer are you?';

  @override
  String get employerTypeCompany => 'A company';

  @override
  String get employerTypeCompanyHint =>
      'Registered business hiring under a company name.';

  @override
  String get employerTypeIndividual => 'An individual';

  @override
  String get employerTypeIndividualHint =>
      'Hiring for your own household or private work.';

  @override
  String get employerTypeFixed => 'Chosen once and cannot be changed later.';

  @override
  String get employerDetails => 'Employer details';

  @override
  String get employerLegalName => 'Registered name';

  @override
  String get employerPublicName => 'Name shown to candidates';

  @override
  String get employerFullName => 'Your full name';

  @override
  String get employerIndustry => 'Industry';

  @override
  String get employerContactPerson => 'Contact person';

  @override
  String get employerContactPhone => 'Contact phone';

  @override
  String get employerRegion => 'Region';

  @override
  String get employerDistrict => 'District or city';

  @override
  String get employerAddress => 'Address';

  @override
  String get employerDescription => 'Description';

  @override
  String get employerVerification => 'Verification';

  @override
  String get employerVerificationNotSubmitted => 'Not submitted';

  @override
  String get employerVerificationUnderReview => 'Under review';

  @override
  String get employerVerificationVerified => 'Verified';

  @override
  String get employerVerificationRejected => 'Rejected';

  @override
  String get employerVerificationChangesRequired => 'Changes required';

  @override
  String get employerSubmitVerification => 'Submit for verification';

  @override
  String get employerEvidence => 'Documents to provide';

  @override
  String get employerEvidenceRequired => 'Required';

  @override
  String get employerEvidenceOptional => 'Optional';

  @override
  String get employerCannotPublish =>
      'Complete your profile and get verified before posting a vacancy or inviting a candidate.';

  @override
  String get employerCanPublish =>
      'You can post vacancies and invite candidates.';

  @override
  String get employerSaveFirst =>
      'Save your details before submitting for verification.';

  @override
  String get attachmentsTitle => 'Documents';

  @override
  String get attachmentUpload => 'Upload';

  @override
  String get attachmentReplace => 'Replace';

  @override
  String attachmentUploading(String percent) {
    return 'Uploading… $percent%';
  }

  @override
  String get attachmentNone => 'Nothing uploaded yet';

  @override
  String attachmentTooLarge(String limit) {
    return 'That file is larger than $limit MB.';
  }

  @override
  String attachmentWrongType(String types) {
    return 'Choose a $types file.';
  }

  @override
  String get attachmentDeleteTitle => 'Delete this file?';

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
