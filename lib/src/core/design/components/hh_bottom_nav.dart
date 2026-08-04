import 'package:flutter/material.dart';

import 'package:headhunter_app/src/core/design/hh_colors.dart';
import 'package:headhunter_app/src/core/design/hh_icons.dart';
import 'package:headhunter_app/src/core/design/hh_metrics.dart';
import 'package:headhunter_app/src/core/design/hh_typography.dart';

/// One bottom-navigation destination.
@immutable
class HhNavItem {
  const HhNavItem({
    required this.iconPath,
    required this.label,
  });

  final String iconPath;

  /// Localized label. Always shown — the design never uses icon-only tabs.
  final String label;
}

/// Bottom navigation, at most five destinations, **icon + label always**.
///
/// The design specifies three configurations — candidate, employer,
/// administrator — which are supplied as [items] rather than baked in, because
/// the active role decides them at runtime and one account may hold several
/// roles.
///
/// Labels **wrap to two lines rather than truncate**: "Фойдаланувчилар"
/// (Uzbek Cyrillic, admin config) is the longest label in the set, and
/// truncating it would leave "Фойдалан…", which is not a word. That is why the
/// bar reserves height for two lines.
class HhBottomNav extends StatelessWidget {
  const HhBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final List<HhNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    assert(
      items.length <= 5,
      'The design caps bottom navigation at five destinations; '
      'got ${items.length}.',
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        border: Border(top: HhBorders.card),
        boxShadow: HhElevation.nav,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 9, bottom: 11, left: 4, right: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, item) in items.indexed)
                Expanded(
                  child: _NavTab(
                    item: item,
                    selected: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final HhNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: item.label,
    child: InkWell(
      onTap: onTap,
      borderRadius: HhRadius.inputAll,
      child: Container(
        constraints: const BoxConstraints(minHeight: HhSize.minTarget),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: HhIcon(
                item.iconPath,
                size: HhSize.iconNav,
                color: selected ? HhColors.brand600 : HhColors.inkSubtle,
                active: selected,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: HhTypography.navLabel(selected: selected),
              textAlign: TextAlign.center,
              // Two lines, then ellipsis — see the class doc.
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

/// The three destination sets from the design.
///
/// Labels must come from the localization layer at call time, so these are
/// functions of the already-translated strings rather than constants.
abstract final class HhNavSets {
  static List<HhNavItem> candidate({
    required String home,
    required String vacancies,
    required String applications,
    required String messages,
    required String profile,
  }) => [
    HhNavItem(iconPath: HhIconPath.home, label: home),
    HhNavItem(iconPath: HhIconPath.briefcase, label: vacancies),
    HhNavItem(iconPath: HhIconPath.document, label: applications),
    HhNavItem(iconPath: HhIconPath.chat, label: messages),
    HhNavItem(iconPath: HhIconPath.person, label: profile),
  ];

  static List<HhNavItem> employer({
    required String home,
    required String vacancies,
    required String candidates,
    required String messages,
    required String company,
  }) => [
    HhNavItem(iconPath: HhIconPath.home, label: home),
    HhNavItem(iconPath: HhIconPath.briefcase, label: vacancies),
    HhNavItem(iconPath: HhIconPath.people, label: candidates),
    HhNavItem(iconPath: HhIconPath.chat, label: messages),
    HhNavItem(iconPath: HhIconPath.building, label: company),
  ];

  static List<HhNavItem> admin({
    required String dashboard,
    required String queue,
    required String complaints,
    required String users,
    required String dictionaries,
  }) => [
    HhNavItem(iconPath: HhIconPath.home, label: dashboard),
    HhNavItem(iconPath: HhIconPath.shieldCheck, label: queue),
    HhNavItem(iconPath: HhIconPath.alertTriangle, label: complaints),
    HhNavItem(iconPath: HhIconPath.people, label: users),
    HhNavItem(iconPath: HhIconPath.dictionary, label: dictionaries),
  ];
}
