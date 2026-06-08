import 'package:antinvestor_api_profile/antinvestor_api_profile.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter/material.dart';

/// An embeddable search-and-select widget for customers.
///
/// Wraps [ProfileSearchSelect] from ui_profile with a commerce-specific
/// label and optional customer-type filtering.
class CustomerSearchSelect extends StatelessWidget {
  const CustomerSearchSelect({
    super.key,
    required this.onSelected,
    this.label = 'Search customers',
    this.initialQuery = '',
    this.autofocus = false,
  });

  final ValueChanged<ProfileObject> onSelected;
  final String label;
  final String initialQuery;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ProfileSearchSelect(
      onSelected: onSelected,
      label: label,
      initialQuery: initialQuery,
      autofocus: autofocus,
    );
  }
}
