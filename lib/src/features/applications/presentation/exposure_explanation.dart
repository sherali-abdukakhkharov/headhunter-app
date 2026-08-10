import 'package:headhunter_app/l10n/generated/app_l10n.dart';

/// Turns BR-09's `exposureReason` into a sentence that says what would change
/// it.
///
/// ## Why the reason is worth rendering at all
///
/// A blank where a phone number should be reads as a bug. The server already
/// knows *which* rule closed it — `contact-exposure.ts` returns a stable code
/// precisely so "two rules that both deny for different reasons are not the
/// same rule" survives the trip — and throwing that away at the last step
/// leaves an employer thinking the app is broken when the real answer is that
/// nobody has applied yet.
///
/// ## Exhaustive, not defaulted
///
/// The six codes are mapped one by one rather than folded into a generic line.
/// "The candidate has hidden their profile" and "no interaction yet" are things
/// an employer acts on differently: the first is not going to change, and the
/// second changes the moment the candidate applies.
///
/// The three *allowing* codes are here too, and they are the subtle ones:
/// reaching this function with `application` means contact was permitted and
/// there simply is no number on file. Saying "withheld" there would accuse the
/// platform of hiding something that does not exist.
///
/// An unrecognised code — a server ahead of this build — falls back to the
/// generic line. That is the one case where saying less is right.
///
/// Lives in `applications` because that is where `CandidateForEmployer` lives,
/// and candidate search reads both. One direction, one copy: a privacy rule
/// with two renderings drifts, and the drift is invisible until someone reads
/// both screens side by side.
String exposureExplanation(String reason, AppL10n l10n) => switch (reason) {
  'application' || 'accepted_invitation' || 'admin' =>
    l10n.candidatePhoneNotOnFile,
  'not_verified_employer' => l10n.candidateExposureNotVerified,
  'no_interaction' => l10n.candidateExposureNoInteraction,
  'hidden_by_candidate' => l10n.candidateExposureHidden,
  _ => l10n.candidatePhoneHiddenWhy,
};
