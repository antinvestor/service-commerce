import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';

final _entityIdPattern = RegExp(r'^[0-9a-z_-]{3,40}$');

/// Validates a commerce/profile entity ID (3-40 chars of `[0-9a-z_-]`), the
/// same shape the backend enforces on customer and variant IDs.
String? validateEntityId(String? value, [String field = 'ID']) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return '$field is required';
  if (!_entityIdPattern.hasMatch(v)) {
    return '$field must be 3-40 lowercase letters, digits, "-" or "_"';
  }
  return null;
}

/// Like [validateEntityId] but an empty value is allowed.
String? validateOptionalEntityId(String? value, [String field = 'ID']) {
  if (value == null || value.trim().isEmpty) return null;
  return validateEntityId(value, field);
}

/// Validates that each ID in a comma/space separated list is well formed.
String? validateEntityIdList(List<String> ids, [String field = 'ID']) {
  for (final id in ids) {
    if (!_entityIdPattern.hasMatch(id)) return 'Invalid $field: $id';
  }
  return null;
}

/// Returns an error when [until] is not after [from].
String? validateValidityRange(DateTime? from, DateTime? until) {
  if (from != null && until != null && !until.isAfter(from)) {
    return 'Valid until must be after valid from';
  }
  return null;
}

/// Reads an optional proto [Timestamp] into a local [DateTime].
DateTime? timestampToDate(bool hasValue, Timestamp ts) =>
    hasValue ? ts.toDateTime().toLocal() : null;

/// Converts a picked date to a UTC [Timestamp].
Timestamp dateToTimestamp(DateTime date) =>
    Timestamp.fromDateTime(date.toUtc());

/// Formats a date as `YYYY-MM-DD`.
String formatDate(DateTime date) {
  final d = date.toLocal();
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Formats a date and time as `YYYY-MM-DD HH:MM`.
String formatDateTime(DateTime date) {
  final d = date.toLocal();
  return '${formatDate(d)} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}
