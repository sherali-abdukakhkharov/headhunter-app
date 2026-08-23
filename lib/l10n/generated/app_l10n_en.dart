// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'JobBridge';

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
  String get feedRecommended => 'Recommended';

  @override
  String get feedRecent => 'Recent';

  @override
  String get feedSaved => 'Saved';

  @override
  String get feedEmpty => 'No vacancies to show yet';

  @override
  String get vacancyVerifiedEmployer => 'Verified employer';

  @override
  String get vacancyNegotiablePay => 'Pay negotiable';

  @override
  String vacancyDeadline(String date) {
    return 'Apply by $date';
  }

  @override
  String get vacancyApply => 'Apply';

  @override
  String get vacancyApplied => 'Applied';

  @override
  String get vacancyClosedToApplications => 'Not accepting applications';

  @override
  String get vacancySave => 'Save';

  @override
  String get vacancySaved => 'Saved';

  @override
  String get vacancyReport => 'Report';

  @override
  String get vacancyReportTitle => 'Report this vacancy';

  @override
  String get vacancyReportHint => 'What is wrong with it?';

  @override
  String get vacancyReported => 'Thank you. A moderator will review it.';

  @override
  String get applicationsMine => 'Your applications';

  @override
  String get applicationsEmpty => 'You have not applied to anything yet';

  @override
  String get applicationWithdraw => 'Withdraw';

  @override
  String get applicationWithdrawTitle => 'Withdraw this application?';

  @override
  String get stageSubmitted => 'Submitted';

  @override
  String get stageViewed => 'Viewed';

  @override
  String get stageShortlisted => 'Shortlisted';

  @override
  String get stageInterview => 'Interview';

  @override
  String get stageOffer => 'Offer';

  @override
  String get stageHired => 'Hired';

  @override
  String get stageRejected => 'Not selected';

  @override
  String get stageWithdrawn => 'Withdrawn';

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

  @override
  String get vacancyApplicants => 'Applicants';

  @override
  String get vacancyApplicantsEmpty => 'No applications yet';

  @override
  String applicationsHired(int hired, int required) {
    return '$hired of $required hired';
  }

  @override
  String applicationsHiredNoTarget(int hired) {
    return '$hired hired';
  }

  @override
  String get applicationMoveTo => 'Move to';

  @override
  String get applicationRejectReason => 'Reason (shown to the candidate)';

  @override
  String get candidatePhoneHidden => 'Phone not available';

  @override
  String get candidatePhoneHiddenWhy =>
      'The candidate’s privacy settings decide when an employer can see it.';

  @override
  String get candidateFilesHidden => 'Files not available';

  @override
  String candidateCompleteness(int percent) {
    return 'Profile $percent% complete';
  }

  @override
  String get notesTitle => 'Private notes';

  @override
  String get notesHint => 'Only you can see these';

  @override
  String get notesAdd => 'Add note';

  @override
  String get searchCandidates => 'Find candidates';

  @override
  String get searchRun => 'Search';

  @override
  String searchCountExact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidates',
      one: '$count candidate',
    );
    return '$_temp0';
  }

  @override
  String searchCountCapped(int count) {
    return '$count+ candidates';
  }

  @override
  String get searchNoResults => 'No candidates match these filters';

  @override
  String get searchSaved => 'Saved candidates';

  @override
  String searchMatch(int percent) {
    return '$percent% match';
  }

  @override
  String searchExperienceYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years of experience',
      one: '$years year of experience',
    );
    return '$_temp0';
  }

  @override
  String get searchShortlist => 'Add to shortlist';

  @override
  String get searchShortlisted => 'Shortlisted';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filtersApply => 'Apply filters';

  @override
  String get filtersReset => 'Reset';

  @override
  String get filtersEdit => 'Filters';

  @override
  String get filtersClearAll => 'Clear all';

  @override
  String get filtersNone => 'No filters — every searchable candidate';

  @override
  String get filtersBlockedTitle => 'Cannot search yet';

  @override
  String get filtersOccupation => 'Occupation';

  @override
  String get filtersSkills => 'Skills';

  @override
  String get filtersExperience => 'Experience';

  @override
  String get filtersLanguages => 'Languages';

  @override
  String get filtersEducation => 'Education';

  @override
  String get filtersLocation => 'Location';

  @override
  String get filtersPreferences => 'Work preferences';

  @override
  String get filtersAvailability => 'Availability';

  @override
  String get filtersAttributes => 'Additional requirements';

  @override
  String get filtersProfile => 'Profile';

  @override
  String get filtersRestrictions => 'Restrictions';

  @override
  String get filtersSort => 'Sort by';

  @override
  String get filterOccupations => 'Occupations';

  @override
  String get filterPrimaryOnly => 'Primary occupation only';

  @override
  String get filterPrimaryOnlyHint =>
      'Match the candidate’s main occupation, not every one they listed';

  @override
  String get filterOccupationLevels => 'Professional level';

  @override
  String get filterCurrentOccupations => 'Current or last role';

  @override
  String get filterSkills => 'Skills';

  @override
  String get filterMatchMode => 'Match';

  @override
  String get filterMatchAny => 'Any';

  @override
  String get filterMatchAll => 'All';

  @override
  String get filterMinLevel => 'Minimum level';

  @override
  String get filterLevelAny => 'Any level';

  @override
  String get filterExperienceYearsMin => 'Total years, minimum';

  @override
  String get filterOccupationExperience => 'Years in this occupation, minimum';

  @override
  String get filterOccupationExperienceNeedsOccupation =>
      'Choose an occupation first';

  @override
  String get filterLanguages => 'Languages';

  @override
  String get filterLanguageCertificate => 'Certificate required';

  @override
  String get filterEducationLevels => 'Education level';

  @override
  String get filterSpecializations => 'Specialization';

  @override
  String get filterRegion => 'Region';

  @override
  String get filterDistricts => 'Districts';

  @override
  String get filterDistrictsNeedRegion => 'Choose a region first';

  @override
  String get filterWillingToRelocate => 'Willing to relocate';

  @override
  String get filterWillingToTravel => 'Ready to travel';

  @override
  String get filterProximityDistrict => 'Near this district';

  @override
  String get filterProximityHint => 'Used by the “Nearest” sort';

  @override
  String get filterEmploymentTypes => 'Employment type';

  @override
  String get filterWorkFormats => 'Work format';

  @override
  String get filterShifts => 'Shift';

  @override
  String get filterSalaryMin => 'Salary from';

  @override
  String get filterSalaryMax => 'Salary up to';

  @override
  String get filterSalaryMaxHint =>
      'A candidate expecting more is excluded. A negotiable expectation still matches.';

  @override
  String get filterAvailableBy => 'Available by';

  @override
  String get filterAvailableImmediately => 'Available immediately';

  @override
  String get filterAttributes => 'Licences, transport and tools';

  @override
  String get filterCrewSizeMin => 'Can bring a crew of at least';

  @override
  String get filterMinCompleteness => 'Profile completeness, minimum (%)';

  @override
  String get filterUpdatedSince => 'Updated since';

  @override
  String get filterAgeMin => 'Age from';

  @override
  String get filterAgeMax => 'Age to';

  @override
  String get filterGender => 'Gender';

  @override
  String get filterJustification => 'Reason for the restriction';

  @override
  String get filterRestrictionRequired =>
      'An age or gender filter needs a declared reason. Every use is logged.';

  @override
  String get filterRestrictionExplain =>
      'Only where the job genuinely requires it.';

  @override
  String get sortMatch => 'Best match';

  @override
  String get sortRecent => 'Recently updated';

  @override
  String get sortExperience => 'Most experience';

  @override
  String get sortSalary => 'Lowest expectation';

  @override
  String get sortProximity => 'Nearest';

  @override
  String get commonLoadMore => 'Load more';

  @override
  String filterChipCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String filterChipValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get searchFromVacancy => 'Find candidates';

  @override
  String get searchScopedToVacancy => 'Filters came from a vacancy';

  @override
  String get candidateProfileTitle => 'Candidate';

  @override
  String get candidateViewProfile => 'View profile';

  @override
  String get candidateContact => 'Contact';

  @override
  String candidateAvailableFrom(String date) {
    return 'Available from $date';
  }

  @override
  String get candidateAttachments => 'Attachments';

  @override
  String get candidateNoFiles => 'This candidate has not uploaded anything';

  @override
  String get candidatePhoneNotOnFile =>
      'This candidate has no phone number on file.';

  @override
  String get candidateExposureNotVerified =>
      'Contact details open once your company is verified.';

  @override
  String get candidateExposureNoInteraction =>
      'Contact details open once this candidate applies to one of your vacancies, or accepts an invitation.';

  @override
  String get candidateExposureHidden =>
      'This candidate has hidden their profile from search. They can still see your vacancies and apply.';

  @override
  String get searchSavedEmpty => 'No saved candidates';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonCopied => 'Copied';

  @override
  String get vacancyDetailTitle => 'Vacancy';

  @override
  String get vacancyDescription => 'About the job';

  @override
  String get vacancyRequirements => 'Requirements';

  @override
  String get vacancyMandatory => 'Required';

  @override
  String get vacancyPreferred => 'Preferred';

  @override
  String get vacancyGoneTitle => 'This vacancy is no longer available';

  @override
  String get vacancyGoneBody =>
      'It may have been filled, closed, or its deadline may have passed.';

  @override
  String get vacancyReportReason => 'What is wrong with this vacancy?';

  @override
  String get vacancyReportSend => 'Send report';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String vacancyOpenings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count openings',
      one: '$count opening',
    );
    return '$_temp0';
  }

  @override
  String vacancyWorkWindow(String start, String end) {
    return '$start – $end';
  }

  @override
  String vacancyStartsOn(String date) {
    return 'From $date';
  }

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletBalanceLabel => 'Balance';

  @override
  String walletCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coins',
      one: '$count Coin',
    );
    return '$_temp0';
  }

  @override
  String walletApproxUzs(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '≈ $amountString UZS';
  }

  @override
  String walletUzs(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '$amountString UZS';
  }

  @override
  String get walletPrices => 'Prices today';

  @override
  String get walletCoinPriceLabel => '1 Coin';

  @override
  String get walletUnlockPriceLabel => 'Candidate unlock';

  @override
  String walletRegistrationBonusOn(String date) {
    return 'Registration bonus granted $date';
  }

  @override
  String get walletTopUp => 'Top up';

  @override
  String get walletTopUpUnavailable =>
      'Top-up is not available yet. It arrives with Payme and CLICK support.';

  @override
  String get walletActivity => 'Recent activity';

  @override
  String get walletActivityEmpty =>
      'Nothing has moved in this wallet yet. Credits and unlocks both appear here, and neither is ever removed.';

  @override
  String walletBalanceAfter(int count) {
    return 'Balance $count';
  }

  @override
  String walletAmountCredit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coins',
      one: '$count Coin',
    );
    return '+$_temp0';
  }

  @override
  String walletAmountDebit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Coins',
      one: '$count Coin',
    );
    return '−$_temp0';
  }

  @override
  String get walletKindRegistrationBonus => 'Registration bonus';

  @override
  String get walletKindTopUp => 'Top-up';

  @override
  String get walletKindCandidateUnlock => 'Candidate unlock';

  @override
  String get walletKindAdminAdjustment => 'Administrator adjustment';

  @override
  String get walletKindReversal => 'Reversal';

  @override
  String get walletKindOther => 'Wallet activity';

  @override
  String get walletCorrection => 'Correction';

  @override
  String get walletBalanceUnavailable => 'Balance unavailable';

  @override
  String unlockContact(String coins) {
    return 'Unlock contact — $coins';
  }

  @override
  String get unlockTitle => 'Unlock contact';

  @override
  String get unlockCost => 'Cost';

  @override
  String get unlockBalanceNow => 'Your balance';

  @override
  String get unlockBalanceAfter => 'Balance after';

  @override
  String get unlockConfirm => 'Confirm';

  @override
  String get unlockWhatYouGet =>
      'Phone number, e-mail and CV become available, and you can start a conversation. Charged once — returning to this candidate later is free.';

  @override
  String get unlockDone => 'Contact unlocked';

  @override
  String get unlockAlready => 'Already unlocked — nothing was charged';

  @override
  String unlockUnlockedOn(String date) {
    return 'Unlocked $date';
  }

  @override
  String get unlockTopUpNeeded => 'Top up to unlock';

  @override
  String get candidateExposureUnlockRequired =>
      'Unlock contact to reach this candidate now. It also opens free if they apply to one of your vacancies, or accept an invitation.';

  @override
  String get contactLockedTitle => 'Protected information';

  @override
  String get contactUnlockedTitle => 'Contact details';

  @override
  String get contactPhone => 'Phone number';

  @override
  String get contactEmail => 'E-mail';

  @override
  String get contactCv => 'CV file';

  @override
  String get contactCvLocked => 'PDF · locked';

  @override
  String contactLockedExplainer(String coins) {
    return '$coins opens one new candidate\'s phone, e-mail, CV and conversation. An unlocked candidate is never charged for again.';
  }

  @override
  String get unlockGoToVerification => 'Go to verification';

  @override
  String unlockChargedDetail(String coins, String balance) {
    return '$coins spent · balance $balance';
  }

  @override
  String get unlockInsufficient => 'Not enough Coins';

  @override
  String walletValueAndPrice(int value, int price) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);
    final intl.NumberFormat priceNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String priceString = priceNumberFormat.format(price);

    return '≈ $valueString UZS · 1 Coin = $priceString UZS';
  }

  @override
  String walletCoinRule(String coins) {
    return '$coins unlocks one new candidate\'s contact. Searching candidates and viewing profiles is free.';
  }

  @override
  String get walletHistoryTitle => 'Activity history';

  @override
  String get walletHistoryAll => 'All';

  @override
  String get walletHistoryIncoming => 'Topped up';

  @override
  String get walletHistoryOutgoing => 'Spent';

  @override
  String get walletHistoryNoMatch =>
      'No activity of this kind yet. Clear the filter to see everything the wallet has recorded.';

  @override
  String get walletDetailTitle => 'Activity detail';

  @override
  String get walletDetailSection => 'Detail';

  @override
  String get walletDetailReason => 'Reason';

  @override
  String get walletDetailWhen => 'Date and time';

  @override
  String get walletDetailAmountUzs => 'Amount paid';

  @override
  String get walletDetailEffect => 'Effect on balance';

  @override
  String get walletDetailBalanceAfter => 'Balance after';

  @override
  String get walletDetailReference => 'Reference number';

  @override
  String get walletDetailSupportTitle => 'Something wrong with this entry?';

  @override
  String get walletDetailSupport =>
      'Contact support and quote the reference number above. Nothing in this history can be edited or deleted, so the record you are looking at is the record they will see.';

  @override
  String get walletCorrectionExplained =>
      'This entry corrects an earlier one. The original stays in the history — corrections are added, never written over.';

  @override
  String get navInvitations => 'Invitations';

  @override
  String get invitationSent => 'Sent';

  @override
  String get invitationDetailsRequested => 'Details requested';

  @override
  String get invitationAccepted => 'Accepted';

  @override
  String get invitationDeclined => 'Declined';

  @override
  String get invitationAccept => 'Accept';

  @override
  String get invitationDecline => 'Decline';

  @override
  String get invitationRequestDetails => 'Ask a question';

  @override
  String get invitationsInboxEmpty =>
      'Employers who invite you to a vacancy will appear here.';

  @override
  String get invitationGeneral => 'General invitation';

  @override
  String get invitationOpenVacancy => 'Open vacancy';

  @override
  String get invitationVacancyLoading => 'Loading the vacancy…';

  @override
  String get invitationVacancyUnavailable => 'The vacancy could not be loaded.';

  @override
  String get invitationVacancyUntitled => 'Vacancy';

  @override
  String get invitationYourReply => 'Your reply';

  @override
  String invitationPayRange(int from, int to) {
    final intl.NumberFormat fromNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String fromString = fromNumberFormat.format(from);
    final intl.NumberFormat toNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String toString = toNumberFormat.format(to);

    return '$fromString – $toString UZS';
  }

  @override
  String invitationPayFrom(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return 'From $amountString UZS';
  }

  @override
  String invitationPayUpTo(int amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return 'Up to $amountString UZS';
  }

  @override
  String get invitationAcceptTitle => 'Accept this invitation?';

  @override
  String get invitationAcceptDiscloses =>
      'Accepting shares your phone number, e-mail address and CV with this employer, and cannot be undone.';

  @override
  String get invitationDeclineTitle => 'Decline this invitation?';

  @override
  String get invitationDeclineFinal =>
      'Your contact details stay private. Declining is final, but the employer may invite you again later.';

  @override
  String get invitationRequestDetailsTitle => 'Ask the employer a question';

  @override
  String get invitationRequestDetailsBody =>
      'You can still accept or decline afterwards. Your contact details stay private until you accept.';

  @override
  String get invitationQuestionLabel => 'Your question';

  @override
  String get invitationQuestionHint =>
      'For example: where exactly is the work, and when does it start?';

  @override
  String get invitationNoteLabel => 'Message (optional)';

  @override
  String get invitationNoteHint =>
      'Anything you would like the employer to know.';

  @override
  String get invitationAlreadyAnswered =>
      'This invitation has already been answered';

  @override
  String get commonChoose => 'Choose';

  @override
  String get invitationSendTitle => 'Send invitation';

  @override
  String get invitationSend => 'Send';

  @override
  String get invitationSendFree =>
      'Sending is free. Contact details open only if the candidate accepts.';

  @override
  String get invitationToVacancy => 'To a vacancy';

  @override
  String get invitationVacancyLabel => 'Choose a vacancy';

  @override
  String get invitationNoOpenVacancyTitle => 'No open vacancies';

  @override
  String get invitationNoOpenVacancyBody =>
      'An invitation can only point at an active vacancy. You can still send a general work invitation.';

  @override
  String get invitationOccupation => 'Occupation';

  @override
  String get invitationRegion => 'Region';

  @override
  String get invitationDistrict => 'District';

  @override
  String get invitationNegotiable => 'Pay is negotiable';

  @override
  String get invitationSalaryFrom => 'Pay from';

  @override
  String get invitationSalaryTo => 'Pay to';

  @override
  String get invitationSalaryPeriod => 'Per';

  @override
  String get invitationSchedule => 'Schedule';

  @override
  String get invitationScheduleHint => 'For example: six days a week, mornings';

  @override
  String get invitationMessageLabel => 'Message (optional)';

  @override
  String get invitationMessageHint =>
      'What you would like the candidate to know';

  @override
  String invitationQuotaRemaining(int remaining, int limit) {
    return '$remaining of $limit invitations left today';
  }

  @override
  String invitationQuotaResets(String at) {
    return 'Resets at $at';
  }

  @override
  String get invitationQuotaSpentTitle => 'Today’s invitations are used up';

  @override
  String get invitationAlreadySentTitle => 'Already invited';

  @override
  String get invitationSentConfirm => 'Invitation sent';

  @override
  String get invitationsSentTitle => 'Invitations sent';

  @override
  String get invitationsSentEmpty => 'Candidates you invite will appear here.';

  @override
  String get invitationsSentNoMatch =>
      'No invitations with this status. Clear the filter to see everything you have sent.';

  @override
  String get invitationsSentForVacancy => 'This vacancy only';

  @override
  String get invitationFilterAll => 'All';

  @override
  String get invitationYourMessage => 'What you wrote';

  @override
  String get invitationCandidateReply => 'Candidate\'s reply';

  @override
  String get invitationContactOpenTitle => 'Contact is open';

  @override
  String get invitationContactOpenBody =>
      'The candidate accepted, so their phone, e-mail and CV are on their profile. No unlock needed.';

  @override
  String get invitationOpenCandidate => 'View candidate';

  @override
  String invitationCounts(int invited, int accepted) {
    return '$invited invited, $accepted accepted';
  }

  @override
  String get fileNoViewer => 'No app on this phone can open this file.';

  @override
  String get dashboardActiveVacancies => 'Active vacancies';

  @override
  String get dashboardOpenPositions => 'Open positions';

  @override
  String get dashboardNewApplications => 'New applications';

  @override
  String get dashboardAttention => 'Needs your attention';

  @override
  String get dashboardAttentionClear => 'Nothing is waiting on you.';

  @override
  String get dashboardVerificationTitle => 'Verification is not complete';

  @override
  String get dashboardVacancyRejected => 'Changes are required';

  @override
  String dashboardUnreviewed(int count) {
    return '$count applications not yet reviewed';
  }

  @override
  String dashboardSavedCandidates(int count) {
    return '$count saved candidates';
  }

  @override
  String get dashboardHiring => 'Hiring progress';

  @override
  String dashboardHiredOf(int hired, int openings) {
    return '$hired of $openings';
  }

  @override
  String dashboardMeterHired(int count) {
    return 'Hired $count';
  }

  @override
  String dashboardMeterInvited(int count) {
    return 'Invited $count';
  }

  @override
  String dashboardMeterRemaining(int count) {
    return 'Remaining $count';
  }

  @override
  String get dashboardWallet => 'Wallet';

  @override
  String get accountTitle => 'Account and security';

  @override
  String get accountDevices => 'Signed-in devices';

  @override
  String get accountDevicesBody =>
      'If you see a device you do not recognise, end its session.';

  @override
  String get accountDeviceUnknown => 'Unnamed device';

  @override
  String accountLastUsed(String at) {
    return 'Last used $at';
  }

  @override
  String get accountThisDevice => 'This device';

  @override
  String get accountRevoke => 'End session';

  @override
  String get accountRevokeTitle => 'End this session?';

  @override
  String get accountRevokeBody => 'That device will have to sign in again.';

  @override
  String get accountRevokeCurrentTitle => 'Sign out of this device?';

  @override
  String get accountRevokeCurrentBody =>
      'This is the device you are using. You will be signed out now.';

  @override
  String get accountRevokeAll => 'End all sessions';

  @override
  String get accountRevokeAllTitle => 'End every session?';

  @override
  String get accountRevokeAllBody =>
      'Every device will be signed out, including this one.';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteBody =>
      'Your profile, applications and messages will be removed. This cannot be undone.';

  @override
  String get accountDeleteAction => 'Request deletion';

  @override
  String get accountDeleteConfirmTitle => 'Request account deletion?';

  @override
  String get accountDeleteConfirmBody =>
      'We will start removing your account. You will not be able to undo this from the app.';

  @override
  String get accountDeleteRequestedTitle => 'Deletion requested';

  @override
  String get accountDeleteRequestedBody =>
      'Your request has been recorded. Support can tell you what happens next.';

  @override
  String get filtersRegion => 'Region or district';

  @override
  String get filtersEmploymentType => 'Employment type';

  @override
  String get filtersWorkFormat => 'Work format';

  @override
  String get filtersShift => 'Shift';

  @override
  String get filtersSalaryFrom => 'Pay from';

  @override
  String get filtersSalaryNegotiableNote =>
      'Vacancies with negotiable pay are still shown.';

  @override
  String get filtersPublishedFrom => 'Published from';

  @override
  String get filtersUnavailableTitle => 'Three filters are not available yet';

  @override
  String get filtersUnavailableBody =>
      'Experience, language and an upper pay limit cannot be filtered on yet. Everything else here works.';

  @override
  String feedFilteredNote(int count) {
    return '$count filters applied';
  }

  @override
  String get feedFilteredEmpty =>
      'No vacancies match these filters. Try widening them.';

  @override
  String get feedSavedUnfiltered => 'Saved vacancies are never filtered.';

  @override
  String get notesEmpty => 'No notes yet.';

  @override
  String get notesNewLabel => 'New note';

  @override
  String get notesNewHint => 'Asked for 8m, may take 6.5 — call back Thursday';

  @override
  String get applicantsNoneAtStage =>
      'Nobody is at this stage. Clear the filter to see every applicant.';

  @override
  String get shortlistTitle => 'Shortlist';

  @override
  String get shortlistEmpty => 'Nobody is shortlisted yet';

  @override
  String get roleSelectionTitle => 'How will you use JobBridge?';

  @override
  String get roleSelectionSubtitle =>
      'Pick one or both — you can add the other later without a second account.';

  @override
  String get roleCandidateDescription =>
      'Build a profile employers can find, apply to vacancies, and answer invitations.';

  @override
  String get roleEmployerDescription =>
      'Publish vacancies, search candidates, and invite the people you want to talk to.';

  @override
  String get roleSelectionBoth =>
      'With both, one account keeps two separate spaces: your own profile and your company\'s, switched from your profile.';

  @override
  String get chatListEmpty =>
      'A conversation opens with a hiring interaction — an application, or an invitation that was accepted.';

  @override
  String get chatParticipantUnknown => 'Participant';

  @override
  String chatUnreadCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString';
  }

  @override
  String chatUnreadSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '$count unread message',
    );
    return '$_temp0';
  }

  @override
  String get chatNoMessages => 'No messages yet';

  @override
  String get chatAttachment => 'Attachment';

  @override
  String get chatReadOnly => 'Read-only';

  @override
  String get chatBlocked => 'Blocked';

  @override
  String get chatBlockedByYou => 'You blocked this';

  @override
  String get chatReadOnlyTitle => 'This conversation is history';

  @override
  String get chatReadOnlyBody =>
      'The application or invitation it came from has ended, so no new messages can be sent. Everything already here stays readable.';

  @override
  String get chatBlockedTitle => 'Blocked';

  @override
  String get chatBlockedBody =>
      'The other person blocked this conversation. Nobody can send here while that stands, and the messages stay readable.';

  @override
  String get chatBlockedByYouTitle => 'You blocked this conversation';

  @override
  String get chatBlockedByYouBody =>
      'Neither side can send while the block stands — including you. Unblock from the top of the screen to write again.';

  @override
  String get chatUnblock => 'Unblock';

  @override
  String get chatUnblocked => 'Unblocked. You can write again.';

  @override
  String get chatBlockAction => 'Block';

  @override
  String get chatBlockTitle => 'Block this conversation?';

  @override
  String get chatBlockBody =>
      'It becomes read-only for both of you — you will not be able to send either. The messages stay readable, and a moderator can review them.';

  @override
  String get chatBlockReasonLabel => 'Reason (optional)';

  @override
  String get chatBlockReasonHint => 'For the moderator who reviews this';

  @override
  String get chatReportTitle => 'Report this message';

  @override
  String get chatReportBody =>
      'A moderator reads the report and decides. Blocking the conversation is separate, and you can do both.';

  @override
  String get chatReportReasonLabel => 'What is wrong with it';

  @override
  String get chatReportReasonHint => 'Asked me to pay for the job';

  @override
  String get chatReportSubmit => 'Send report';

  @override
  String get chatReportDone => 'Report sent. A moderator will review it.';

  @override
  String get chatComposerLabel => 'Message';

  @override
  String get chatComposerHint => 'Write a message';

  @override
  String get chatSend => 'Send';

  @override
  String get chatSendRefusedTitle => 'Not sent';

  @override
  String get chatSent => 'Sent';

  @override
  String get chatRead => 'Read';

  @override
  String get chatEarlier => 'Earlier messages';

  @override
  String get chatThreadEmpty => 'No messages yet. Write the first one.';

  @override
  String get chatThreadEmptyClosed =>
      'No messages were sent before this conversation closed.';

  @override
  String get chatOpenAction => 'Send a message';

  @override
  String get interviewTitle => 'Interview';

  @override
  String get interviewStatusScheduled => 'Scheduled';

  @override
  String get interviewStatusConfirmed => 'Confirmed';

  @override
  String get interviewStatusRescheduleRequested => 'Another time asked';

  @override
  String get interviewStatusCancelled => 'Cancelled';

  @override
  String get interviewTypePhone => 'Phone call';

  @override
  String get interviewTypeInPerson => 'In person';

  @override
  String get interviewTypeExternalLink => 'Video link';

  @override
  String get interviewPhoneNote =>
      'The employer will call the number on your profile.';

  @override
  String get interviewWhere => 'Where';

  @override
  String get interviewLink => 'Link';

  @override
  String get interviewInstructions => 'From the employer';

  @override
  String get interviewYourReply => 'Your reply';

  @override
  String get interviewPassed => 'This time has already passed.';

  @override
  String get interviewCancelledNotice =>
      'The employer called this interview off.';

  @override
  String get interviewConfirm => 'Confirm';

  @override
  String get interviewRequestAnother => 'Ask for another time';

  @override
  String get interviewConfirmTitle => 'Confirm this time?';

  @override
  String get interviewConfirmBody =>
      'The employer will see that the time suits you. If something changes later you can still ask for another time.';

  @override
  String get interviewRescheduleTitle => 'Ask for another time';

  @override
  String get interviewRescheduleBody =>
      'The interview stays booked until the employer sets a new time, and they will see what you write below.';

  @override
  String get interviewNoteLabel => 'Which times suit you';

  @override
  String get interviewNoteHint => 'Any afternoon this week, or Friday morning';

  @override
  String get interviewReplyNoteLabel => 'Note (optional)';

  @override
  String get interviewReplyNoteHint => 'I will be there ten minutes early';

  @override
  String get interviewNotAllowed => 'This interview has moved on';

  @override
  String get interviewSchedule => 'Schedule an interview';

  @override
  String get interviewScheduleTitle => 'Schedule an interview';

  @override
  String get interviewScheduleSave => 'Send to the candidate';

  @override
  String get interviewRescheduleFormTitle => 'Move this interview';

  @override
  String get interviewRescheduleSave => 'Save the new time';

  @override
  String get interviewRescheduleResets =>
      'The candidate will be asked to confirm again, even for a small change — an interview moved to another time has not been confirmed.';

  @override
  String get interviewTypeLabel => 'Kind of interview';

  @override
  String get interviewWhereHint =>
      'Amir Temur 12, 3rd floor — ask for Dilnoza at reception';

  @override
  String get interviewLinkHint => 'https://meet.example.com/abc-defg-hij';

  @override
  String get interviewDateLabel => 'Date';

  @override
  String get interviewTimeLabel => 'Time';

  @override
  String get interviewTimeHint => '10:00';

  @override
  String get interviewInstructionsLabel =>
      'Anything they should bring or prepare';

  @override
  String get interviewInstructionsHint =>
      'Bring your diploma and your work record book';

  @override
  String get interviewReschedule => 'Move';

  @override
  String get interviewCancelAction => 'Call it off';

  @override
  String get interviewCancelTitle => 'Call off this interview?';

  @override
  String get interviewCancelBody =>
      'This is final for both sides — the interview cannot be brought back, and a new time means scheduling a new one. The candidate will see that it was called off.';

  @override
  String get interviewCancelReasonLabel =>
      'Reason (optional, the candidate sees it)';

  @override
  String get interviewCancelReasonHint =>
      'The role has been filled — thank you for your time';

  @override
  String get interviewCandidateReply => 'What the candidate said';

  @override
  String get commonShowMore => 'Show more';

  @override
  String get commonLoadingMore => 'Loading more…';

  @override
  String get adminDashboardTitle => 'Administration';

  @override
  String get adminQueuesTitle => 'Waiting on a decision';

  @override
  String get adminAwaitingVerification => 'Employers awaiting verification';

  @override
  String get adminAwaitingModeration => 'Vacancies awaiting moderation';

  @override
  String get adminOpenComplaints => 'Open complaints';

  @override
  String get adminQueuesClear => 'Nothing is waiting on you.';

  @override
  String get adminSanctionsTitle => 'Accounts under sanction';

  @override
  String get adminRestrictedUsers => 'Restricted';

  @override
  String get adminBlockedUsers => 'Blocked';

  @override
  String get adminPeriodTitle => 'For the selected period';

  @override
  String adminPeriodDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return '$_temp0';
  }

  @override
  String get adminCandidates => 'Candidates';

  @override
  String get adminEmployers => 'Employers';

  @override
  String get adminVacanciesPublished => 'Vacancies published';

  @override
  String get adminApplicationsSubmitted => 'Applications submitted';

  @override
  String get adminCountTotal => 'in total';

  @override
  String get adminCountNew => 'new';

  @override
  String get adminVerificationTitle => 'Employer verification';

  @override
  String get adminVerificationFifo =>
      'Oldest first — the submission at the top has waited longest.';

  @override
  String get adminVerificationEmpty => 'Nobody is waiting';

  @override
  String get adminVerificationEmptyBody =>
      'Submissions appear here as employers send their documents in.';

  @override
  String get adminEmployerCompany => 'Company';

  @override
  String get adminEmployerIndividual => 'Individual employer';

  @override
  String get adminEmployerUnnamed => 'No name on file';

  @override
  String adminWaitingDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Waiting $days days',
      one: 'Waiting $days day',
      zero: 'Submitted today',
    );
    return '$_temp0';
  }

  @override
  String get adminEvidenceTitle => 'Evidence';

  @override
  String get adminEvidenceNone => 'No documents attached';

  @override
  String get adminVerify => 'Verify';

  @override
  String get adminRequestChanges => 'Ask for changes';

  @override
  String get adminReject => 'Reject';

  @override
  String get adminVerifyTitle => 'Verify this employer?';

  @override
  String get adminVerifyBody =>
      'This is what lets them publish vacancies and invite candidates. Nothing else about their account changes.';

  @override
  String get adminRequestChangesTitle => 'Send this back for changes?';

  @override
  String get adminRequestChangesBody =>
      'They keep their profile and their files, and can submit again once they have fixed what you name below.';

  @override
  String get adminRejectTitle => 'Reject this submission?';

  @override
  String get adminRejectBody =>
      'They stay unverified and cannot publish or invite. Your reason is all they are given, so write what it would take to pass.';

  @override
  String get adminReasonLabel => 'Reason (the employer reads it word for word)';

  @override
  String get adminReasonHint =>
      'The registration certificate is unreadable — please upload a clearer scan';

  @override
  String get adminAlreadyDecided => 'Already decided';

  @override
  String get adminDecisionRecorded => 'Decision recorded.';

  @override
  String get adminQueueTitle => 'Moderation';

  @override
  String get adminQueueEmployers => 'Employers';

  @override
  String get adminQueueVacancies => 'Vacancies';

  @override
  String get adminModerationEmpty => 'No vacancy is waiting';

  @override
  String get adminModerationEmptyBody =>
      'Vacancies appear here as employers submit them for publication.';

  @override
  String get adminRestrictionFlag => 'Age or gender limit';

  @override
  String get adminReviewTitle => 'Review';

  @override
  String get adminVacancyGoneTitle => 'This vacancy has left the queue';

  @override
  String get adminVacancyGoneBody =>
      'Somebody may have decided it already, or the employer may have withdrawn it.';

  @override
  String get adminPublish => 'Publish';

  @override
  String get adminSendBack => 'Send back';

  @override
  String get adminPublishTitle => 'Publish this vacancy?';

  @override
  String get adminPublishBody =>
      'Candidates see it straight away. If it carries an age or gender limit, publishing approves that limit too — this queue is the only way one can ever go live.';

  @override
  String get adminSendBackTitle => 'Send this vacancy back?';

  @override
  String get adminSendBackBody =>
      'The employer can edit it and submit again. Your reason is the only guidance they get, so name what has to change.';

  @override
  String get adminRestrictionJudge =>
      'A limit is only allowed where the reason genuinely requires it. Judge the reason, not the limit.';

  @override
  String get adminRestrictionAge => 'Age limit';

  @override
  String get adminRestrictionGender => 'Gender limit';

  @override
  String get adminRestrictionReason => 'Reason the employer chose';

  @override
  String get adminRestrictionNote => 'In their own words';

  @override
  String get adminPreviousReason => 'Sent back before, for this';

  @override
  String get adminVacancyWhere => 'Where the work is';

  @override
  String get adminVacancyEmployer => 'Employer';

  @override
  String get adminVacancyEmployerPhone => 'Sign-in number';

  @override
  String get adminComplaintsTitle => 'Complaints';

  @override
  String get adminComplaintsEmpty => 'Nothing reported';

  @override
  String get adminComplaintsEmptyBody =>
      'No complaint is waiting for a decision.';

  @override
  String get adminComplaintKindVacancy => 'Vacancy';

  @override
  String get adminComplaintKindUser => 'Person';

  @override
  String get adminComplaintKindProfile => 'Profile';

  @override
  String get adminComplaintKindMessage => 'Message';

  @override
  String get adminComplaintKindUnknown => 'Unknown type';

  @override
  String get adminComplaintKindUnknownBody =>
      'This version of the app cannot show what kind of thing this is. Update the app to review it.';

  @override
  String get adminComplaintTitle => 'Complaint';

  @override
  String get adminComplaintGoneTitle => 'This complaint is gone';

  @override
  String get adminComplaintGoneBody =>
      'Somebody reviewed it, or it never existed. There is nothing left to decide.';

  @override
  String get adminComplaintReported => 'What was reported';

  @override
  String get adminComplaintTarget => 'The reported item';

  @override
  String get adminComplaintTargetGone => 'The reported item is gone';

  @override
  String get adminComplaintTargetGoneBody =>
      'It was removed after the complaint was filed. The complaint is kept, so the outcome can still be recorded.';

  @override
  String get adminComplaintEmployerAccount => 'Employer account';

  @override
  String get adminComplaintRemedy => 'Act on it first';

  @override
  String get adminComplaintRemedyBody =>
      'Recording a complaint as upheld does not carry anything out. Do that here first.';

  @override
  String get adminComplaintNoRemedy =>
      'There is nothing to act on from here. Record the outcome below.';

  @override
  String get adminComplaintOutcome => 'Record the outcome';

  @override
  String get adminComplaintOutcomeBody =>
      'Nothing else records a complaint review, so what you write is the whole account of it.';

  @override
  String get adminComplaintUphold => 'Uphold';

  @override
  String get adminComplaintDismiss => 'Dismiss';

  @override
  String get adminComplaintUpholdTitle => 'Uphold this complaint?';

  @override
  String get adminComplaintUpholdBody =>
      'It closes as upheld. If a remedy was needed, apply it before recording this.';

  @override
  String get adminComplaintDismissTitle => 'Dismiss this complaint?';

  @override
  String get adminComplaintDismissBody =>
      'It closes with nothing done. Say why — this is the only account of the decision.';

  @override
  String get adminResolutionLabel => 'Resolution (kept in the audit log)';

  @override
  String get adminResolutionHint =>
      'The vacancy was paused and the employer asked to take the phone number out of the description';

  @override
  String get adminPauseVacancy => 'Pause this vacancy';

  @override
  String get adminCloseVacancy => 'Remove this vacancy';

  @override
  String get adminPauseVacancyTitle => 'Pause this vacancy?';

  @override
  String get adminPauseVacancyBody =>
      'It leaves the feed now, and can be resumed once the employer has fixed it.';

  @override
  String get adminCloseVacancyTitle => 'Remove this vacancy?';

  @override
  String get adminCloseVacancyBody =>
      'It leaves the feed for good. A removed vacancy cannot be reopened — pause it instead if the employer can fix it.';

  @override
  String get adminWarnUser => 'Warn this person';

  @override
  String get adminWarnUserTitle => 'Send a warning?';

  @override
  String get adminWarnUserBody =>
      'Their account is not changed. The warning and its reason are recorded, and they are told.';

  @override
  String get adminWarnReasonLabel => 'Warning (they read it word for word)';

  @override
  String get adminWarnReasonHint =>
      'Contact details in a public vacancy description are not allowed — please take them out';

  @override
  String get adminAccountStatusActive => 'Active';

  @override
  String get adminAccountStatusRestricted => 'Restricted';

  @override
  String get adminAccountStatusBlocked => 'Blocked';

  @override
  String get adminVacancyEmployerContactPhone => 'Contact number';

  @override
  String get adminUsersTitle => 'Users';

  @override
  String get adminUserSearchPhone => 'Phone number';

  @override
  String get adminUserSearchPhoneHint => 'The last digits are enough';

  @override
  String get adminUserSearchPhoneTooShort => 'At least 3 digits.';

  @override
  String get adminUserSearchName => 'Name';

  @override
  String get adminUserSearchNameHint =>
      'A person, a company, or its legal name';

  @override
  String get adminUserSearchNameTooShort => 'At least 2 characters.';

  @override
  String get adminUserSearchMore => 'More filters';

  @override
  String get adminUserSearchFewer => 'Fewer filters';

  @override
  String get adminUserSearchRole => 'Holds the role';

  @override
  String get adminUserSearchStatus => 'Account status';

  @override
  String get adminUserSearchRegisteredFrom => 'Registered from';

  @override
  String get adminUserSearchRegisteredTo => 'Registered to';

  @override
  String get adminUserSearchDatesReversed => 'These dates cannot match';

  @override
  String get adminUserSearchDatesReversedBody =>
      'The first date is after the second, so no account can fall between them.';

  @override
  String get adminUserSearchRun => 'Search';

  @override
  String get adminUserSearchClear => 'Clear the filters';

  @override
  String get adminUserSearchIdle => 'Find an account';

  @override
  String get adminUserSearchIdleBody =>
      'Search by the last digits of a phone number, or by any name the account is known under — a person\'s, a company\'s public name, or its legal name. Nothing is looked up until you ask.';

  @override
  String get adminUserSearchEmpty => 'No account matches';

  @override
  String get adminUserSearchEmptyBody =>
      'Nothing matches these filters. A phone number is matched anywhere inside it, so the last few digits find an account that a full number typed differently will not.';

  @override
  String get adminUserSearchOrder =>
      'Newest registration first. An older account is further down the list rather than missing — narrow the search instead of paging to it.';

  @override
  String get adminUserNoName => 'No name on the account';

  @override
  String get adminUserNoPhone => 'No phone number';

  @override
  String adminUserRegistered(String date) {
    return 'Registered $date';
  }

  @override
  String adminUserLastLogin(String date) {
    return 'Last signed in $date';
  }

  @override
  String get adminUserNeverSignedIn => 'Never signed in';

  @override
  String get adminAccountStatusDeletionRequested => 'Deletion requested';

  @override
  String get adminUserTitle => 'Account';

  @override
  String get adminUserGoneTitle => 'This account is gone';

  @override
  String get adminUserGoneBody =>
      'It was not found. It may have been deleted since the search that found it.';

  @override
  String get adminUserActions => 'Act on this account';

  @override
  String get adminUserNoActionsTitle => 'Nothing can be done from here';

  @override
  String get adminUserNoActionsBody =>
      'This account has asked to be deleted. That request is answered by its own process, and restricting or blocking it here would overwrite the request.';

  @override
  String get adminUserRestrict => 'Restrict';

  @override
  String get adminUserBlock => 'Block';

  @override
  String get adminUserUnblock => 'Unblock';

  @override
  String get adminUserLiftRestriction => 'Lift the restriction';

  @override
  String get adminUserRestrictTitle => 'Restrict this account?';

  @override
  String get adminUserRestrictBody =>
      'They keep the account and can still sign in, but every action that changes anything is refused until it is lifted. They are shown your reason.';

  @override
  String get adminUserBlockTitle => 'Block this account?';

  @override
  String get adminUserBlockBody =>
      'They lose access to everything but the notice explaining why. Only an administrator can undo it.';

  @override
  String get adminUserUnblockTitle => 'Unblock this account?';

  @override
  String get adminUserLiftRestrictionTitle => 'Lift this restriction?';

  @override
  String get adminUserLiftBody =>
      'Everything is available to them again from now.';

  @override
  String get adminUserRestrictUntilLabel => 'Ends on';

  @override
  String get adminUserRestrictUntilCaption =>
      'The restriction lifts at the start of this day, Tashkent time. Leave it empty and it stays until an administrator lifts it.';

  @override
  String get adminUserStatusReasonLabel =>
      'Reason (they read it word for word)';

  @override
  String get adminUserStatusReasonHint =>
      'Repeatedly posting vacancies that ask candidates for money';

  @override
  String adminUserRestrictedUntil(String date) {
    return 'Restricted until $date';
  }

  @override
  String get adminUserRestrictedIndefinitely =>
      'Restricted until an administrator lifts it';

  @override
  String get adminUserHistory => 'Account history';

  @override
  String get adminUserHistoryEmpty =>
      'Nothing has changed this account\'s status.';

  @override
  String adminUserHistoryBy(String actor) {
    return 'By $actor';
  }

  @override
  String get adminUserHistoryAutomatic =>
      'By the platform, when the date passed';

  @override
  String get adminUserComplaints => 'Complaints about this account';

  @override
  String get adminUserComplaintsEmpty => 'Nobody has reported this account.';

  @override
  String get adminUserComplaintOpen => 'Open';

  @override
  String get adminUserComplaintClosed => 'Reviewed';

  @override
  String get adminAuditTitle => 'Audit log';

  @override
  String get adminAuditNote =>
      'Newest first. Nothing here can be changed or removed.';

  @override
  String get adminAuditEmpty => 'Nothing recorded yet';

  @override
  String get adminAuditEmptyBody =>
      'An entry appears here whenever an administrator decides, verifies, moderates or sanctions something.';

  @override
  String get adminAuditEmptyFilteredBody =>
      'Nothing has been recorded for this one. The rest of the log is below.';

  @override
  String get adminAuditFilteredByActor => 'Only this administrator';

  @override
  String get adminAuditFilteredByTarget => 'Only this record';

  @override
  String get adminAuditShowAll => 'Show the whole log';

  @override
  String get adminAuditActor => 'Administrator';

  @override
  String get adminAuditDetails => 'What changed';

  @override
  String get adminAuditTargetUser => 'Account';

  @override
  String get adminAuditTargetEmployer => 'Employer';

  @override
  String get adminAuditTargetVacancy => 'Vacancy';

  @override
  String get adminAuditTargetComplaint => 'Complaint';

  @override
  String get adminAuditTargetDictionaryItem => 'Dictionary item';

  @override
  String get adminAuditTargetUnknown => 'Other';

  @override
  String get adminAuditVerificationDecided => 'Employer verification decided';

  @override
  String get adminAuditVacancyModerated => 'Vacancy moderated';

  @override
  String get adminAuditComplaintReviewed => 'Complaint reviewed';

  @override
  String get adminAuditUserWarned => 'User warned';

  @override
  String get adminAuditUserRestricted => 'User restricted';

  @override
  String get adminAuditUserBlocked => 'User blocked';

  @override
  String get adminAuditUserUnblocked => 'User unblocked';

  @override
  String get adminAuditRestrictionExpired => 'Restriction expired';

  @override
  String get adminAuditAccountPurged => 'Account deleted';

  @override
  String get adminAuditWalletAdjusted => 'Wallet adjusted';

  @override
  String get adminAuditDictionaryCreated => 'Dictionary item added';

  @override
  String get adminAuditDictionaryUpdated => 'Dictionary item changed';

  @override
  String get adminAuditDictionaryDeactivated => 'Dictionary item deactivated';

  @override
  String get adminAuditDictionaryMerged => 'Dictionary items merged';

  @override
  String get adminUserAuditAbout => 'Everything done to this account';

  @override
  String get adminUserAuditBy => 'Everything this administrator has done';

  @override
  String get candidateHomeTitle => 'Home';

  @override
  String candidateHomeInvitations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invitations await your answer',
      one: '$count invitation awaits your answer',
    );
    return '$_temp0';
  }

  @override
  String candidateHomeApplications(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count applications in progress',
      one: '$count application in progress',
    );
    return '$_temp0';
  }

  @override
  String get candidateHomeProfileEmpty => 'Start your profile';

  @override
  String get candidateHomeProfileIncomplete => 'Finish your profile';

  @override
  String get candidateHomeProfileBody =>
      'A fuller profile is matched to more of the work employers are posting.';

  @override
  String get candidateHomeProfileHidden =>
      'Employers cannot find you yet — your profile has to be complete before it appears in a search.';

  @override
  String get candidateHomeRecommended => 'Recommended for you';

  @override
  String get candidateHomeSeeAll => 'See all';

  @override
  String get candidateHomeNoRecommendations => 'No recommendations yet';

  @override
  String get candidateHomeNoRecommendationsBody =>
      'Recommendations are matched to your occupations, location and work preferences. Newly published vacancies are always worth a look meanwhile.';

  @override
  String get candidateHomeBrowseAll => 'Browse new vacancies';

  @override
  String get invitationAwaitingYou => 'Awaiting your answer';

  @override
  String get employerTypeFirst =>
      'Choose who is hiring above. The details asked for depend on it.';

  @override
  String get employerRequired => 'Required';

  @override
  String employerMissingRequired(String fields) {
    return 'Still needed: $fields';
  }

  @override
  String get dashboardProfileTitle => 'Complete your company profile';

  @override
  String get dashboardProfileMissing => 'Nothing has been entered yet';

  @override
  String dashboardProfileIncomplete(int percent) {
    return '$percent% filled in — vacancies and candidate search need all of it';
  }
}
