import 'package:flutter/foundation.dart';
import 'package:jobbridge_app/src/core/time/zoned_timestamp.dart';

/// One §9.1 conversation, as the caller sees it.
///
/// Mirrors `ConversationDto` in headhunter-backend — change both together.
///
/// ## "Mine" is derived from the counterpart, never from a stored user id
///
/// The app has never needed to know its own user id, and this feature does not
/// change that. A conversation has exactly two participants and the server
/// names the other one *per caller*, so a message is mine when its sender is
/// not [counterpartUserId]. `SessionActive` carries granted roles and an
/// account status and no id; adding one so a bubble could pick a side would put
/// a second answer to "who am I" into the app, and the two would eventually
/// disagree after a role switch.
///
/// [employerUserId] and [candidateUserId] are parsed because they are what
/// makes the pair meaningful in a bug report, not because a screen picks a side
/// with them.
///
/// ## [canSend] is the server's answer *at the time of the response*
///
/// It is not a flag the client maintains. The server re-asks
/// `HiringInteractionService` on every send, so a withdrawal, a rejection or a
/// declined invitation turns a live thread into history while somebody is
/// looking at it. The screen renders the last answer it was given and lets a
/// send be refused — which is why `chat.read_only` is an outcome that reshapes
/// the screen rather than an error.
///
/// **Read-only and blocked are two different facts** and [isBlocked] is what
/// separates them: both make [canSend] false, but one is undone by unblocking
/// and the other by the hiring interaction resuming, so they cannot share a
/// sentence.
@immutable
class Conversation {
  const Conversation({
    required this.id,
    required this.employerUserId,
    required this.candidateUserId,
    required this.counterpartUserId,
    required this.unreadCount,
    required this.canSend,
    required this.isBlocked,
    required this.blockedByMe,
    this.counterpartName,
    this.lastMessageAt,
    this.lastMessageBody,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'] as String,
    employerUserId: json['employerUserId'] as String,
    candidateUserId: json['candidateUserId'] as String,
    counterpartUserId: json['counterpartUserId'] as String,
    unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    canSend: json['canSend'] as bool? ?? false,
    isBlocked: json['isBlocked'] as bool? ?? false,
    blockedByMe: json['blockedByMe'] as bool? ?? false,
    counterpartName: json['counterpartName'] as String?,
    lastMessageAt: switch (json['lastMessageAt']) {
      final String at => ZonedTimestamp.parse(at),
      _ => null,
    },
    lastMessageBody: json['lastMessageBody'] as String?,
  );

  final String id;
  final String employerUserId;
  final String candidateUserId;

  /// The other participant, from the caller's side.
  final String counterpartUserId;

  /// The candidate's name or the employer's public name — never a legal name.
  ///
  /// Null where the server sends none, and a null name is rendered as the
  /// role's word rather than as a gap: §7.3's "permitted name" rule means a
  /// missing name is sometimes the correct answer, not a failure to load one.
  final String? counterpartName;

  /// When the thread was last active, or null for one opened and never used.
  final ZonedTimestamp? lastMessageAt;

  /// The last message's text, for the list's preview line.
  ///
  /// Null when the last message carried only an attachment — the server sends
  /// the body it has, and there is no body there. A preview therefore has to
  /// cope with "active, but nothing to quote".
  final String? lastMessageBody;

  /// Messages from the other side the caller has not read.
  final int unreadCount;

  /// §9.1: false once the hiring interaction has ended or either side blocked.
  final bool canSend;

  final bool isBlocked;

  /// Whether it was the caller who blocked — the only thing that decides
  /// whether unblocking is on offer. A block set by the other side is a fact
  /// this side cannot clear, and offering a control that looks like it clears
  /// it would be worse than offering nothing.
  final bool blockedByMe;

  /// True when the thread is history: readable, and closed to new messages.
  bool get isReadOnly => !canSend;

  /// Read-only for a reason **other** than a block.
  ///
  /// The two need different sentences: this one is undone by the hiring
  /// interaction resuming, and a block is undone by unblocking.
  bool get isEnded => !canSend && !isBlocked;
}
