import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// §9.2's five notification categories.
///
/// They are what a user switches off, not what a notification is *about* —
/// `account` covers a restriction and a verification decision alike, because
/// what those two share is that they are about the account rather than about
/// the work.
enum NotificationCategory {
  applications('applications'),
  invitations('invitations'),
  messages('messages'),
  interviews('interviews'),

  /// **Cannot be switched off** (§9.2). The server refuses it with
  /// `notification.category_not_disableable` and a CHECK constraint refuses
  /// the row underneath, so this is a fact about the data rather than a rule
  /// this client is enforcing.
  account('account'),

  /// A category added after this build shipped.
  unknown('');

  const NotificationCategory(this.wire);

  factory NotificationCategory.fromWire(String? value) => values.firstWhere(
    (category) => category.wire == value,
    orElse: () => NotificationCategory.unknown,
  );

  final String wire;
}

/// One notification (§9.2).
///
/// Mirrors `NotificationDto` in headhunter-backend — change both together.
///
/// ## [text] is a sentence, not a key
///
/// The row stores a message key and its parameters; the server renders it in
/// the language of *this* request. So a user who switches language reads their
/// whole history in the new one, and the client shows the sentence verbatim
/// (§2.4's rule for user content applies here for a different reason: this
/// text is already in the reader's language, and re-rendering it from a
/// client-side table would put two translations of one event in the product).
///
/// **Branch on [event], never on the sentence.**
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.event,
    required this.category,
    required this.text,
    required this.isRead,
    required this.createdAt,
    this.targetType,
    this.targetId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        event: json['event'] as String? ?? '',
        category: NotificationCategory.fromWire(json['category'] as String?),
        text: json['text'] as String? ?? '',
        isRead: json['isRead'] as bool? ?? false,
        createdAt: ZonedTimestamp.parse(json['createdAt'] as String),
        targetType: json['targetType'] as String?,
        targetId: json['targetId'] as String?,
      );

  final String id;

  /// A stable §9.2 event code — `application_created`, `interview_changed`.
  /// Kept as a string: the catalogue grows server-side, and a row this build
  /// cannot classify still has a sentence worth reading.
  final String event;

  final NotificationCategory category;

  /// Already in the reader's language. Shown as given.
  final String text;

  /// What tapping it should open: `vacancy`, `application`, `conversation`,
  /// `interview`, `invitation`, `employer`, `user`. Null where the event is
  /// about nothing addressable.
  final String? targetType;

  final String? targetId;

  final bool isRead;
  final ZonedTimestamp createdAt;

  /// The same notification, read.
  ///
  /// Used to mark one locally rather than re-reading the list: the server's
  /// answer to `POST /notifications/:id/read` is 204, so a refetch would cost
  /// a request to learn what the request just did.
  AppNotification get read => AppNotification(
    id: id,
    event: event,
    category: category,
    text: text,
    isRead: true,
    createdAt: createdAt,
    targetType: targetType,
    targetId: targetId,
  );
}

/// Whether one category is delivered, and whether that can be changed (§9.2).
@immutable
class NotificationPreference {
  const NotificationPreference({
    required this.category,
    required this.enabled,
    required this.canDisable,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) =>
      NotificationPreference(
        category: NotificationCategory.fromWire(json['category'] as String?),
        enabled: json['enabled'] as bool? ?? true,
        canDisable: json['canDisable'] as bool? ?? true,
      );

  final NotificationCategory category;
  final bool enabled;

  /// False for `account`. §9.2 keeps security and account notices on, and the
  /// settings screen **shows it greyed out rather than omitting it** — a user
  /// who cannot find a switch assumes it is off.
  final bool canDisable;
}
