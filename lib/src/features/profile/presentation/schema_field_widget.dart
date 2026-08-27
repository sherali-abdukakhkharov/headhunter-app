import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobbridge_app/l10n/generated/app_l10n.dart';
import 'package:jobbridge_app/src/core/design/design.dart';
import 'package:jobbridge_app/src/features/dictionaries/presentation/dictionary_picker.dart';
import 'package:jobbridge_app/src/features/profile/domain/field_schema.dart';
import 'package:jobbridge_app/src/features/profile/presentation/leveled_field_editor.dart';

/// Renders one schema field, chosen by [SchemaField.kind].
///
/// ## The contract this widget keeps
///
/// **Values go in and come out in exactly the shape the API uses.** The
/// profile's `fields` map is "shaped exactly as PATCH accepts", so the engine
/// reads a value straight out of it, hands it to a widget, and puts whatever
/// comes back straight into the write body. No translation layer in either
/// direction, and therefore no place for the two to disagree.
///
/// So: a `date` is an ISO `yyyy-MM-dd` string, a `dictionary_multi` is a
/// `List<String>` of ids, a `money_range` is the four-key object §4.3 defines.
///
/// **An unknown kind renders nothing.** It never reaches here — the section
/// filters it out — but the switch still has the arm, because the alternative
/// is an exhaustiveness error the day the union grows.
class SchemaFieldWidget extends StatelessWidget {
  const SchemaFieldWidget({
    required this.field,
    required this.value,
    required this.onChanged,
    super.key,
    this.parentValue,
    this.errorText,
    this.enabled = true,
  });

  final SchemaField field;

  /// The current value, in wire shape. Null when unset.
  final Object? value;

  final ValueChanged<Object?> onChanged;

