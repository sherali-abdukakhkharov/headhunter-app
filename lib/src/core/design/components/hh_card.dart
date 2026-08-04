import 'package:flutter/material.dart';

import 'package:headhunter_app/src/core/design/components/hh_badge.dart';
import 'package:headhunter_app/src/core/design/components/hh_category_band.dart';
import 'package:headhunter_app/src/core/design/components/hh_chip.dart';
import 'package:headhunter_app/src/core/design/components/hh_progress.dart';
import 'package:headhunter_app/src/core/design/hh_colors.dart';
import 'package:headhunter_app/src/core/design/hh_icons.dart';
import 'package:headhunter_app/src/core/design/hh_metrics.dart';
import 'package:headhunter_app/src/core/design/hh_typography.dart';

/// The base card surface: white, hairline border, one elevation level.
///
/// Every card in the product should be built on this rather than a bare
/// `Container`, so the single permitted elevation stays single.
class HhCard extends StatelessWidget {
  const HhCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final decorated = DecoratedBox(
      decoration: const BoxDecoration(
        color: HhColors.white,
        borderRadius: HhRadius.cardAll,
        border: Border.fromBorderSide(HhBorders.card),
        boxShadow: HhElevation.card,
      ),
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: HhRadius.cardAll,
                child: Padding(padding: padding, child: child),
              ),
            ),
    );

    if (clipBehavior == Clip.none) return decorated;
    return ClipRRect(borderRadius: HhRadius.cardAll, child: decorated);
  }
}

/// Vacancy card as drawn in the design: category band, title, employer, pay,
/// metadata chips, and a footer with the verification mark and publication age.
///
/// [category] and [categoryLabel] are **required** because the band always
/// renders — with a photograph when one exists, otherwise with the category
/// tint plus glyph and name. See [HhCategoryBand]: a card that drops its band
/// changes height relative to its neighbours, and that is the one behaviour
/// that breaks the rhythm of a scanned list.
class HhVacancyCard extends StatelessWidget {
  const HhVacancyCard({
    required this.title,
    required this.employer,
    required this.pay,
    required this.category,
    required this.categoryLabel,
    super.key,
    this.metaChips = const [],
    this.verifiedLabel,
    this.publishedLabel,
    this.saved = false,
    this.onToggleSave,
    this.onTap,
    this.image,
  });

  final HhWorkCategory category;

  /// Localized category name, shown when there is no photograph.
  final String categoryLabel;

  final String title;
  final String employer;

  /// Pre-formatted pay string. Formatting is locale-dependent, so it is the
  /// caller's job — this widget never formats numbers.
  final String pay;

  final List<Widget> metaChips;

  /// Localized "Verified employer". Omit for an unverified employer; do not
  /// substitute a neutral badge, since absence is the signal.
  final String? verifiedLabel;

  /// Localized relative age, e.g. "2 days ago".
  final String? publishedLabel;

  final bool saved;
  final VoidCallback? onToggleSave;
  final VoidCallback? onTap;

  /// Category photograph. When null the band still renders, filled with the
  /// category tint, glyph and name — see [HhCategoryBand].
  final Widget? image;

  @override
  Widget build(BuildContext context) => HhCard(
    onTap: onTap,
    clipBehavior: Clip.antiAlias,
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always present — never conditional. See the class doc.
        HhCategoryBand(
          category: category,
          categoryLabel: categoryLabel,
          image: image,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: HhTypography.subtitle),
                        const SizedBox(height: 3),
                        Text(
                          employer,
                          style: HhTypography.caption.copyWith(fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                  if (onToggleSave != null)
                    Semantics(
                      button: true,
                      selected: saved,
                      child: InkWell(
                        onTap: onToggleSave,
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: HhSize.minTarget,
                          height: HhSize.minTarget,
                          child: Center(
                            child: HhIcon(
                              HhIconPath.bookmark,
                              size: 22,
                              color: saved
                                  ? HhColors.brand600
                                  : HhColors.inkSubtle,
                              active: saved,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                pay,
                style: HhTypography.bodyStrong.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (metaChips.isNotEmpty) ...[
                const SizedBox(height: 9),
                Wrap(spacing: 6, runSpacing: 6, children: metaChips),
              ],
              if (verifiedLabel != null || publishedLabel != null) ...[
                const SizedBox(height: 11),
                const Divider(height: 1),
                const SizedBox(height: 9),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (verifiedLabel != null)
                      HhVerifiedMark(label: verifiedLabel!)
                    else
                      const SizedBox.shrink(),
                    if (publishedLabel != null)
                      Text(
                        publishedLabel!,
                        style: HhTypography.meta.copyWith(
                          color: HhColors.inkSubtle,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

/// Candidate result card: avatar, name, match pill, headline, and attribute
/// chips.
///
/// **Never put a phone number or full contact detail on this card.** Contact
/// details are released only per the candidate's privacy settings plus an
/// allowed hiring interaction, which is a server-side decision — a search
/// result card is not one of those contexts.
class HhCandidateCard extends StatelessWidget {
  const HhCandidateCard({
    required this.name,
    required this.headline,
    super.key,
    this.matchLabel,
    this.chips = const [],
    this.onTap,
    this.avatar,
  });

  final String name;

  /// e.g. "Call-centre operator · 2 years experience".
  final String headline;

  /// Localized "88% match".
  final String? matchLabel;

  final List<Widget> chips;
  final VoidCallback? onTap;

  /// Shown only when the candidate's privacy settings permit a photo.
  final Widget? avatar;

  @override
  Widget build(BuildContext context) => HhCard(
    onTap: onTap,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: HhColors.placeholder,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child:
              avatar ??
              const Center(
                child: HhIcon(
                  HhIconPath.person,
                  size: 22,
                  color: HhColors.inkSubtle,
                  strokeWidth: 1.8,
                ),
              ),
        ),
        const SizedBox(width: HhSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: HhTypography.bodyStrong,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (matchLabel != null) ...[
                    const SizedBox(width: HhSpace.sm),
                    HhMatchPill(label: matchLabel!),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              Text(
                headline,
                style: HhTypography.caption.copyWith(fontSize: 13.5),
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 7),
                Wrap(spacing: 5, runSpacing: 5, children: chips),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

/// Application card: role, context line, current-stage badge, and the stage
/// timeline.
class HhApplicationCard extends StatelessWidget {
  const HhApplicationCard({
    required this.title,
    required this.subtitle,
    required this.stageBadge,
    required this.stages,
    required this.currentStageIndex,
    super.key,
    this.onTap,
  });

  final String title;

  /// e.g. "Nur Market · 12 August".
  final String subtitle;

  /// The current stage as an [HhBadge], so it uses the same vocabulary as every
  /// other status in the product.
  final Widget stageBadge;

  final List<String> stages;
  final int currentStageIndex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => HhCard(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: HhTypography.bodyStrong),
                  const SizedBox(height: 2),
                  Text(subtitle, style: HhTypography.caption),
                ],
              ),
            ),
            const SizedBox(width: HhSpace.sm),
            stageBadge,
          ],
        ),
        const SizedBox(height: 11),
        HhStageTimeline(stages: stages, currentIndex: currentStageIndex),
      ],
    ),
  );
}

/// Convenience builder for the neutral metadata chips a vacancy card carries.
List<Widget> hhVacancyMeta({
  String? location,
  String? schedule,
  String? openings,
}) => [
  if (location != null)
    HhMetaChip(label: location, iconPath: HhIconPath.location),
  if (schedule != null) HhMetaChip(label: schedule),
  if (openings != null) HhMetaChip(label: openings),
];
