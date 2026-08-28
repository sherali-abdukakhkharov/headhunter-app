import 'package:flutter/material.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/account/presentation/account_screen.dart';

/// The way in to §4.2 and BR-14, as a row.
///
/// A row rather than an icon: the glyph set has no gear — `lock` already means
/// "restricted" in five places and `shieldCheck` means verification, so an icon
/// here would have had to overload one of them. A named row also says what is
/// behind it, which matters for the one screen somebody visits to *leave*.
///
/// **On the two profile screens this is now [AccountEntryAction] instead**, at
/// the top and outside the scroll. The row's reasoning was sound and its
/// *position* was not: it sat under the whole editable profile, so reaching
/// language, sessions, role switch, sign-out and BR-14 took five or six swipes
/// (1.29.0 audit, P1). It stays as a row on the administrator's dashboard,
/// which is short enough that it is already on the first screen.
class AccountEntryRow extends StatelessWidget {
  const AccountEntryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhCard(
      onTap: () => showAccount(context),
      child: Row(
        children: [
          const HhIcon(
            HhIconPath.person,
            size: 20,
            color: HhColors.inkMuted,
            strokeWidth: 2,
          ),
          const SizedBox(width: HhSpace.md),
          Expanded(
            child: Text(
              l10n.accountTitle,
              style: HhTypography.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const HhIcon(
            HhIconPath.chevronRight,
            size: 18,
            color: HhColors.inkDisabled,
          ),
        ],
      ),
    );
  }
}

/// The same destination, as a header action.
///
/// A word rather than a glyph, for the reason above: there is no gear in the
/// set, and one word is quicker to read than an icon is to decode.
///
/// **`accountEntryShort`, not `accountTitle`.** "Account and security" names
/// the screen and it shares this row with the *screen's own* title, where it
/// overflows — 20 characters against a 328pt row before the text scale is
/// touched. A destination and a way in to it are allowed different lengths.
class AccountEntryAction extends StatelessWidget {
  const AccountEntryAction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return HhButton.text(
      label: l10n.accountEntryShort,
      onPressed: () => showAccount(context),
    );
  }
}
