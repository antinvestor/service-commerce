import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:antinvestor_ui_auth/antinvestor_ui_auth.dart'
    show authTransportProvider;
import 'package:antinvestor_ui_catalog/antinvestor_ui_catalog.dart'
    show catalogTransportProvider;
import 'package:antinvestor_ui_coldchain/antinvestor_ui_coldchain.dart'
    show coldchainTransportProvider;
import 'package:antinvestor_ui_costing/antinvestor_ui_costing.dart'
    show costingTransportProvider;
import 'package:antinvestor_ui_customers/antinvestor_ui_customers.dart'
    show customerTransportProvider;
import 'package:antinvestor_ui_demand/antinvestor_ui_demand.dart'
    show demandTransportProvider;
import 'package:antinvestor_ui_equipment/antinvestor_ui_equipment.dart'
    show equipmentTransportProvider;
import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart'
    show geolocationTransportProvider, identityTransportProvider;
import 'package:antinvestor_ui_inventory/antinvestor_ui_inventory.dart'
    show inventoryTransportProvider;
import 'package:antinvestor_ui_notification/antinvestor_ui_notification.dart'
    show notificationTransportProvider;
import 'package:antinvestor_ui_orders/antinvestor_ui_orders.dart'
    show orderTransportProvider;
import 'package:antinvestor_ui_payment/antinvestor_ui_payment.dart'
    show paymentTransportProvider;
import 'package:antinvestor_ui_pricing/antinvestor_ui_pricing.dart'
    show pricingTransportProvider;
import 'package:antinvestor_ui_procurement/antinvestor_ui_procurement.dart'
    show procurementTransportProvider;
import 'package:antinvestor_ui_production/antinvestor_ui_production.dart'
    show productionTransportProvider;
import 'package:antinvestor_ui_profile/antinvestor_ui_profile.dart'
    show profileTransportProvider;
import 'package:antinvestor_ui_quality/antinvestor_ui_quality.dart'
    show qualityTransportProvider;
import 'package:antinvestor_ui_recipes/antinvestor_ui_recipes.dart'
    show recipesTransportProvider;
import 'package:antinvestor_ui_shelflife/antinvestor_ui_shelflife.dart'
    show shelflifeTransportProvider;
import 'package:antinvestor_ui_traceability/antinvestor_ui_traceability.dart'
    show traceabilityTransportProvider;
import 'package:antinvestor_ui_waste/antinvestor_ui_waste.dart'
    show wasteTransportProvider;
import 'package:connectrpc/connect.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'api_config.dart';
import 'commerce_client_provider.dart';
import 'runtime_transport.dart';

/// Points every service transport the console's modules use at the console's
/// endpoints and authenticates it through the auth runtime.
///
/// Each UI package ships a transport provider defaulting to its own base URL
/// and to ui_core's token interceptor; the runtime never exposes a token, so
/// without these overrides module RPCs would go out unauthenticated.
List<Override> runtimeTransportOverrides(AuthRuntime runtime) {
  Transport to(String baseUrl) => runtimeTransport(runtime, baseUrl);

  final commerce = ApiConfig.commerceBaseUrl;
  final manufacturing = ApiConfig.manufacturingBaseUrl;
  return [
    // Commerce.
    commerceTransportProvider.overrideWith((ref) => to(commerce)),
    catalogTransportProvider.overrideWith((ref) => to(commerce)),
    customerTransportProvider.overrideWith((ref) => to(commerce)),
    orderTransportProvider.overrideWith((ref) => to(commerce)),
    pricingTransportProvider.overrideWith((ref) => to(commerce)),
    procurementTransportProvider.overrideWith(
      (ref) => to(ApiConfig.procurementBaseUrl),
    ),
    // Manufacturing.
    coldchainTransportProvider.overrideWith((ref) => to(manufacturing)),
    costingTransportProvider.overrideWith((ref) => to(manufacturing)),
    demandTransportProvider.overrideWith((ref) => to(manufacturing)),
    equipmentTransportProvider.overrideWith((ref) => to(manufacturing)),
    inventoryTransportProvider.overrideWith((ref) => to(manufacturing)),
    productionTransportProvider.overrideWith((ref) => to(manufacturing)),
    qualityTransportProvider.overrideWith((ref) => to(manufacturing)),
    recipesTransportProvider.overrideWith((ref) => to(manufacturing)),
    shelflifeTransportProvider.overrideWith((ref) => to(manufacturing)),
    traceabilityTransportProvider.overrideWith((ref) => to(manufacturing)),
    wasteTransportProvider.overrideWith((ref) => to(manufacturing)),
    // Platform.
    profileTransportProvider.overrideWith(
      (ref) => to(ApiConfig.profileBaseUrl),
    ),
    notificationTransportProvider.overrideWith(
      (ref) => to(ApiConfig.notificationBaseUrl),
    ),
    paymentTransportProvider.overrideWith(
      (ref) => to(ApiConfig.paymentBaseUrl),
    ),
    identityTransportProvider.overrideWith(
      (ref) => to(ApiConfig.identityBaseUrl),
    ),
    geolocationTransportProvider.overrideWith(
      (ref) => to(ApiConfig.geolocationBaseUrl),
    ),
    authTransportProvider.overrideWith(
      (ref) => to(ApiConfig.authenticationBaseUrl),
    ),
  ];
}
