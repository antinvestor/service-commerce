import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
// FieldMask is not re-exported by the commerce barrel, so it is imported
// from its generated source to build a precise update mask.
// ignore: implementation_imports
import 'package:antinvestor_api_commerce/src/google/protobuf/field_mask.pb.dart'
    show FieldMask;
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/order_providers.dart';
import '../utils/instalments.dart';
import 'fulfilment_status_badge.dart';
import 'order_payment_dialogs.dart' show paymentErrorMessage;

/// The forward path a fulfilment moves along.
const fulfilmentStatusFlow = [
  FulfilmentStatus.FULFILMENT_STATUS_PENDING,
  FulfilmentStatus.FULFILMENT_STATUS_PREPARING,
  FulfilmentStatus.FULFILMENT_STATUS_PACKED,
  FulfilmentStatus.FULFILMENT_STATUS_SHIPPED,
  FulfilmentStatus.FULFILMENT_STATUS_DELIVERED,
];

/// Statuses a fulfilment in [current] may move to: any later step of
/// [fulfilmentStatusFlow], or cancelled until it is delivered. Delivered and
/// cancelled are final.
List<FulfilmentStatus> nextFulfilmentStatuses(FulfilmentStatus current) {
  if (current == FulfilmentStatus.FULFILMENT_STATUS_DELIVERED ||
      current == FulfilmentStatus.FULFILMENT_STATUS_CANCELLED) {
    return const [];
  }
  final index = fulfilmentStatusFlow.indexOf(current);
  return [
    ...fulfilmentStatusFlow.skip(index < 0 ? 0 : index + 1),
    FulfilmentStatus.FULFILMENT_STATUS_CANCELLED,
  ];
}

String fulfilmentStatusLabel(FulfilmentStatus s) => switch (s) {
  FulfilmentStatus.FULFILMENT_STATUS_PENDING => 'Pending',
  FulfilmentStatus.FULFILMENT_STATUS_PREPARING => 'Preparing',
  FulfilmentStatus.FULFILMENT_STATUS_PACKED => 'Packed',
  FulfilmentStatus.FULFILMENT_STATUS_SHIPPED => 'Shipped',
  FulfilmentStatus.FULFILMENT_STATUS_DELIVERED => 'Delivered',
  FulfilmentStatus.FULFILMENT_STATUS_CANCELLED => 'Cancelled',
  _ => 'Unknown',
};

/// Lists every fulfilment of an order (ListFulfilments) with its status,
/// carrier and tracking, and lets staff open details or update one.
class OrderFulfilmentsPanel extends ConsumerWidget {
  const OrderFulfilmentsPanel({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncFulfilments = ref.watch(orderFulfilmentsProvider(orderId));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Fulfilments',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh fulfilments',
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: () =>
                    ref.invalidate(orderFulfilmentsProvider(orderId)),
              ),
            ],
          ),
          asyncFulfilments.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              'Could not load fulfilments: ${friendlyError(e)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            data: (fulfilments) => fulfilments.isEmpty
                ? Text(
                    'No fulfilments yet',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : Column(
                    children: fulfilments
                        .map((f) => FulfilmentTile(fulfilment: f))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// One fulfilment row: status, carrier/tracking, and update action.
class FulfilmentTile extends StatelessWidget {
  const FulfilmentTile({super.key, required this.fulfilment});

  final Fulfilment fulfilment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = fulfilment;
    final details = <String>[
      if (f.carrier.isNotEmpty) f.carrier,
      if (f.trackingNumber.isNotEmpty) 'Tracking ${f.trackingNumber}',
      '${f.lines.length} line${f.lines.length == 1 ? '' : 's'}',
      if (f.hasCreatedAt())
        'Created ${formatDateTime(f.createdAt.toDateTime())}',
    ];
    final canUpdate = nextFulfilmentStatuses(f.status).isNotEmpty;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => showFulfilmentDetailsDialog(context, f.id),
      leading: Icon(
        Icons.inventory_2_outlined,
        color: theme.colorScheme.primary,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              f.id,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          FulfilmentStatusBadge(status: f.status),
        ],
      ),
      subtitle: Text(details.join(' · '), style: theme.textTheme.bodySmall),
      trailing: canUpdate
          ? TextButton(
              onPressed: () => showUpdateFulfilmentDialog(context, f),
              child: const Text('Update'),
            )
          : null,
    );
  }
}

