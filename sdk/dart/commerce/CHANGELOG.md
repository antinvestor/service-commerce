## 2.0.0

- **Breaking:** regenerated with protoc_plugin 25.1 (`buf.build/protocolbuffers/dart:v25.1.0`)
  and connect-dart 2.0 (`buf.build/connectrpc/dart:v2.0.0`); requires
  `protobuf ^6.1.0`, `connectrpc ^2.0.0`, `fixnum ^1.1.1`,
  `antinvestor_api_common ^2.0.0` and Dart `^3.7.0`.
- Well-known types (`Struct`, `Timestamp`, `FieldMask`, ...) come from
  `package:protobuf/well_known_types/...` (the barrel re-exports them); the
  vendored copies and empty `.pbserver.dart` files are gone.
- `ListOrdersRequest.statuses` and `payment_statuses` filter orders on the server.
- `FieldMask` is exported from the barrel.

## 1.55.0

- Hosted checkout: `CheckoutOrder`, `ConfirmOrderPayment`, `CancelOrder`
- Scheduled operations: `ReconcilePayments`, `RunEndOfDayLedger`
- `ListShops`, `ListProductVariants`; shop currency, contact and return URL
- Order payment fields, `ORDER_STATUS_PENDING_PAYMENT`, `PAYMENT_STATUS_EXPIRED`
- Cursor pagination (`next_page`) on all list responses

## 1.54.0

- Generated Dart SDK from proto definitions

