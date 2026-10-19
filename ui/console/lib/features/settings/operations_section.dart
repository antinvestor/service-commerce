import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show
        LedgerPosting,
        ReconcilePaymentsRequest,
        ReconcilePaymentsResponse,
        RunEndOfDayLedgerRequest,
        Shop;
import 'package:antinvestor_ui_core/antinvestor_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/active_shop_provider.dart';
import '../../core/services/commerce_client_provider.dart';
import '../../core/theme/app_colors.dart';

/// Formats [day] as the `YYYY-MM-DD` trading date `RunEndOfDayLedger`
/// expects.
String ledgerDate(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

/// The day before [now], the default trading day to post.
DateTime yesterdayOf(DateTime now) =>
    DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));

/// Staff actions that run the payment reconciler and end-of-day ledger
/// posting for the active shop on demand.
///
/// The console has no role source, so this is shown to every operator;
/// the backend rejects callers without the required permission and the
/// error is shown inline.
class OperationsSection extends ConsumerStatefulWidget {
  const OperationsSection({super.key});

  @override
  ConsumerState<OperationsSection> createState() => _OperationsSectionState();
}

class _OperationsSectionState extends ConsumerState<OperationsSection> {
  bool _reconciling = false;
  ReconcilePaymentsResponse? _reconcileResult;
  String? _reconcileError;

  bool _posting = false;
  DateTime _postingDay = yesterdayOf(DateTime.now());
  List<LedgerPosting>? _postings;
  String? _postingError;

  Future<void> _reconcile(Shop shop) async {
    setState(() {
      _reconciling = true;
      _reconcileError = null;
      _reconcileResult = null;
    });
    try {
      final result = await ref
          .read(commerceServiceClientProvider)
          .reconcilePayments(ReconcilePaymentsRequest(shopId: shop.id));
      if (mounted) setState(() => _reconcileResult = result);
    } catch (e) {
      if (mounted) setState(() => _reconcileError = friendlyError(e));
    } finally {
      if (mounted) setState(() => _reconciling = false);
    }
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _postingDay,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Trading day to post',
    );
    if (picked != null && mounted) setState(() => _postingDay = picked);
  }

  Future<void> _postLedger(Shop shop) async {
    setState(() {
      _posting = true;
      _postingError = null;
      _postings = null;
    });
    try {
      final result = await ref
          .read(commerceServiceClientProvider)
          .runEndOfDayLedger(
            RunEndOfDayLedgerRequest(
              shopId: shop.id,
              date: ledgerDate(_postingDay),
            ),
          );
      if (mounted) setState(() => _postings = result.postings.toList());
    } catch (e) {
      if (mounted) setState(() => _postingError = friendlyError(e));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = ref.watch(activeShopProvider);
    final theme = Theme.of(context);
    if (shop == null) {
      return Text(
        'Select or create a shop to run operations.',
        style: theme.textTheme.bodyMedium,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Run jobs that normally happen on a schedule for ${shop.name}.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.onSurfaceMuted,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _reconciling ? null : () => _reconcile(shop),
          icon: _reconciling
              ? const _Spinner()
              : const Icon(Icons.sync_outlined),
          label: const Text('Reconcile payments now'),
        ),
        if (_reconcileError != null) _ErrorText(_reconcileError!),
        if (_reconcileResult != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Stat('Examined', _reconcileResult!.examined),
                _Stat('Paid', _reconcileResult!.paid),
                _Stat('Expired', _reconcileResult!.expired),
                _Stat('Failed', _reconcileResult!.failed),
              ],
            ),
          ),
        const Divider(height: 32),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _posting ? null : _pickDay,
              icon: const Icon(Icons.event_outlined),
              label: Text(ledgerDate(_postingDay)),
            ),
            OutlinedButton.icon(
              onPressed: _posting ? null : () => _postLedger(shop),
              icon: _posting
                  ? const _Spinner()
                  : const Icon(Icons.account_balance_outlined),
              label: const Text('Post end-of-day ledger'),
            ),
          ],
        ),
        if (_postingError != null) _ErrorText(_postingError!),
        if (_postings != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _postings!.isEmpty
                ? Text(
                    'Nothing to post for ${ledgerDate(_postingDay)}.',
                    style: theme.textTheme.bodyMedium,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final p in _postings!) _PostingTile(posting: p),
                    ],
                  ),
          ),
      ],
    );
  }
}

class _PostingTile extends StatelessWidget {
  const _PostingTile({required this.posting});

  final LedgerPosting posting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final failed = posting.error.isNotEmpty;
    final status = failed
        ? 'Failed'
        : posting.skipped
        ? 'Skipped (already posted or nothing to post)'
        : 'Posted';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: failed ? AppColors.error : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${posting.date} · $status',
            style: theme.textTheme.titleSmall?.copyWith(
              color: failed ? AppColors.error : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sales ${_money(posting.hasSales() ? posting.sales : null)} · '
            'Refunds ${_money(posting.hasRefunds() ? posting.refunds : null)} · '
            'Orders ${posting.orders}',
            style: theme.textTheme.bodyMedium,
          ),
          if (posting.transactionId.isNotEmpty)
            Text(
              'Ledger transaction ${posting.transactionId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
          if (failed)
            Text(
              posting.error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }

  static String _money(Object? money) {
    if (money == null) return '0.00';
    final formatted = formatMoney(money);
    return formatted == '—' ? '0.00' : formatted;
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 16,
    height: 16,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
