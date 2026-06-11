import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pricing_providers.dart';

const _typeOptions = ['Percentage', 'Fixed Amount'];
const _scopeOptions = ['Order', 'Line Item'];
const _statusOptions = ['Active', 'Inactive'];
const _approvalOptions = ['No', 'Yes'];

/// Conditions Struct key holding the minimum-quantity threshold for the rule.
const _minQuantityKey = 'min_quantity';

DiscountType _typeFromLabel(String label) => label == 'Fixed Amount'
    ? DiscountType.DISCOUNT_TYPE_FIXED_AMOUNT
    : DiscountType.DISCOUNT_TYPE_PERCENTAGE;

String _labelFromType(DiscountType type) =>
    type == DiscountType.DISCOUNT_TYPE_FIXED_AMOUNT
        ? 'Fixed Amount'
        : 'Percentage';

DiscountAppliesTo _scopeFromLabel(String label) => label == 'Line Item'
    ? DiscountAppliesTo.DISCOUNT_APPLIES_TO_LINE_ITEM
    : DiscountAppliesTo.DISCOUNT_APPLIES_TO_ORDER;

String _labelFromScope(DiscountAppliesTo scope) =>
    scope == DiscountAppliesTo.DISCOUNT_APPLIES_TO_LINE_ITEM
        ? 'Line Item'
        : 'Order';

DiscountRuleStatus _statusFromLabel(String label) => label == 'Inactive'
    ? DiscountRuleStatus.DISCOUNT_RULE_STATUS_INACTIVE
    : DiscountRuleStatus.DISCOUNT_RULE_STATUS_ACTIVE;

String _labelFromStatus(DiscountRuleStatus status) =>
    status == DiscountRuleStatus.DISCOUNT_RULE_STATUS_INACTIVE
        ? 'Inactive'
        : 'Active';

double _readMinQuantity(DiscountRule rule) {
  if (!rule.hasConditions()) return 0;
  final value = rule.conditions.fields[_minQuantityKey];
  if (value == null) return 0;
  return value.hasNumberValue() ? value.numberValue : 0;
}

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
  final minQty = isEdit ? _readMinQuantity(existing) : 0.0;
  final values = await showEditDialog(
    context: context,
    title: isEdit ? 'Edit Discount Rule' : 'New Discount Rule',
    saveLabel: isEdit ? 'Save' : 'Create',
    fields: [
      DialogField(
        key: 'name',
        label: 'Name',
        required: true,
        initialValue: existing?.name ?? '',
      ),
      DialogField(
        key: 'type',
        label: 'Discount Type',
        type: DialogFieldType.dropdown,
        options: _typeOptions,
        initialValue: isEdit ? _labelFromType(existing.discountType) : 'Percentage',
      ),
      DialogField(
        key: 'value',
        label: 'Value',
        hint: 'Percent (e.g. 10) or fixed amount',
        required: true,
        initialValue: isEdit ? _trimDouble(existing.value) : '',
      ),
      DialogField(
        key: 'scope',
        label: 'Applies To',
        type: DialogFieldType.dropdown,
        options: _scopeOptions,
        initialValue: isEdit ? _labelFromScope(existing.appliesTo) : 'Order',
      ),
      DialogField(
        key: 'minQuantity',
        label: 'Minimum Quantity Threshold',
        hint: 'Leave 0 for no threshold',
        initialValue: minQty > 0 ? _trimDouble(minQty) : '0',
      ),
      DialogField(
        key: 'maxDiscountPercent',
        label: 'Max Discount Percent',
        hint: 'Cap, leave 0 for none',
        initialValue:
            isEdit && existing.maxDiscountPercent > 0 ? _trimDouble(existing.maxDiscountPercent) : '0',
      ),
      DialogField(
        key: 'requiresApproval',
        label: 'Requires Approval',
        type: DialogFieldType.dropdown,
        options: _approvalOptions,
        initialValue: isEdit && existing.requiresApproval ? 'Yes' : 'No',
      ),
      DialogField(
        key: 'status',
        label: 'Status',
        type: DialogFieldType.dropdown,
        options: _statusOptions,
        initialValue: isEdit ? _labelFromStatus(existing.status) : 'Active',
      ),
    ],
  );
  if (values == null || !context.mounted) return null;

  final name = (values['name'] ?? '').trim();
  final value = double.tryParse((values['value'] ?? '').trim());
  if (name.isEmpty || value == null) {
    _showError(context, 'Name and a numeric value are required');
    return null;
  }

  final request = DiscountRuleSaveRequest()
    ..shopId = shopId
    ..name = name
    ..discountType = _typeFromLabel(values['type'] ?? 'Percentage')
    ..value = value
    ..appliesTo = _scopeFromLabel(values['scope'] ?? 'Order')
    ..requiresApproval = (values['requiresApproval'] ?? 'No') == 'Yes'
    ..maxDiscountPercent =
        double.tryParse((values['maxDiscountPercent'] ?? '0').trim()) ?? 0
    ..status = _statusFromLabel(values['status'] ?? 'Active');
  if (isEdit) request.id = existing.id;

  final threshold = double.tryParse((values['minQuantity'] ?? '0').trim()) ?? 0;
  if (threshold > 0) {
    request.conditions = Struct(
      fields: {_minQuantityKey: Value(numberValue: threshold)},
    );
  }

  try {
    final saved =
        await ref.read(pricingNotifierProvider.notifier).saveDiscount(request);
    ref.invalidate(discountRuleListProvider(shopId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Discount rule updated' : 'Discount rule created'),
        ),
      );
    }
    return saved;
  } catch (e) {
    if (context.mounted) _showError(context, 'Error: $e');
    return null;
  }
}

String _trimDouble(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toString();
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
