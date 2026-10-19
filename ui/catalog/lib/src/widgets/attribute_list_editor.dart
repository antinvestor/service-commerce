import 'package:flutter/material.dart';

/// Editable list of key/value attribute rows.
///
/// Reports the attributes through [onChanged] on every edit; rows with an
/// empty key are left out, and a repeated key keeps its last value.
/// [initial] is read once.
class AttributeListEditor extends StatefulWidget {
  const AttributeListEditor({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  final Map<String, String> initial;
  final ValueChanged<Map<String, String>> onChanged;

  @override
  State<AttributeListEditor> createState() => _AttributeListEditorState();
}

class _AttributeRow {
  _AttributeRow(String key, String value)
    : key = TextEditingController(text: key),
      value = TextEditingController(text: value);

  final TextEditingController key;
  final TextEditingController value;

  void dispose() {
    key.dispose();
    value.dispose();
  }
}

class _AttributeListEditorState extends State<AttributeListEditor> {
  late final List<_AttributeRow> _rows = [
    for (final e in widget.initial.entries) _AttributeRow(e.key, e.value),
  ];

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _emit() {
    final result = <String, String>{};
    for (final r in _rows) {
      final k = r.key.text.trim();
      if (k.isNotEmpty) result[k] = r.value.text.trim();
    }
    widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_rows.isEmpty)
          Text(
            'No attributes.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        for (final (i, row) in _rows.indexed)
          Padding(
            key: ObjectKey(row),
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: ValueKey('attribute-key-$i'),
                    controller: row.key,
                    decoration: const InputDecoration(
                      hintText: 'Key (e.g. color)',
                      isDense: true,
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: ValueKey('attribute-value-$i'),
                    controller: row.value,
                    decoration: const InputDecoration(
                      hintText: 'Value (e.g. red)',
                      isDense: true,
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  tooltip: 'Remove attribute',
                  onPressed: () {
                    setState(() => _rows.removeAt(i));
                    // Dispose after the frame that unmounts the row's fields.
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => row.dispose(),
                    );
                    _emit();
                  },
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: () => setState(() => _rows.add(_AttributeRow('', ''))),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add attribute'),
        ),
      ],
    );
  }
}