/// Shows a fulfilment fetched fresh with GetFulfilment, offering to update
/// it when it can still move forward.
Future<void> showFulfilmentDetailsDialog(
  BuildContext context,
  String fulfilmentId,
) async {
  final toUpdate = await showDialog<Fulfilment>(
    context: context,
    builder: (_) => _FulfilmentDetailsDialog(fulfilmentId: fulfilmentId),
  );
  if (toUpdate != null && context.mounted) {
    await showUpdateFulfilmentDialog(context, toUpdate);
  }
}

class _FulfilmentDetailsDialog extends ConsumerWidget {
  const _FulfilmentDetailsDialog({required this.fulfilmentId});

  final String fulfilmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncFulfilment = ref.watch(fulfilmentByIdProvider(fulfilmentId));
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
    return AlertDialog(
      title: const Text('Fulfilment'),
      content: SizedBox(
        width: 380,
        child: asyncFulfilment.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text(
            friendlyError(e),
            style: TextStyle(color: theme.colorScheme.error),
          ),
          data: (f) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row('ID', f.id),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FulfilmentStatusBadge(status: f.status),
              ),
              row('Carrier', f.carrier.isEmpty ? '—' : f.carrier),
              row(
                'Tracking',
                f.trackingNumber.isEmpty ? '—' : f.trackingNumber,
              ),
              if (f.hasCreatedAt())
                row('Created', formatDateTime(f.createdAt.toDateTime())),
              if (f.hasShippedAt())
                row('Shipped', formatDateTime(f.shippedAt.toDateTime())),
              for (final line in f.lines)
                row('Line', '${line.orderLineId} × ${line.quantity}'),
            ],
          ),
        ),
      ),
      actions: [
        if (asyncFulfilment.value case final f?
            when nextFulfilmentStatuses(f.status).isNotEmpty)
          TextButton(
            onPressed: () => Navigator.of(context).pop(f),
            child: const Text('Update'),
          ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Edits status (forward only), carrier and tracking number of a
/// fulfilment via UpdateFulfilment with an update mask of the changed
/// fields. Returns the updated fulfilment, or null when dismissed.
Future<Fulfilment?> showUpdateFulfilmentDialog(
  BuildContext context,
  Fulfilment fulfilment,
) {
  return showDialog<Fulfilment>(
    context: context,
    builder: (_) => UpdateFulfilmentDialog(fulfilment: fulfilment),
  );
}

class UpdateFulfilmentDialog extends ConsumerStatefulWidget {
  const UpdateFulfilmentDialog({super.key, required this.fulfilment});

  final Fulfilment fulfilment;

  @override
  ConsumerState<UpdateFulfilmentDialog> createState() =>
      _UpdateFulfilmentDialogState();
}

class _UpdateFulfilmentDialogState
    extends ConsumerState<UpdateFulfilmentDialog> {
  late FulfilmentStatus _status = widget.fulfilment.status;
  late final _carrier = TextEditingController(text: widget.fulfilment.carrier);
  late final _tracking = TextEditingController(
    text: widget.fulfilment.trackingNumber,
  );
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _carrier.dispose();
    _tracking.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final f = widget.fulfilment;
    final request = UpdateFulfilmentRequest(id: f.id);
    final paths = <String>[];
    if (_status != f.status) {
      request.status = _status;
      paths.add('status');
    }
    if (_carrier.text.trim() != f.carrier) {
      request.carrier = _carrier.text.trim();
      paths.add('carrier');
    }
    if (_tracking.text.trim() != f.trackingNumber) {
      request.trackingNumber = _tracking.text.trim();
      paths.add('tracking_number');
    }
    if (paths.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    request.updateMask = FieldMask(paths: paths);

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(fulfilmentNotifierProvider.notifier)
          .update(request);
      if (mounted) Navigator.of(context).pop(updated);
    } catch (e) {
      if (mounted) setState(() => _error = paymentErrorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = widget.fulfilment.status;
    final options = [current, ...nextFulfilmentStatuses(current)];
    return AlertDialog(
      title: const Text('Update fulfilment'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<FulfilmentStatus>(
              key: const ValueKey('fulfilment-status'),
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: options
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(fulfilmentStatusLabel(s)),
                    ),
                  )
                  .toList(),
              onChanged: (s) => setState(() => _status = s ?? _status),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('fulfilment-carrier'),
              controller: _carrier,
              decoration: const InputDecoration(labelText: 'Carrier'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('fulfilment-tracking'),
              controller: _tracking,
              decoration: const InputDecoration(labelText: 'Tracking number'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
