/// Which side of the ledger a request is asking for (§06, E-52).
///
/// **Sign, not kind.** "Topped up" and "spent" look like they name kinds, and
/// they do not: an `admin_adjustment` can be either, and a `reversal` is a
/// credit that undoes a debit. A list of kind codes would also have to be kept
/// in step on both sides, and would silently drop a sixth kind from *both*
/// filters — whereas every entry has exactly one sign, and always will.
enum LedgerSign {
  /// Coins arriving: the registration bonus, a top-up, a credit adjustment.
  credit,

  /// Coins leaving: an unlock, a debit adjustment.
  debit;

  /// The value the server's `sign` query parameter takes.
  String get wire => name;
}
