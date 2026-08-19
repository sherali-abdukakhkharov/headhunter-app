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
  String get searchShortlist => 'Shortlist';

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
  String get walletShowMore => 'Show more';

  @override
  String get walletLoadingMore => 'Loading more…';

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
}
