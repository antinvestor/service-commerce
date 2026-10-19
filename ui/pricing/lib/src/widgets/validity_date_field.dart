import 'package:flutter/material.dart';

import '../utils/pricing_validators.dart';

/// A tappable date field with a clear button, used for validity windows.
///
/// When [endOfDay] is set, the picked date is reported as the last second of
/// that day so a "valid until" date includes the whole day.
class ValidityDateField extends StatelessWidget {
  const ValidityDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.endOfDay = false,
    this.errorText,
    this.emptyText = 'No limit',
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool endOfDay;
  final String? errorText;
  final String emptyText;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final initial = value ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;
    onChanged(
      endOfDay
          ? DateTime(picked.year, picked.month, picked.day, 23, 59, 59)
          : DateTime(picked.year, picked.month, picked.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixIcon: value != null
              ? IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          value != null ? formatDate(value!) : emptyText,
          style: value != null
              ? theme.textTheme.bodyLarge
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
