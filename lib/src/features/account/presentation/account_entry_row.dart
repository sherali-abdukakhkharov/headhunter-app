import 'package:flutter/material.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/account/presentation/account_screen.dart';

/// The way in to §4.2 and BR-14, from whichever profile the role has.
///
/// A row rather than an app-bar icon, for two reasons. Neither profile screen
/// has an app bar — the role shell provides no chrome and each screen builds
/// its own header — and the glyph set has no gear: `lock` already means
/// "restricted"
/// in five places and `shieldCheck` means verification, so an icon here would
/// have had to overload one of them. A named row also says what is behind it,
/// which matters for the one screen somebody visits to *leave*.
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