  /// The value of [SchemaField.parentFieldCode], when this field declares one.
  /// Drives the cascade without the engine knowing what a district is.
  final Object? parentValue;

  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return switch (field.kind) {
      FieldKind.text ||
      FieldKind.url ||
      FieldKind.phone => _text(context, maxLines: 1),
      FieldKind.longText => _text(context, maxLines: 4),
      FieldKind.int_ => _number(context, decimal: false),
      FieldKind.decimal => _number(context, decimal: true),
      FieldKind.bool_ => HhSwitchRow(
        label: field.label,
        // Absent is not the same as false to the server, but it is the same to
        // a switch - there is no third position. Rendering null as off and
        // sending a real boolean is the only honest mapping.
        value: value == true,
        onChanged: enabled ? onChanged : null,
      ),
      FieldKind.date => _date(context),
      FieldKind.dictionarySingle => HhDictionaryPicker(
        label: _labelWithRequired(l10n),
        type: field.dictionaryType ?? '',
        value: value as String?,
        errorText: errorText,
        enabled: enabled,
        // The schema declares the hierarchy; the engine just relays it.
        parentScoped: field.parentFieldCode != null || _isHierarchical,
        parentId: parentValue as String?,
        requiresParentLabel: field.parentFieldCode == null
            ? null
            : l10n.profileChooseParentFirst,
        onChanged: onChanged,
      ),
      FieldKind.dictionaryMulti => HhDictionaryMultiPicker(
        label: _labelWithRequired(l10n),
        type: field.dictionaryType ?? '',
        values: (value as List<dynamic>? ?? const []).cast<String>().toList(),
        errorText: errorText,
        enabled: enabled,
        onChanged: onChanged,
      ),
      FieldKind.moneyRange => _money(context),
      FieldKind.dictionaryLeveled => LeveledFieldEditor(
        field: field,
        rows: [
          for (final row in value as List<dynamic>? ?? const [])
            Map<String, dynamic>.from(row as Map),
        ],
        errorText: errorText,
        enabled: enabled,
        onChanged: onChanged,
      ),

      // `date_range` is declared by the contract but no candidate-profile field
      // uses it yet - it arrives with M5. Rendered as an explicit notice rather
      // than omitted, because a silently missing field looks like a complete
      // form and the completeness percentage would then be inexplicable.
      FieldKind.dateRange => HhNotice.pending(
        title: field.label,
        message: l10n.profileFieldNotEditableYet,
      ),

      FieldKind.unknown => const SizedBox.shrink(),
    };
  }

  /// A region picker is "items with no parent", not the whole type — see
  /// `HhDictionaryPicker.parentScoped`. A field that is somebody's parent is
  /// therefore itself scoped.
  bool get _isHierarchical => field.code == 'region_id';

  String _labelWithRequired(AppL10n l10n) =>
      field.required ? '${field.label} *' : field.label;

  Widget _text(BuildContext context, {required int maxLines}) => HhTextField(
    label: _labelWithRequired(AppL10n.of(context)),
    controller: _controllerFor(value as String? ?? ''),
    maxLines: maxLines,
    maxLength: field.validation?.maxLength,
    enabled: enabled,
    errorText: errorText,
    keyboardType: switch (field.kind) {
      FieldKind.url => TextInputType.url,
      FieldKind.phone => TextInputType.phone,
      FieldKind.longText => TextInputType.multiline,
      _ => TextInputType.text,
    },
    // Empty means "clear this field", which is a legitimate write - so it is
    // sent as null rather than as an empty string the server would store.
    onChanged: (text) => onChanged(text.trim().isEmpty ? null : text),
  );

  /// The schema's own bounds, checked as the value is typed (BR-05).
  ///
  /// `validation.min` and `.max` were declared and never applied, so a worker
  /// count of 0 - the one BR-05 names - cost a round trip and came back in the
  /// page's error state rather than on the field. The rule is general: every
  /// bounded field in the schema had the same problem.
  ///
  /// **The server stays authoritative.** This saves the trip and puts the
  /// message where the value is; it does not decide anything the server would
  /// not have decided.
  String? _boundsError(AppL10n l10n) {
    final number = switch (value) {
      final num n => n,
      _ => null,
    };
    if (number == null) return null;

    final validation = field.validation;
    final min = validation?.min;
    final max = validation?.max;

    if (min != null && number < min) return l10n.fieldAtLeast(_plain(min));
    if (max != null && number > max) return l10n.fieldAtMost(_plain(max));

    return null;
  }

  /// `1` rather than `1.0`: the bound is declared as a double because one
  /// schema type covers int and decimal, and a whole number reads as one.
  static String _plain(double bound) =>
      bound == bound.roundToDouble() ? bound.toInt().toString() : '$bound';

  Widget _number(BuildContext context, {required bool decimal}) => HhTextField(
    label: _labelWithRequired(AppL10n.of(context)),
    controller: _controllerFor(value?.toString() ?? ''),
    enabled: enabled,
    // The server's refusal wins when there is one: it may know something the
    // declaration does not.
    errorText: errorText ?? _boundsError(AppL10n.of(context)),
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        decimal ? RegExp(r'[\d.]') : RegExp(r'\d'),
      ),
    ],
    onChanged: (text) {
      if (text.trim().isEmpty) return onChanged(null);
      // Unparseable input is left alone rather than coerced to zero: zero is a
      // value somebody may have meant, and inventing it loses what they typed.
      final parsed = decimal ? double.tryParse(text) : int.tryParse(text);
      if (parsed != null) onChanged(parsed);
    },
  );

  Widget _date(BuildContext context) {
    final l10n = AppL10n.of(context);
    final current = _parseIsoDate(value as String?);

    return HhTextField(
      label: _labelWithRequired(l10n),
      readOnly: true,
      enabled: enabled,
      errorText: errorText,
      hintText: l10n.profileDateHint,
      trailingIconPath: HhIconPath.calendar,
      trailingSemanticLabel: l10n.commonPickDate,
      controller: TextEditingController(text: value as String? ?? ''),
      onTap: enabled ? () => _pickDate(context, current) : null,
      onTrailingTap: enabled ? () => _pickDate(context, current) : null,
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 25),
      // Wide enough for a birth date at one end and an availability date at the
      // other. The server owns the real rule (`notAfter`, `minAgeYears`) and
      // says so in its own words, so clamping here would only ever be wrong in
      // a way the user cannot read.
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null) return;
    // ISO `yyyy-MM-dd`, which is what the wire uses. Never a localized format:
    // the value is data, not display.
    onChanged(
      '${picked.year.toString().padLeft(4, '0')}-'
      '${picked.month.toString().padLeft(2, '0')}-'
      '${picked.day.toString().padLeft(2, '0')}',
    );
  }

  Widget _money(BuildContext context) {
    final l10n = AppL10n.of(context);
    final money = (value as Map<String, dynamic>?) ?? const {};
    final from = money['from'] as num?;
    final to = money['to'] as num?;
    final negotiable = money['isNegotiable'] as bool? ?? false;

    void emit({
      Object? newFrom = _unset,
      Object? newTo = _unset,
      bool? newNegotiable,
    }) {
      onChanged({
        ...money,
        if (newFrom != _unset) 'from': newFrom,
        if (newTo != _unset) 'to': newTo,
        'isNegotiable': ?newNegotiable,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_labelWithRequired(l10n), style: HhTypography.subtitle),
        const SizedBox(height: HhSpace.md),
        Row(
          children: [
            Expanded(
              child: HhTextField(
                label: l10n.profileSalaryFrom,
                controller: _controllerFor(from?.toString() ?? ''),
                enabled: enabled && !negotiable,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                // From the schema, never hardcoded - the contract says so.
                unit: field.currency,
                onChanged: (t) => emit(newFrom: int.tryParse(t)),
              ),
            ),
            const SizedBox(width: HhSpace.md),
            Expanded(
              child: HhTextField(
                label: l10n.profileSalaryTo,
                controller: _controllerFor(to?.toString() ?? ''),
                enabled: enabled && !negotiable,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                unit: field.currency,
                onChanged: (t) => emit(newTo: int.tryParse(t)),
              ),
            ),
          ],
        ),
        if (field.allowNegotiable ?? false) ...[
          const SizedBox(height: HhSpace.md),
          HhCheckboxRow(
            label: l10n.profileSalaryNegotiable,
            value: negotiable,
            onChanged: enabled ? (v) => emit(newNegotiable: v) : null,
          ),
        ],
        if (errorText case final message?) ...[
          const SizedBox(height: 6),
          Text(
            message,
            style: HhTypography.caption.copyWith(color: HhColors.error),
          ),
        ],
      ],
    );
  }

  /// Sentinel so the money emitter can tell "leave this key alone" from "set it
  /// to null" - for money that is the difference between not touching the lower
  /// bound and clearing it.
  static const _unset = Object();

  /// A controller seeded with the current value, caret parked at the end.
  ///
  /// Rebuilt each frame, which is fine because these fields are only rebuilt
  /// when their own value changes — but the caret would otherwise jump to the
  /// start on every keystroke.
  static TextEditingController _controllerFor(String text) =>
      TextEditingController.fromValue(
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      );

  static DateTime? _parseIsoDate(String? value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } on FormatException {
      debugPrint('[schema] unparseable date: $value');
      return null;
    }
  }
}
