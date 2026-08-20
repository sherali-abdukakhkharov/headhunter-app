import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';

/// BR-09's contact block, in both its states (§06, E-43).
///
/// ## Locked shows *what* is locked, not just that something is
///
/// The design draws three named rows — phone, e-mail, CV — with their values
/// masked, under the heading "protected information". That is a deliberate
/// improvement on a sentence saying contact is unavailable: an employer
/// deciding whether to spend Coins needs to know what the two Coins buy, and "a
/// phone number, an e-mail address and a CV" is the answer. A single line of
/// prose leaves them guessing whether there is even a number on file.
///
/// ## The mask is fixed-width, and that is a privacy rule
///
/// [maskedPhone] and [maskedEmail] are constants. They are **not** derived from
/// the real value, because a mask whose length tracked the value would leak the
/// length — and §8.7 forbids revealing the protected value "in hidden text,
/// accessibility labels, copy actions, or partial UI".
///
/// The client could not leak it anyway: the server sends `phone: null` and an
/// empty file list until the entitlement exists, so there is nothing here to
/// reconstruct. The fixed mask is the second line of defence, kept because the
/// first one lives in another repository.
///
/// Nothing in the locked state is selectable, has a copy action, or carries a
/// semantics label containing a value. The rows are decorative text over an
/// absence.
class ProtectedContactCard extends StatelessWidget {
  const ProtectedContactCard({
    required this.phone,
    required this.email,
    super.key,
    this.unlockCoins,
    this.onMessage,
  });

  /// Opens §9.1's conversation with this candidate.
  ///
  /// Rendered **only in the unlocked state**, and only where a caller supplies
  /// it — the candidate's own profile shows this card too, and there is nobody
  /// there to message.
  final VoidCallback? onMessage;

  /// The price, already localized as a Coin quantity, or null when the wallet
  /// has not answered.
  ///
  /// Gates the explainer beneath the rows, because that sentence names the
  /// price and §06's second principle is that the price is never a surprise — a
  /// version of it with the number missing would be the opposite. The rows
  /// alone still say what is locked, which is the card's main job.
  final String? unlockCoins;

  /// The number the server sent, or null where BR-09 closed it.
  final String? phone;

  /// The address the server sent, or null. Reserved: today's
  /// `CandidateForEmployerDto` carries no e-mail field, so this is always null
  /// and the row always renders masked. It is modelled anyway because §8.7
  /// lists e-mail beside the phone in the same entitlement, and a row that
  /// appears later should appear in the drawn position rather than wherever it
  /// fits.
  final String? email;

  /// Twelve dots. Uzbek mobile numbers are twelve digits in E.164 (`+998…`), so
  /// this matches the shape of the thing without matching any instance of it.
  static const maskedPhone = '••••••••••••';

  /// Fourteen, from the design. An address has no canonical length, so the mask
  /// deliberately does not imply one.
  static const maskedEmail = '••••••••••••••';

