import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/core/network/api_exception.dart';
import 'package:jobbridge_app/src/features/chat/data/chat_repository.dart';
import 'package:jobbridge_app/src/features/chat/domain/conversation.dart';
import 'package:jobbridge_app/src/shared/format/wall_clock.dart';

/// The Messages tab, for both roles (§9.1).
///
/// ## One screen, and it does not ask who is looking
///
/// `GET /conversations` is scoped by the caller's active role on the server, so
/// a candidate and an employer get their own threads from the same call. The
/// screen therefore has no role branch at all — and the empty state's sentence
/// is deliberately **role-neutral** ("a conversation opens with a hiring
/// interaction") rather than two sentences chosen by role. Two would need this
/// screen to hold an opinion about which side it is on, which is the one thing
/// §9.1's gate already answers better than the client can.
///
/// ## The thread is a child of whichever tab rendered this
///
/// [basePath] comes from the route that built the screen, so `context.go` walks
/// into `<this tab>/<id>` and the system back gesture returns here with the
/// shell's nav bar intact. Not derived from the active role: the role and the
/// location can disagree for one frame during a switch (see
/// `role_navigation.dart`), and a path built from the role during that frame
/// would land in the other shell.
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({required this.basePath, super.key});

  /// The path of the tab this screen is the body of, e.g. `/employer/messages`.
  final String basePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final threads = ref.watch(conversationsProvider);

    return switch (threads) {
      // Error first, before any loading arm: retry is disabled app-wide, so a
      // failure is terminal and a spinner over it would never end.
      AsyncValue(hasError: true, :final error?) => Padding(
        padding: const EdgeInsets.all(HhSpace.gutter),
        child: HhErrorState(
          title: failureTitle(error, l10n),
          message: error is ApiException ? error.message : l10n.stateErrorBody,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(conversationsProvider),
        ),
      ),
      AsyncData(:final value) when value.isEmpty => Padding(
        padding: const EdgeInsets.all(HhSpace.gutter),
        child: HhEmptyState(
          title: l10n.stateEmptyTitle,
          message: l10n.chatListEmpty,
          art: HhSpotArt.first,
        ),
      ),
      AsyncData(:final value) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(conversationsProvider),
        child: ListView.builder(
          padding: const EdgeInsets.all(HhSpace.gutter),
          itemCount: value.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: HhSpace.sm),
            child: _ConversationRow(
              conversation: value[index],
              basePath: basePath,
            ),
          ),
        ),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// One thread's row: who, when, what was last said, and whether it is still
/// open.
class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conversation, required this.basePath});

  final Conversation conversation;
  final String basePath;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      onTap: () => context.go('$basePath/${conversation.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A Wrap and not a Row with an Expanded name, which is what this was
          // and which overflowed by 138pt at the design's own QA case (320pt,
          // 2.0x): the stamp is a full ISO date and time, and at that scale it
          // is wider than the whole card on its own — so `Expanded` on the name
          // shrinks the wrong child and the stamp still does not fit.
          //
          // It must not be the thing that truncates, either. A date clipped to
          // "2026-08-20 1…" is a date nobody can read, and §8.3's display
          // policy is still open precisely so a wrong-*looking* date beats a
          // plausible wrong one. So it drops to its own line instead — the same
          // fix, for the same reason, as the §8.2 inbox card's badge row.
          //
          // `width: double.infinity` is load-bearing and easy to lose: the
          // Column around this is `crossAxisAlignment: start`, which hands its
          // children *loose* constraints, so a bare Wrap shrink-wraps its
          // content and `spaceBetween` has no free space to distribute. The
          // stamp then sits hard against the name and the column of stamps
          // comes out ragged, which reads as a bug rather than as a layout.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: HhSpace.sm,
              runSpacing: 2,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  // A thread whose counterpart has no name still has to say
                  // what it is. §7.3's "permitted name" rule means an absent
                  // name is sometimes the correct answer, not a load that
                  // failed, so the row reads as a person rather than as a gap.
                  conversation.counterpartName ?? l10n.chatParticipantUnknown,
                  style: HhTypography.subtitle.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (conversation.lastMessageAt case final at?)
                  Text(
                    wallClockStamp(at.wallClock),
                    style: HhTypography.meta.copyWith(color: HhColors.inkMuted),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _preview(l10n),
                  style: HhTypography.caption.copyWith(
                    color: HhColors.inkMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (conversation.unreadCount > 0) ...[
                const SizedBox(width: HhSpace.sm),
                HhUnreadPill(
                  label: l10n.chatUnreadCount(conversation.unreadCount),
                  semanticsLabel: l10n.chatUnreadSemantics(
                    conversation.unreadCount,
                  ),
                ),
              ],
            ],
          ),

          // On its own line rather than beside the name, the lesson the §8.2
          // inbox card paid for: a badge is icon **plus word**, so it cannot be
          // the thing that yields when a name and a timestamp already fill the
          // row. Truncating it would put the state back on colour alone.
          if (conversation.isReadOnly) ...[
            const SizedBox(height: HhSpace.sm),
            conversationStateBadge(conversation, l10n),
          ],
        ],
      ),
    );
  }

  /// The preview line.
  ///
  /// Three cases and not two: the server sends the last message's **body**, and
  /// a message that carried only an attachment has none. So "active, but
  /// nothing to quote" is a real state, and it is not the same as a thread
  /// nobody has written in.
  String _preview(AppL10n l10n) {
    if (conversation.lastMessageBody case final body? when body.isNotEmpty) {
      return body;
    }
    return conversation.lastMessageAt == null
        ? l10n.chatNoMessages
        : l10n.chatAttachment;
  }
}

/// The badge for a thread that no longer accepts messages (§9.1).
///
/// Three labels over two badges, because `blockedByMe` changes what the reader
/// can do about it and not what the state is: only the person who blocked can
/// unblock, so telling them apart on the row is what makes the thread's own
/// screen unsurprising.
///
/// A live thread has no badge at all. "Open" is the default state of a
/// conversation and badging it would make the exception invisible among the
/// rule.
Widget conversationStateBadge(Conversation conversation, AppL10n l10n) {
  if (conversation.isBlocked) {
    return HhBadge.conversationBlocked(
      label: conversation.blockedByMe
          ? l10n.chatBlockedByYou
          : l10n.chatBlocked,
    );
  }
  return HhBadge.conversationReadOnly(label: l10n.chatReadOnly);
}
