import 'package:jobbridge_app/l10n/generated/app_l10n.dart';

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
/// The *allowing* codes are here too, and they are the subtle ones: reaching
/// this function with `application` means contact was permitted and there
/// simply is no number on file. Saying "withheld" there would accuse the
/// platform of hiding something that does not exist.
///
/// An unrecognised code — a server ahead of this build — falls back to the
/// generic line. That is the one case where saying less is right.
///
/// ## One function, two servers (§6.6, M12)
///
/// The Coin wallet added a paid entitlement, and the two codes it comes with
/// are handled beside the original six rather than replacing them, because this
/// build has to tell the truth against a server that gates contact on an unlock
/// **and** one that does not:
///
/// - `candidate_unlock` allows, so it joins the allowing group — an employer
///   who paid and finds no number was not refused anything.
/// - `unlock_required` is what a gating server sends where an ungated one sends
///   `no_interaction`. Both are denials with no interaction behind them; they
///   differ in what fixes it, which is the whole reason the codes are kept
///   apart rather than folded into one "denied". So `no_interaction` keeps its
///   original sentence — still true wherever it is still sent — and the new
///   code gets one that offers the purchase.
///
/// That split is also load-bearing outside this function: `unlock_required` is
/// the signal the unlock control is gated on, because a server that has never
/// heard of entitlements cannot send it. See `_Contact` in
/// `candidate_detail_screen.dart`.
///
/// Lives in `applications` because that is where `CandidateForEmployer` lives,
/// and candidate search reads both. One direction, one copy: a privacy rule
/// with two renderings drifts, and the drift is invisible until someone reads
/// both screens side by side.
String exposureExplanation(String reason, AppL10n l10n) => switch (reason) {
  'application' || 'accepted_invitation' || 'admin' || 'candidate_unlock' =>
    l10n.candidatePhoneNotOnFile,
  'not_verified_employer' => l10n.candidateExposureNotVerified,
  'unlock_required' => l10n.candidateExposureUnlockRequired,
  'no_interaction' => l10n.candidateExposureNoInteraction,
  'hidden_by_candidate' => l10n.candidateExposureHidden,
  _ => l10n.candidatePhoneHiddenWhy,
};

/// Whether this reason is one a **purchase** would resolve (§6.6, UAT-17).
///
/// The unlock control is offered on exactly this, and on nothing else. Three
/// things follow from that, and the third is why it is a function rather than a
/// comparison at the call site:
///
/// 1. `not_verified_employer` is excluded. BR-03 is a precondition an employer
///    cannot buy past — §7 says only a verified employer may see candidates at
///    all — so offering a purchase there would sell access the server will
///    refuse.
/// 2. `hidden_by_candidate` is excluded for the same shape of reason: the
///    candidate withdrew from search, and no amount of Coins changes that.
/// 3. **`no_interaction` is excluded, and that is what makes this build safe to
///    ship before the backend gates exposure.** A server that has not learned
///    about entitlements answers `no_interaction`, so the control never appears
///    and nobody can be charged for an unlock that would change nothing. On the
///    day the backend starts sending `unlock_required` the control appears — no
///    client release, and no flag to remember to switch on.
bool unlockWouldOpenContact(String reason) => reason == 'unlock_required';
