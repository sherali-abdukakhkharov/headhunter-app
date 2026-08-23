import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/auth/app_role.dart';
import 'package:jobbridge_app/src/features/admin/domain/admin_user.dart';

/// §10.4's six search axes, as one immutable value.
///
/// ## Every one of these semantics was confirmed at the contract, not guessed
///
/// They are not derivable from the field names, and two of them change the
/// screen:
///
/// - [phone] is a **substring**, not a prefix. A number is remembered by its
///   last digits, so the field must never say "starts with".
/// - [name] is a case-insensitive substring matched against **five** columns —
///   a candidate's profile name, an individual employer's own name, a
///   company's public name, its legal name, and the account's own `full_name`,
///   which in practice only seeded administrators have and which is what lets
///   an administrator find a colleague. An administrator should not have to
///   know which kind of account they are looking for.
/// - [role] matches a user who **holds** the role, not one whose only role it
///   is (§2.3), so the label must not read as "is a".
/// - [status] is exact.
/// - [registeredFrom] and [registeredTo] are **both inclusive** calendar dates
///   in `Asia/Tashkent`; the same day for both means that one day.
///
/// ## Paging bites before the filters do
///
/// Results come back newest registration first, then `limit`/`offset`. So an
/// old account matching a broad filter sits **past the page rather than
/// outside the filter**, and from here those two look identical. That is a
/// fact about the screen's wording rather than about this type, and it is why
/// the results panel says how the list is ordered instead of leaving an
/// administrator to conclude somebody does not exist.
@immutable
class UserSearchFilters {
  const UserSearchFilters({
    this.phone,
    this.name,
    this.role,
    this.status,
    this.registeredFrom,
    this.registeredTo,
  });

  /// The server's own minimum, restated so the screen stops where the API
  /// would have refused rather than after it.
  static const phoneMinLength = 3;
  static const nameMinLength = 2;

  /// Whatever the administrator typed, punctuation and all.
  final String? phone;

  final String? name;
  final AppRole? role;
  final UserAccountStatus? status;

  /// `yyyy-MM-dd`, inclusive.
  final String? registeredFrom;

  /// `yyyy-MM-dd`, inclusive.
  final String? registeredTo;

  /// The query the repository sends. An unset filter is **omitted**, never
  /// sent as null: the server reads an absent key as no constraint and has no
  /// reading at all for a present empty one.
  Map<String, dynamic> toQuery() => {
    'phone': ?searchablePhone,
    'name': ?_trimmed(name),
    'role': ?role?.wire,
    'status': ?status?.wire,
    'registeredFrom': ?_trimmed(registeredFrom),
    'registeredTo': ?_trimmed(registeredTo),
  };

  /// [phone] reduced to what the stored number actually looks like.
  ///
  /// The match is a raw `LIKE` against an E.164 column (`+998901234567`), so a
  /// number pasted out of a chat as `+998 90 123 45 67` matches **nothing** if
  /// it is sent as typed — the spaces are in the pattern. Every character that
  /// is not a digit or a leading `+` is dropped here, at the one place the
  /// value leaves the client, so the field can go on showing what was typed.
  ///
  /// Null when what is left is shorter than [phoneMinLength], which is also
  /// what [isRunnable] refuses on: a two-digit fragment would be a 400 from
  /// the DTO rather than a wide search.
  String? get searchablePhone {
    final raw = _trimmed(phone);
    if (raw == null) return null;

    final digits = raw.replaceAll(RegExp('[^0-9+]'), '');
    final cleaned = digits.startsWith('+')
        ? '+${digits.replaceAll('+', '')}'
        : digits.replaceAll('+', '');

    return cleaned.length < phoneMinLength ? null : cleaned;
  }

  /// Whether the phone box holds something the server would refuse.
  bool get phoneIsTooShort =>
      _trimmed(phone) != null && searchablePhone == null;

  /// Whether the name box holds something the server would refuse.
  bool get nameIsTooShort {
    final value = _trimmed(name);
    return value != null && value.length < nameMinLength;
  }

  /// A range that can match nothing — the one filter mistake the server
  /// answers with an empty list rather than a refusal, which is the answer
  /// hardest to tell from "this person does not exist".
  bool get datesAreReversed {
    final from = _trimmed(registeredFrom);
    final to = _trimmed(registeredTo);
    if (from == null || to == null) return false;

    return from.compareTo(to) > 0;
  }

  /// Whether this set is worth sending at all.
  bool get isRunnable =>
      !phoneIsTooShort && !nameIsTooShort && !datesAreReversed;

  /// No constraint at all: the twenty most recently registered accounts.
  bool get isEmpty => toQuery().isEmpty;

  static String? _trimmed(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
