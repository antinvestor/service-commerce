import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_api_profile/antinvestor_api_profile.dart';
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customer_transport_provider.dart';

/// Get a customer (profile) by ID. Delegates to the profile service.
final customerByIdProvider =
    FutureProvider.family<ProfileObject, String>((ref, customerId) async {
  return ref.watch(profileByIdProvider(customerId).future);
});

/// Search customers (profiles) by query. Delegates to the profile service.
final customerSearchProvider =
    FutureProvider.family<List<ProfileObject>, String>((ref, query) async {
  return ref.watch(profileSearchProvider(query).future);
});

/// List orders for a specific customer (profile) in a shop.
final customerOrdersProvider = FutureProvider.family<List<Order>,
    ({String shopId, String customerId})>((ref, params) async {
  final client = ref.watch(customerServiceClientProvider);
  final request = ListOrdersRequest()..shopId = params.shopId;
  final response = await client.listOrders(request);
  // Filter orders by the customer's profile ID client-side, since
  // ListOrdersRequest does not yet support a profileId filter.
  return response.orders
      .where((order) => order.profileId == params.customerId)
      .toList();
});

/// A simple note model for customer notes.
class CustomerNote {
  const CustomerNote({
    required this.id,
    required this.text,
    required this.createdAt,
    this.authorName = '',
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final String authorName;
}

/// Notifier for customer notes. Placeholder until a dedicated notes RPC exists.
class CustomerNoteNotifier extends Notifier<List<CustomerNote>> {
  @override
  List<CustomerNote> build() => [];

  void add({required String text, String authorName = ''}) {
    state = [
      ...state,
      CustomerNote(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        createdAt: DateTime.now(),
        authorName: authorName,
      ),
    ];
  }

  void remove(String noteId) {
    state = state.where((n) => n.id != noteId).toList();
  }
}

final customerNoteNotifierProvider =
    NotifierProvider<CustomerNoteNotifier, List<CustomerNote>>(
        CustomerNoteNotifier.new);
