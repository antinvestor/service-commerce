import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
// FieldMask is not re-exported by the commerce barrel.
// ignore: implementation_imports
import 'package:antinvestor_ui_core/widgets/money_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';
import '../utils/discount_conditions.dart';
import '../utils/pricing_validators.dart';
import '../widgets/discount_approval_status.dart';
import '../widgets/discount_conditions_editor.dart';
import '../widgets/validity_date_field.dart';

const _typeLabels = {
  DiscountType.DISCOUNT_TYPE_PERCENTAGE: 'Percentage',
  DiscountType.DISCOUNT_TYPE_FIXED_AMOUNT: 'Fixed Amount',
};

const _scopeLabels = {
  DiscountAppliesTo.DISCOUNT_APPLIES_TO_ORDER: 'Order',
  DiscountAppliesTo.DISCOUNT_APPLIES_TO_LINE_ITEM: 'Line Item',
};

const _statusLabels = {
  DiscountRuleStatus.DISCOUNT_RULE_STATUS_ACTIVE: 'Active',
  DiscountRuleStatus.DISCOUNT_RULE_STATUS_INACTIVE: 'Inactive',
};

/// Shows the discount-rule create/edit dialog and persists it via
/// [PricingNotifier.saveDiscount]. Pass [existing] to edit. Returns the saved
/// rule, or null if cancelled / failed.
Future<DiscountRule?> showDiscountRuleForm({
  required BuildContext context,
  required WidgetRef ref,
  required String shopId,
  DiscountRule? existing,
}) async {
  final isEdit = existing != null;
  final request = await showDialog<DiscountRuleSaveRequest>(
    context: context,
    builder: (_) => DiscountRuleFormDialog(shopId: shopId, existing: existing),
  );
  if (request == null || !context.mounted) return null;

  try {
    final saved = await ref
        .read(pricingNotifierProvider.notifier)
        .saveDiscount(request);
    ref.invalidate(discountRuleListProvider(shopId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Discount rule updated' : 'Discount rule created',
          ),
        ),
      );
    }
    return saved;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    return null;
  }
}

/// Builds the conditions Struct to save: the supported keys from
/// [conditions], plus any unsupported keys from [original] unless
/// [dropUnsupported] is set. Unsupported keys are kept by default because
/// silently dropping a restriction would widen who gets the discount.
Struct buildConditionsStruct(
  DiscountConditions conditions, {
  Struct? original,
  bool dropUnsupported = false,
}) {
  final struct = conditions.toStruct();
  if (!dropUnsupported && original != null) {
    for (final entry in original.fields.entries) {
      if (!supportedConditionKeys.contains(entry.key)) {
        struct.fields[entry.key] = entry.value;
      }
    }
  }
  return struct;
}

/// Form dialog that pops a [DiscountRuleSaveRequest] on save.
class DiscountRuleFormDialog extends StatefulWidget {
  const DiscountRuleFormDialog({
    super.key,
    required this.shopId,
    this.existing,
  });

  final String shopId;
  final DiscountRule? existing;

  @override
  State<DiscountRuleFormDialog> createState() => _DiscountRuleFormDialogState();
}

