import 'package:flutter/material.dart';

import 'package:headhunter_app/src/core/design/design.dart';

/// A living catalogue of the design system.
///
/// This exists to be *looked at*: it renders every component in every state the
/// design draws, so a token change can be eyeballed in one place rather than
/// hunted across forty screens. It is also what makes the component library
/// reviewable against the design document before any feature is built on it.
///
/// Not a product screen. It is reachable only from the dev route and carries no
/// localized strings — the labels here are the design document's own Uzbek
/// sample copy, kept verbatim so the rendering can be compared side by side
/// with the source. Real screens take their strings from the l10n layer.
class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  int _segment = 0;
  int _navIndex = 0;
  bool _licence = true;
  bool _car = false;
  bool _visible = true;
  String _crew = 'solo';
  bool _saved = true;
  final _payController = TextEditingController(text: '5 000 000');
  final _phoneController = TextEditingController(text: '90 123 45 67');

  @override
  void dispose() {
    _payController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Design system')),
    bottomNavigationBar: HhBottomNav(
      items: HhNavSets.candidate(
        home: 'Bosh sahifa',
        vacancies: 'Vakansiyalar',
        applications: 'Arizalar',
        messages: 'Xabarlar',
        profile: 'Profil',
      ),
      currentIndex: _navIndex,
      onSelected: (i) => setState(() => _navIndex = i),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        HhSpace.gutter,
        HhSpace.lg,
        HhSpace.gutter,
        HhSpace.xxl,
      ),
      children: [
        // --- Type ---------------------------------------------------------
        const _Section('Tipografika'),
        Text('Sarlavha · display', style: HhTypography.display),
        const SizedBox(height: 4),
        Text('Ekran nomi · title', style: HhTypography.title),
        const SizedBox(height: 4),
        Text('Karta sarlavhasi · subtitle', style: HhTypography.subtitle),
        const SizedBox(height: 4),
        Text('Asosiy matn · body', style: HhTypography.body),
        const SizedBox(height: 4),
        Text('Yordamchi matn · caption', style: HhTypography.caption),
        const SizedBox(height: 4),
        Text("BO'LIM YORLIG'I · OVERLINE", style: HhTypography.overline),
        const SizedBox(height: 10),
        // Proves the bundled font covers both Uzbek scripts and Russian.
        Text(
          'Aa Бб Ўў Ққ Ғғ Ҳҳ Oʻzbekcha Ўзбекча Русский 0123',
          style: HhTypography.body.copyWith(color: HhColors.brand900),
        ),

        // --- Buttons ------------------------------------------------------
        const _Section('Buttons'),
        HhButton(label: 'Davom etish', onPressed: () {}),
        const SizedBox(height: 10),
        HhButton.secondary(label: 'Saqlash', onPressed: () {}),
        const SizedBox(height: 10),
        HhButton.tertiary(
          label: "Qo'shish",
          iconPath: HhIconPath.plus,
          onPressed: () {},
        ),
        const SizedBox(height: 10),
        HhButton.destructive(label: "O'chirish", onPressed: () {}),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: HhButton(
                label: 'Yuborilmoqda',
                loading: true,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: HhButton(label: "O'chirilgan")),
          ],
        ),
        const SizedBox(height: 10),
        HhButton.text(
          label: "Keyinroq to'ldiraman",
          onPressed: () {},
          expand: true,
        ),

        // --- Text fields --------------------------------------------------
        const _Section('Text fields'),
        const HhTextField(
          label: 'Ism va familiya',
          hintText: 'Masalan: Aziz Karimov',
        ),
        const SizedBox(height: 14),
        HhTextField(
          label: 'Telefon raqami',
          controller: _phoneController,
          prefix: '+998',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        HhTextField(
          label: 'Kutilayotgan oylik',
          controller: _payController,
          unit: "so'm / oy",
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),
        HhTextField(
          label: "Tug'ilgan sana",
          controller: TextEditingController(text: '31.02.2001'),
          trailingIconPath: HhIconPath.calendar,
          errorText: 'Bunday sana mavjud emas. Kalendardan tanlang.',
          readOnly: true,
        ),
        const SizedBox(height: 14),
        const HhTextField(
          label: 'Kompaniya nomi',
          enabled: false,
          disabledHint: 'Tasdiqlashdan keyin ochiladi',
        ),

        // --- Selection ----------------------------------------------------
        const _Section('Selection & chips'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            HhFilterChip(label: 'Toshkent', selected: true, onTap: () {}),
            HhFilterChip(label: 'Samarqand', selected: false, onTap: () {}),
            HhFilterChip(label: "Farg'ona", selected: false, onTap: () {}),
            HhRemovableChip(label: "To'liq stavka", onRemove: () {}),
          ],
        ),
        const SizedBox(height: HhSpace.lg),
        HhSegmented(
          labels: const ['Faol', 'Tarix'],
          selectedIndex: _segment,
          onChanged: (i) => setState(() => _segment = i),
        ),
        const SizedBox(height: HhSpace.md),
        HhCheckboxRow(
          label: 'Haydovchilik guvohnomasi bor',
          value: _licence,
          onChanged: (v) => setState(() => _licence = v),
        ),
        HhCheckboxRow(
          label: 'Shaxsiy avtomobilim bor',
          value: _car,
          onChanged: (v) => setState(() => _car = v),
        ),
        HhRadioRow<String>(
          label: 'Yakka tartibda ishlayman',
          value: 'solo',
          groupValue: _crew,
          onChanged: (v) => setState(() => _crew = v),
        ),
        HhRadioRow<String>(
          label: 'Brigada bilan ishlayman',
          value: 'crew',
          groupValue: _crew,
          onChanged: (v) => setState(() => _crew = v),
        ),
        HhSwitchRow(
          label: "Qidiruvda ko'rinsin",
          value: _visible,
          onChanged: (v) => setState(() => _visible = v),
        ),

        // --- Badges -------------------------------------------------------
        const _Section('Status badges'),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            HhBadge.verified(label: 'Tasdiqlangan'),
            HhBadge.pending(label: "Ko'rib chiqilmoqda"),
            HhBadge.rejected(label: 'Rad etildi'),
            HhBadge.info(label: 'Yangi'),
            HhBadge.paused(label: "To'xtatilgan"),
            HhBadge.changesRequired(label: "O'zgartirish talab qilinadi"),
          ],
        ),

        // --- Progress -----------------------------------------------------
        const _Section('Step indicator & completeness'),
        const HhStepIndicator(
          step: 4,
          total: 9,
          stepLabel: '4-qadam / 9',
          sectionName: "Ko'nikmalar",
        ),
        const SizedBox(height: HhSpace.lg),
        const HhCompletenessRing(
          percent: 72,
          title: "Profil to'ldirilgan",
          subtitle: 'Rezyume va til darajasi qoldi',
          surfaceColor: HhColors.sand100,
        ),

        // --- Cards --------------------------------------------------------
        const _Section('Cards'),
        HhVacancyCard(
          title: 'Call-markaz operatori',
          employer: 'Anor Telecom',
          pay: "4 500 000 – 6 000 000 so'm",
          metaChips: hhVacancyMeta(
            location: 'Toshkent',
            schedule: 'Smenali',
            openings: "20 o'rin",
          ),
          verifiedLabel: 'Tasdiqlangan ish beruvchi',
          publishedLabel: '2 kun oldin',
          saved: _saved,
          onToggleSave: () => setState(() => _saved = !_saved),
          onTap: () {},
        ),
        const SizedBox(height: HhSpace.md),
        HhCandidateCard(
          name: 'Dilnoza Rahimova',
          headline: 'Call-markaz operatori · 2 yil tajriba',
          matchLabel: '88% mos',
          chips: const [
            HhMetaChip(label: 'Rus tili C1', dense: true),
            HhMetaChip(label: 'Toshkent', dense: true),
            HhMetaChip(label: 'Hozir tayyor', dense: true),
          ],
          onTap: () {},
        ),
        const SizedBox(height: HhSpace.md),
        const HhApplicationCard(
          title: 'Sotuvchi-maslahatchi',
          subtitle: 'Nur Market · 12-avgust',
          stageBadge: HhBadge.info(label: 'Suhbat'),
          stages: [
            'Yuborildi',
            "Ko'rildi",
            'Suhbat',
            'Taklif',
            'Qabul',
          ],
          currentStageIndex: 2,
        ),

        // --- States -------------------------------------------------------
        const _Section('Required UI states'),
        const _StateLabel('01 · Skeleton'),
        const HhVacancyCardSkeleton(),
        const SizedBox(height: HhSpace.md),
        const _StateLabel('02 · Pagination'),
        const HhLoadingMore(label: 'Yana 12 ta yuklanmoqda…'),
        const _StateLabel('03 · Empty'),
        HhEmptyState(
          title: "Hozircha saqlangan vakansiya yo'q",
          message:
              "Yoqqan vakansiyani belgilab qo'ying — bu yerda to'planadi va "
              'keyin ariza topshirasiz.',
          actionLabel: "Vakansiyalarni ko'rish",
          onAction: () {},
        ),
        const SizedBox(height: HhSpace.md),
        const _StateLabel('04 · Offline'),
        const HhOfflineBanner(
          title: "Internet aloqasi yo'q",
          message:
              "Kiritilgan ma'lumotlar saqlanib turibdi. Aloqa tiklanganda "
              'yuboriladi.',
        ),
        const SizedBox(height: HhSpace.md),
        const _StateLabel('05 · Server error'),
        HhErrorState(
          title: 'Server xatosi',
          message:
              "Ma'lumotlarni yuklab bo'lmadi. Birozdan so'ng qayta urinib "
              "ko'ring.",
          retryLabel: 'Qayta urinish',
          onRetry: () {},
        ),
        const SizedBox(height: HhSpace.md),
        const _StateLabel('06-08, 10 · Notices'),
        const HhNotice.permission(
          title: 'Joylashuvga ruxsat berilmagan',
          message:
              "Yaqin atrofdagi vakansiyalarni ko'rsatish uchun joylashuv "
              'kerak.',
        ),
        const SizedBox(height: HhSpace.sm),
        const HhNotice.pending(
          title: 'Moderatsiya kutilmoqda',
          message: "Vakansiya tasdiqlangach nomzodlarga ko'rinadi.",
        ),
        const SizedBox(height: HhSpace.sm),
        const HhNotice.restricted(
          title: 'Amal cheklangan',
          message:
              'Hisobingiz vaqtincha cheklangan. Sabab: qoidalar buzilishi.',
        ),
        const SizedBox(height: HhSpace.sm),
        const HhNotice.expired(
          title: "Muddati o'tgan",
          message: 'Ariza qabul qilish muddati tugagan.',
        ),
        const SizedBox(height: HhSpace.md),
        const _StateLabel('09 · Destructive confirm / 11 · Toast'),
        Row(
          children: [
            Expanded(
              child: HhButton.destructive(
                label: "O'chirish",
                compact: true,
                onPressed: () => HhConfirmDialog.show(
                  context,
                  title: "Rezyumeni o'chirish",
                  message:
                      "Fayl butunlay o'chiriladi va ish beruvchilar uni "
                      "ko'ra olmaydi.",
                  confirmLabel: "Ha, o'chirish",
                  cancelLabel: 'Bekor qilish',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: HhButton.secondary(
                label: 'Toast',
                compact: true,
                onPressed: () => HhToast.show(
                  context,
                  message: 'Ariza yuborildi',
                  actionLabel: "Ko'rish",
                  onAction: () {},
                ),
              ),
            ),
          ],
        ),

        // --- Icons --------------------------------------------------------
        const _Section('Ikonkalar'),
        const _IconGrid(),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: HhSpace.sectionGap, bottom: HhSpace.md),
    child: Row(
      children: [
        Text(title.toUpperCase(), style: HhTypography.overline),
        const SizedBox(width: HhSpace.md),
        const Expanded(child: Divider()),
      ],
    ),
  );
}

