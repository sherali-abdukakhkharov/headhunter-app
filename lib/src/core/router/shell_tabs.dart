import 'package:flutter/foundation.dart';
import 'package:headhunter_app/l10n/generated/app_l10n.dart';
import 'package:headhunter_app/src/core/auth/app_role.dart';
import 'package:headhunter_app/src/core/design/hh_icons.dart';
import 'package:headhunter_app/src/core/router/routes.dart';

/// One destination in a role's bottom navigation.
///
/// This table is the **single source** for three things that must not disagree:
/// the router's branch definitions, the bottom bar's items, and each tab's
/// screen title. Kept together because they drifted apart in every codebase
/// where they were written out three times - a renamed tab whose route still
/// says the old thing is invisible until someone deep-links to it.
@immutable
class ShellTab {
  const ShellTab({
    required this.path,
    required this.iconPath,
    required this.label,
    required this.milestone,
  });

  final String path;
  final String iconPath;

  /// Resolved at build time from the active locale, never captured once - the
  /// language switches live (§3.2) and a cached label would keep the old one.
  final String Function(AppL10n) label;

  /// The milestone that replaces this placeholder with the real screen. Shown
  /// on the placeholder itself, so a build handed to the client says what is
  /// unfinished rather than looking broken.
  final String milestone;
}

/// The three destination sets of the design, one per role.
///
/// Five tabs each, which is the design's cap and also what `HhBottomNav`
/// asserts.
abstract final class ShellTabs {
  static const List<ShellTab> candidate = [
    ShellTab(
      path: Routes.candidateHome,
      iconPath: HhIconPath.home,
      label: _homeLabel,
      milestone: 'M6',
    ),
    ShellTab(
      path: Routes.candidateVacancies,
      iconPath: HhIconPath.briefcase,
      label: _vacanciesLabel,
      milestone: 'M6',
    ),
    ShellTab(
      path: Routes.candidateApplications,
      iconPath: HhIconPath.document,
      label: _applicationsLabel,
      milestone: 'M6',
    ),
    ShellTab(
      path: Routes.candidateMessages,
      iconPath: HhIconPath.chat,
      label: _messagesLabel,
      milestone: 'M8',
    ),
    ShellTab(
      path: Routes.candidateProfile,
      iconPath: HhIconPath.person,
      label: _profileLabel,
      milestone: 'M3',
    ),
  ];

  static const List<ShellTab> employer = [
    ShellTab(
      path: Routes.employerHome,
      iconPath: HhIconPath.home,
      label: _homeLabel,
      milestone: 'M5',
    ),
    ShellTab(
      path: Routes.employerVacancies,
      iconPath: HhIconPath.briefcase,
      label: _vacanciesLabel,
      milestone: 'M5',
    ),
    ShellTab(
      path: Routes.employerCandidates,
      iconPath: HhIconPath.people,
      label: _candidatesLabel,
      milestone: 'M7',
    ),
    ShellTab(
      path: Routes.employerMessages,
      iconPath: HhIconPath.chat,
      label: _messagesLabel,
      milestone: 'M8',
    ),
    ShellTab(
      path: Routes.employerCompany,
      iconPath: HhIconPath.building,
      label: _companyLabel,
      milestone: 'M4',
    ),
  ];

  static const List<ShellTab> admin = [
    ShellTab(
      path: Routes.adminDashboard,
      iconPath: HhIconPath.home,
      label: _dashboardLabel,
      milestone: 'M10',
    ),
    ShellTab(
      path: Routes.adminQueue,
      iconPath: HhIconPath.shieldCheck,
      label: _queueLabel,
      milestone: 'M10',
    ),
    ShellTab(
      path: Routes.adminComplaints,
      iconPath: HhIconPath.alertTriangle,
      label: _complaintsLabel,
      milestone: 'M10',
    ),
    ShellTab(
      path: Routes.adminUsers,
      iconPath: HhIconPath.people,
      label: _usersLabel,
      milestone: 'M10',
    ),
    ShellTab(
      path: Routes.adminDictionaries,
      iconPath: HhIconPath.dictionary,
      label: _dictionariesLabel,
      milestone: 'M10',
    ),
  ];

  static List<ShellTab> forRole(AppRole role) => switch (role) {
    AppRole.candidate => candidate,
    AppRole.employer => employer,
    AppRole.admin => admin,
  };

  // Tear-offs rather than closures, so the lists above can stay `const`.
  static String _homeLabel(AppL10n l10n) => l10n.navHome;
  static String _vacanciesLabel(AppL10n l10n) => l10n.navVacancies;
  static String _applicationsLabel(AppL10n l10n) => l10n.navApplications;
  static String _messagesLabel(AppL10n l10n) => l10n.navMessages;
  static String _profileLabel(AppL10n l10n) => l10n.navProfile;
  static String _candidatesLabel(AppL10n l10n) => l10n.navCandidates;
  static String _companyLabel(AppL10n l10n) => l10n.navCompany;
  static String _dashboardLabel(AppL10n l10n) => l10n.navDashboard;
  static String _queueLabel(AppL10n l10n) => l10n.navQueue;
  static String _complaintsLabel(AppL10n l10n) => l10n.navComplaints;
  static String _usersLabel(AppL10n l10n) => l10n.navUsers;
  static String _dictionariesLabel(AppL10n l10n) => l10n.navDictionaries;
}