  bool get _unlocked => phone != null && phone!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HhIcon(
                _unlocked ? HhIconPath.checkCircle : HhIconPath.lock,
                size: 17,
                color: _unlocked ? HhColors.successFg : HhColors.inkMuted,
                strokeWidth: 2,
              ),
              const SizedBox(width: HhSpace.sm),
              Expanded(
                child: Text(
                  _unlocked
                      ? l10n.contactUnlockedTitle
                      : l10n.contactLockedTitle,
                  style: HhTypography.subtitle.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),

          _Row(
            iconPath: HhIconPath.phone,
            label: l10n.contactPhone,
            value: phone ?? maskedPhone,
            masked: !_unlocked,
            onCopy: _unlocked ? () => _copy(context, phone!, l10n) : null,
          ),
          const SizedBox(height: 9),
          _Row(
            iconPath: HhIconPath.mail,
            label: l10n.contactEmail,
            value: email ?? maskedEmail,
            masked: email == null || email!.isEmpty,
            onCopy: email != null && email!.isNotEmpty
                ? () => _copy(context, email!, l10n)
                : null,
          ),

          // The CV row appears only while locked. Once open, the real file list
          // renders below with each attachment's purpose and size — two lists
          // of the same files would be one more place for them to disagree.
          if (!_unlocked) ...[
            const SizedBox(height: 9),
            _Row(
              iconPath: HhIconPath.document,
              label: l10n.contactCv,
              value: l10n.contactCvLocked,
              masked: true,
              trailing: const HhIcon(
                HhIconPath.lock,
                size: 15,
                color: HhColors.inkDisabled,
                strokeWidth: 2,
              ),
            ),
          ],

          // §9.1's chat, offered where contact is already open — the same
          // entitlement, from the same service on the server, so this is where
          // it will work rather than where it would mostly fail. The gate is
          // still the server's: the action renders a 403 as the server's
          // sentence, so this placement is a choice about *offering*, never a
          // second copy of the rule.
          //
          // Copy stays beside it. A message needs the other person to open the
          // app; a phone number does not, and §9.1 does not make chat the way
          // to reach somebody.
          if (onMessage case final message? when _unlocked) ...[
            const SizedBox(height: 13),
            HhButton.tertiary(
              label: l10n.chatOpenAction,
              iconPath: HhIconPath.chat,
              onPressed: message,
              compact: true,
            ),
          ],

          if (unlockCoins case final coins? when !_unlocked) ...[
            const SizedBox(height: 13),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: HhIcon(
                    HhIconPath.infoCircle,
                    size: 15,
                    color: HhColors.inkMuted,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    l10n.contactLockedExplainer(coins),
                    style: HhTypography.meta.copyWith(
                      fontSize: 12.5,
                      height: 1.5,
                      color: HhColors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Copy rather than dial or compose. Both of those need a package, and
  /// pubspec.yaml's bounds are load-bearing — the platform dialler and mail app
  /// take it from the clipboard.
  Future<void> _copy(
    BuildContext context,
    String value,
    AppL10n l10n,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    messenger.showSnackBar(SnackBar(content: Text(l10n.commonCopied)));
  }
}

/// One labelled contact row.
class _Row extends StatelessWidget {
  const _Row({
    required this.iconPath,
    required this.label,
    required this.value,
    required this.masked,
    this.trailing,
    this.onCopy,
  });

  final String iconPath;
  final String label;
  final String value;
  final bool masked;
  final Widget? trailing;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        // A locked row sits on the darker fill and an open one on the lighter:
        // the whole block reads as either shut or open before any word is read.
        color: masked ? HhColors.fill : HhColors.surfaceMuted,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            HhIcon(
              iconPath,
              size: 18,
              color: masked ? HhColors.inkDisabled : HhColors.inkMuted,
              strokeWidth: 2,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: HhTypography.meta.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: HhColors.inkSubtle,
                    ),
                  ),
                  const SizedBox(height: 1),
                  // Excluded from semantics while masked so a screen reader
                  // announces the label and nothing else — reading out twelve
                  // bullet characters is noise, and §8.7 names accessibility
                  // labels as a leak path worth closing on purpose.
                  ExcludeSemantics(
                    excluding: masked,
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: masked
                          ? HhTypography.bodyStrong.copyWith(
                              height: 1,
                              color: HhColors.controlOutline,
                              letterSpacing: 1.8,
                            )
                          : HhTypography.bodyStrong,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing case final trailing?) ...[
              const SizedBox(width: HhSpace.sm),
              trailing,
            ],
            // A trailing *word*, which is the row idiom the design uses for the
            // CV's "download". Copy rather than dial or compose: those need a
            // package, and the platform dialler and mail app both take a value
            // from the clipboard.
            if (onCopy case final onCopy?) ...[
              const SizedBox(width: HhSpace.sm),
              Semantics(
                button: true,
                label: '${l10n.commonCopy} $label',
                child: InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 9,
                    ),
                    child: Text(
                      l10n.commonCopy,
                      style: HhTypography.meta.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: HhColors.brand600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