class _StateLabel extends StatelessWidget {
  const _StateLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      label,
      style: HhTypography.meta.copyWith(color: HhColors.inkSubtle),
    ),
  );
}

class _IconGrid extends StatelessWidget {
  const _IconGrid();

  static const _icons = <String, String>{
    'home': HhIconPath.home,
    'briefcase': HhIconPath.briefcase,
    'document': HhIconPath.document,
    'chat': HhIconPath.chat,
    'person': HhIconPath.person,
    'people': HhIconPath.people,
    'building': HhIconPath.building,
    'search': HhIconPath.search,
    'filters': HhIconPath.filters,
    'bookmark': HhIconPath.bookmark,
    'upload': HhIconPath.upload,
    'edit': HhIconPath.edit,
    'trash': HhIconPath.trash,
    'send': HhIconPath.send,
    'refresh': HhIconPath.refresh,
    'plus': HhIconPath.plus,
    'close': HhIconPath.close,
    'check': HhIconPath.check,
    'more': HhIconPath.more,
    'pause': HhIconPath.pause,
    'location': HhIconPath.location,
    'clock': HhIconPath.clock,
    'wallet': HhIconPath.wallet,
    'calendar': HhIconPath.calendar,
    'car': HhIconPath.car,
    'tool': HhIconPath.tool,
    'globe': HhIconPath.globe,
    'eye': HhIconPath.eye,
    'lock': HhIconPath.lock,
    'bell': HhIconPath.bell,
    'shield': HhIconPath.shieldCheck,
    'check-circle': HhIconPath.checkCircle,
    'x-circle': HhIconPath.xCircle,
    'info': HhIconPath.infoCircle,
    'alert': HhIconPath.alertTriangle,
    'wifi-off': HhIconPath.wifiOff,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    decoration: const BoxDecoration(
      color: HhColors.sand50,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: Wrap(
      spacing: 18,
      runSpacing: 18,
      children: [
        for (final entry in _icons.entries)
          SizedBox(
            width: 52,
            child: Column(
              children: [
                HhIcon(entry.value),
                const SizedBox(height: 5),
                Text(
                  entry.key,
                  style: HhTypography.meta.copyWith(
                    fontSize: 8.5,
                    color: HhColors.inkSubtle,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