class _DiscountRuleFormDialogState extends State<DiscountRuleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _value;
  late final TextEditingController _maxPercent;
  late DiscountType _type;
  late DiscountAppliesTo _scope;
  late DiscountRuleStatus _status;
  late bool _requiresApproval;
  late DiscountConditions _conditions;
  bool _dropUnsupported = false;
  DateTime? _validFrom;
  DateTime? _validUntil;
  String? _rangeError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _value = TextEditingController(text: e != null ? _trimDouble(e.value) : '');
    _maxPercent = TextEditingController(
      text: e != null && e.maxDiscountPercent > 0
          ? _trimDouble(e.maxDiscountPercent)
          : '',
    );
    _type = e != null && _typeLabels.containsKey(e.discountType)
        ? e.discountType
        : DiscountType.DISCOUNT_TYPE_PERCENTAGE;
    _scope = e != null && _scopeLabels.containsKey(e.appliesTo)
        ? e.appliesTo
        : DiscountAppliesTo.DISCOUNT_APPLIES_TO_ORDER;
    _status = e != null && _statusLabels.containsKey(e.status)
        ? e.status
        : DiscountRuleStatus.DISCOUNT_RULE_STATUS_ACTIVE;
    _requiresApproval = e?.requiresApproval ?? false;
    _conditions = DiscountConditions.fromStruct(
      e != null && e.hasConditions() ? e.conditions : null,
    );
    _validFrom = e != null
        ? timestampToDate(e.hasValidFrom(), e.validFrom)
        : null;
    _validUntil = e != null
        ? timestampToDate(e.hasValidUntil(), e.validUntil)
        : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    _maxPercent.dispose();
    super.dispose();
  }

  void _submit() {
    final rangeError = validateValidityRange(_validFrom, _validUntil);
    setState(() => _rangeError = rangeError);
    if (!_formKey.currentState!.validate() || rangeError != null) return;

    final e = widget.existing;
    final request = DiscountRuleSaveRequest()
      ..shopId = widget.shopId
      ..name = _name.text.trim()
      ..discountType = _type
      ..value = double.parse(_value.text.trim())
      ..appliesTo = _scope
      ..requiresApproval = _requiresApproval
      ..maxDiscountPercent = double.tryParse(_maxPercent.text.trim()) ?? 0
      ..status = _status;
    final conditions = buildConditionsStruct(
      _conditions,
      original: e != null && e.hasConditions() ? e.conditions : null,
      dropUnsupported: _dropUnsupported,
    );
    if (conditions.fields.isNotEmpty) request.conditions = conditions;
    if (_validFrom != null) request.validFrom = dateToTimestamp(_validFrom!);
    if (_validUntil != null) request.validUntil = dateToTimestamp(_validUntil!);
    if (e != null) request.id = e.id;
    // A plain update can only add the approval requirement; dropping it is
    // an explicit, masked change the server reserves for approvers.
    if (e != null && e.requiresApproval && !_requiresApproval) {
      request.updateMask = FieldMask(paths: const ['requires_approval']);
    }
    Navigator.of(context).pop(request);
  }

  String? _validateValue(String? v) {
    final n = double.tryParse(v?.trim() ?? '');
    if (n == null || n <= 0) return 'Enter a positive number';
    if (_type == DiscountType.DISCOUNT_TYPE_PERCENTAGE && n > 100) {
      return 'A percentage cannot exceed 100';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final existing = widget.existing;
    final isEdit = existing != null;
    final unsupported = _conditions.unsupportedKeys;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Discount Rule' : 'New Discount Rule'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => validateRequired(v, 'Name'),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<DiscountType>(
                        isExpanded: true,
                        initialValue: _type,
                        decoration: const InputDecoration(
                          labelText: 'Discount Type',
                        ),
                        items: [
                          for (final e in _typeLabels.entries)
                            DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? _type),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _value,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Value',
                          suffixText:
                              _type == DiscountType.DISCOUNT_TYPE_PERCENTAGE
                              ? '%'
                              : null,
                        ),
                        validator: _validateValue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DiscountAppliesTo>(
                  isExpanded: true,
                  initialValue: _scope,
                  decoration: const InputDecoration(labelText: 'Applies To'),
                  items: [
                    for (final e in _scopeLabels.entries)
                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: (v) => setState(() => _scope = v ?? _scope),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxPercent,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Max Discount Percent',
                    helperText: 'Cap; leave empty for none',
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return null;
                    final n = double.tryParse(t);
                    if (n == null || n < 0 || n > 100) {
                      return 'Enter a percentage between 0 and 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ValidityDateField(
                  label: 'Valid From',
                  value: _validFrom,
                  emptyText: 'Immediately',
                  onChanged: (d) => setState(() => _validFrom = d),
                ),
                const SizedBox(height: 16),
                ValidityDateField(
                  label: 'Valid Until',
                  value: _validUntil,
                  endOfDay: true,
                  errorText: _rangeError,
                  onChanged: (d) => setState(() => _validUntil = d),
                ),
                const SizedBox(height: 20),
                DiscountConditionsEditor(
                  initial: _conditions,
                  onChanged: (c) => _conditions = c,
                ),
                if (unsupported.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withAlpha(80),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This rule has conditions the pricing engine does '
                          'not understand (${unsupported.join(', ')}), so it '
                          'is never applied automatically.',
                          style: theme.textTheme.bodySmall,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          value: _dropUnsupported,
                          onChanged: (v) =>
                              setState(() => _dropUnsupported = v ?? false),
                          title: const Text('Remove unsupported conditions'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _requiresApproval,
                  onChanged: (v) => setState(() => _requiresApproval = v),
                  title: const Text('Requires approval'),
                  subtitle: Text(
                    isEdit && existing.requiresApproval
                        ? 'Not applied until approved. Turning this off '
                              'needs discount approval permission.'
                        : 'Not applied until someone with discount approval '
                              'approves it',
                  ),
                ),
                if (isEdit &&
                    DiscountApprovalState.of(existing) ==
                        DiscountApprovalState.approved)
                  Text(
                    'Changing the value, type or conditions clears the '
                    'approval.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 8),
                DropdownButtonFormField<DiscountRuleStatus>(
                  isExpanded: true,
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    for (final e in _statusLabels.entries)
                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}

String _trimDouble(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toString();
}
