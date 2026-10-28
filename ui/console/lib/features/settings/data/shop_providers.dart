import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart'
    show
        CommerceServiceClient,
        CreateShopRequest,
        CurrencySource,
        PaymentPolicy,
        ResolveDefaultCurrencyRequest,
        Shop,
        ShopStatus,
        UpdateShopRequest;
// FieldMask is not re-exported by the commerce barrel, so it is imported
// from its generated source to build a precise UpdateShop update mask.
// ignore: implementation_imports
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/active_shop_provider.dart';
import '../../../core/services/commerce_client_provider.dart';

/// The shop the console is operating on, resolved from `ListShops`.
///
/// Returns `null` when the caller has no shops yet, which the UI uses to
/// offer a create flow rather than surfacing an error. Load failures are
/// surfaced as errors.
final currentShopProvider = FutureProvider<Shop?>((ref) async {
  final shops = await ref.watch(shopListProvider.future);
  return resolveActiveShop(shops, ref.watch(selectedShopIdProvider));
});

/// Drives shop create/update mutations and exposes their async state so
/// the settings UI can show progress and surface failures.
class ShopNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CommerceServiceClient get _client => ref.read(commerceServiceClientProvider);

  /// Provisions a new shop. The authenticated user becomes its admin and
  /// the new shop becomes the console's active shop.
  Future<Shop> create({
    required String name,
    required String slug,
    required String description,
    String currency = '',
    String contactId = '',
    String checkoutReturnUrl = '',
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.createShop(
        CreateShopRequest(
          name: name,
          slug: slug,
          description: description.isEmpty ? null : description,
          currency: currency.isEmpty ? null : currency,
          contactId: contactId.isEmpty ? null : contactId,
          checkoutReturnUrl: checkoutReturnUrl.isEmpty
              ? null
              : checkoutReturnUrl,
        ),
      );
      state = const AsyncValue.data(null);
      // The shop id is generated server-side: select it explicitly and
      // reload the listing so the whole console switches to it.
      ref.read(selectedShopIdProvider.notifier).select(response.shop.id);
      ref.invalidate(shopListProvider);
      return response.shop;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates the editable fields of an existing shop. The update mask is
  /// scoped to the fields the settings form exposes so untouched fields
  /// are never clobbered.
  Future<Shop> update({
    required String id,
    required String name,
    required String description,
    required ShopStatus status,
    required String currency,
    required String contactId,
    required String checkoutReturnUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.updateShop(
        UpdateShopRequest(
          id: id,
          name: name,
          description: description,
          status: status,
          currency: currency,
          contactId: contactId,
          checkoutReturnUrl: checkoutReturnUrl,
          updateMask: FieldMask(
            paths: const [
              'name',
              'description',
              'status',
              'currency',
              'contact_id',
              'checkout_return_url',
            ],
          ),
        ),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(shopListProvider);
      return response.shop;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Replaces the shop's payment policy. A null [policy] removes it, so
  /// orders are paid in full again. Only `payment_policy` is in the mask.
  Future<Shop> updatePaymentPolicy({
    required String id,
    PaymentPolicy? policy,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.updateShop(
        UpdateShopRequest(
          id: id,
          paymentPolicy: policy,
          updateMask: FieldMask(paths: const ['payment_policy']),
        ),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(shopListProvider);
      return response.shop;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Opens or closes the shop's public storefront page, where anyone can
  /// buy without an account. Only `public_storefront` is in the mask, so
  /// turning it off is written too.
  Future<Shop> updateStorefront({
    required String id,
    required bool enabled,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.updateShop(
        UpdateShopRequest(
          id: id,
          publicStorefront: enabled,
          updateMask: FieldMask(paths: const ['public_storefront']),
        ),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(shopListProvider);
      return response.shop;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates the shop's webhook settings.
  ///
  /// Only the fields that are passed are written: [url] updates
  /// `webhook_url` (empty disables delivery) and [secret] updates the
  /// write-only `webhook_secret` (empty clears it). Other shop fields are
  /// left untouched because they are not in the update mask.
  Future<Shop> updateWebhook({
    required String id,
    String? url,
    String? secret,
  }) async {
    final paths = <String>[
      if (url != null) 'webhook_url',
      if (secret != null) 'webhook_secret',
    ];
    if (paths.isEmpty) {
      throw ArgumentError('updateWebhook needs a url or a secret');
    }
    state = const AsyncValue.loading();
    try {
      final response = await _client.updateShop(
        UpdateShopRequest(
          id: id,
          webhookUrl: url,
          webhookSecret: secret,
          updateMask: FieldMask(paths: paths),
        ),
      );
      state = const AsyncValue.data(null);
      ref.invalidate(shopListProvider);
      return response.shop;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final shopNotifierProvider = NotifierProvider<ShopNotifier, AsyncValue<void>>(
  ShopNotifier.new,
);

/// Human-readable label for a [ShopStatus] enum value.
String shopStatusLabel(ShopStatus status) {
  switch (status) {
    case ShopStatus.SHOP_STATUS_ACTIVE:
      return 'Active';
    case ShopStatus.SHOP_STATUS_DISABLED:
      return 'Disabled';
    default:
      return 'Unspecified';
  }
}

/// Maps an [shopStatusLabel] back onto its [ShopStatus] enum value.
ShopStatus shopStatusFromLabel(String label) {
  switch (label) {
    case 'Active':
      return ShopStatus.SHOP_STATUS_ACTIVE;
    case 'Disabled':
      return ShopStatus.SHOP_STATUS_DISABLED;
    default:
      return ShopStatus.SHOP_STATUS_UNSPECIFIED;
  }
}

/// Editable status labels offered in the shop edit dialog.
const List<String> shopStatusLabels = ['Active', 'Disabled'];

/// A default currency suggested for a new shop, with a hint telling the
/// operator where it came from.
class DefaultCurrencySuggestion {
  const DefaultCurrencySuggestion({required this.currency, required this.hint});

  /// ISO 4217 code, or empty when no suggestion could be fetched.
  final String currency;

  /// Explanation shown under the currency field.
  final String hint;
}

/// Hint shown when `ResolveDefaultCurrency` could not be reached. The
/// backend applies the same default when the currency is left empty.
const String defaultCurrencyUnavailableHint =
    "Couldn't look up a default currency. Leave empty to let the server "
    'choose it, or enter an ISO 4217 code.';

/// Explains where a resolved default currency came from.
String currencySourceHint(CurrencySource source) {
  switch (source) {
    case CurrencySource.CURRENCY_SOURCE_PREFERENCE:
      return 'From your currency preference';
    case CurrencySource.CURRENCY_SOURCE_DEVICE:
      return "From your device's location";
    case CurrencySource.CURRENCY_SOURCE_ADDRESS:
      return 'From your profile address';
    case CurrencySource.CURRENCY_SOURCE_PLATFORM_DEFAULT:
      return 'Platform default';
    default:
      return 'Suggested default';
  }
}

/// Suggests a currency for a new shop via `ResolveDefaultCurrency`.
///
/// Never throws: on failure it returns an empty currency with
/// [defaultCurrencyUnavailableHint], so the create form still opens.
Future<DefaultCurrencySuggestion> resolveDefaultCurrencySuggestion(
  CommerceServiceClient client,
) async {
  try {
    final response = await client.resolveDefaultCurrency(
      ResolveDefaultCurrencyRequest(),
    );
    final currency = response.currency.trim().toUpperCase();
    if (currency.isEmpty) {
      return const DefaultCurrencySuggestion(
        currency: '',
        hint: defaultCurrencyUnavailableHint,
      );
    }
    return DefaultCurrencySuggestion(
      currency: currency,
      hint: '${currencySourceHint(response.source)}. You can change it.',
    );
  } catch (_) {
    return const DefaultCurrencySuggestion(
      currency: '',
      hint: defaultCurrencyUnavailableHint,
    );
  }
}

/// Validates a shop webhook URL. Returns an error message, or `null` when
/// the value is acceptable. Empty is accepted and disables delivery.
///
/// The backend additionally rejects hosts that resolve to non-public
/// addresses; this only catches what can be seen from the string.
String? validateWebhookUrl(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return 'Enter a full URL, e.g. https://example.com/hooks/commerce';
  }
  if (uri.scheme.toLowerCase() != 'https') {
    return 'The webhook URL must use https.';
  }
  if (uri.userInfo.isNotEmpty) {
    return 'The webhook URL must not contain credentials.';
  }
  if (uri.hasFragment) {
    return 'The webhook URL must not contain a #fragment.';
  }
  if (_isNonPublicHost(uri.host.toLowerCase())) {
    return 'The webhook URL must point to a public address.';
  }
  return null;
}

bool _isNonPublicHost(String host) {
  if (host == 'localhost' ||
      host.endsWith('.localhost') ||
      host.endsWith('.local') ||
      host.endsWith('.internal')) {
    return true;
  }
  // Bracketed IPv6 literal: only reject the obvious loopback/private ones.
  final bare = host.replaceAll('[', '').replaceAll(']', '');
  if (bare.contains(':')) {
    return bare == '::1' ||
        bare == '::' ||
        bare.startsWith('fc') ||
        bare.startsWith('fd') ||
        bare.startsWith('fe80');
  }
  final parts = bare.split('.');
  if (parts.length != 4) return false;
  final octets = parts.map(int.tryParse).toList();
  if (octets.any((o) => o == null || o < 0 || o > 255)) return false;
  final a = octets[0]!;
  final b = octets[1]!;
  return a == 0 ||
      a == 10 ||
      a == 127 ||
      (a == 169 && b == 254) ||
      (a == 172 && b >= 16 && b <= 31) ||
      (a == 192 && b == 168) ||
      (a == 100 && b >= 64 && b <= 127);
}

/// Read-only lines describing a shop's payment policy.
List<String> paymentPolicySummary(Shop shop) {
  if (!shop.hasPaymentPolicy()) {
    return const ['Not configured: buyers pay the full amount at checkout.'];
  }
  final PaymentPolicy p = shop.paymentPolicy;
  if (!p.allowInstalments) {
    return [
      'Instalments off: buyers pay the full amount at checkout.',
      if (p.signalThresholds.isNotEmpty)
        'Signal thresholds: ${p.signalThresholds.map((t) => '$t%').join(', ')}',
    ];
  }
  final fulfilAt = p.fulfilAtPercent == 0 ? 100 : p.fulfilAtPercent;
  return [
    'Instalments allowed',
    'Minimum deposit: ${p.minDepositPercent}%',
    'Minimum instalment: ${p.minInstalmentPercent}%',
    p.balanceDueDays == 0
        ? 'Balance due: no deadline'
        : 'Balance due: ${p.balanceDueDays} days after the first instalment',
    'Fulfil at: $fulfilAt% paid',
    if (p.signalThresholds.isNotEmpty)
      'Signal thresholds: ${p.signalThresholds.map((t) => '$t%').join(', ')}',
    p.cancelWhenOverdue
        ? 'Overdue orders are cancelled and refunded'
        : 'Overdue orders stay open',
  ];
}
