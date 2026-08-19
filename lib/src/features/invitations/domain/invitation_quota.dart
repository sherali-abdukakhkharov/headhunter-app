import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// How many invitations this employer may still send today (§8.2).
///
/// Mirrors `InvitationQuotaDto` in headhunter-backend — change both together.
///
/// ## Every number here is the server's
///
/// The cap is server configuration, like the Coin price and the unlock cost
/// (§6.6, §10.5), and for the same two reasons plus a third:
///
/// 1. A constant in Dart would make a change a store release.
/// 2. It would disagree with the server the moment an administrator moved it,
///    and the disagreement would show as the app refusing a send the API would
///    have accepted.
/// 3. **Extra invitations are expected to become purchasable.** The moment a
///    quota can be bought it is a balance, and §12.3.1 puts balances on the
///    server. So this type exists to *render* figures, never to compute one.
///
/// ## Why there is no `free` and no `purchased`
///
/// [limit] is the **effective** total — whatever the employer may send today,
/// however they came to be allowed it. The client deliberately does not model
/// the tiers: when purchasing lands, the server raises `limit` and this screen
/// is already correct, with no release and no arithmetic. A client that added
/// `free + purchased` itself would be doing the one thing §12.3.1 forbids, to
/// arrive at a number the server already knows.
@immutable
class InvitationQuota {
  const InvitationQuota({
    required this.remaining,
    required this.limit,
    required this.resetsAt,
  });

  factory InvitationQuota.fromJson(Map<String, dynamic> json) =>
      InvitationQuota(
        remaining: json['remaining'] as int,
        limit: json['limit'] as int,
        resetsAt: ZonedTimestamp.parse(json['resetsAt'] as String),
      );

  /// Invitations still available today. Zero is a normal answer.
  final int remaining;

  /// The effective daily limit, free and purchased combined.
  final int limit;

  /// When [remaining] returns to [limit] — the next midnight in the platform
  /// zone.
  ///
  /// A **calendar** boundary rather than a rolling window, which is a product
  /// decision and not an implementation detail: "it resets at midnight" is
  /// something an employer can plan a day around, and "you may send one more in
  /// 7 hours 22 minutes, then two at 09:41" is not.
  final ZonedTimestamp resetsAt;

  /// Whether the employer may send at all right now.
  bool get hasRemaining => remaining > 0;

  /// How close the employer is to the cap, for a progress affordance.
  ///
  /// Guarded against a zero limit, which the server should never send but which
  /// would divide by zero here if it ever did.
  double get usedFraction =>
      limit <= 0 ? 0 : ((limit - remaining) / limit).clamp(0, 1).toDouble();
}
