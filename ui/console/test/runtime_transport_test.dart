import 'dart:typed_data';

import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:connectrpc/connect.dart';
import 'package:console/core/services/runtime_transport.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the request the transport makes and answers with [respond].
class _FakeRuntime implements AuthRuntime {
  _FakeRuntime(this.respond);

  final Future<ApiResponse> Function() respond;
  String? url;
  String? method;
  Map<String, String>? headers;
  Object? body;

  @override
  Future<ApiResponse> fetch(
    String path, {
    String method = 'GET',
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) {
    url = path;
    this.method = method;
    this.headers = headers;
    this.body = body;
    return respond();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'Connect calls go through the runtime, which authenticates them',
    () async {
      final shop = GetShopResponse(
        shop: Shop(id: 'shop-1', name: 'Duka'),
      );
      final runtime = _FakeRuntime(
        () async => ApiResponse(
          status: 200,
          headers: {'content-type': 'application/proto'},
          body: Uint8List.fromList(shop.writeToBuffer()),
        ),
      );
      final client = CommerceServiceClient(
        runtimeTransport(runtime, 'https://api.example/commerce'),
      );

      final response = await client.getShop(GetShopRequest(id: 'shop-1'));

      expect(response.shop.name, 'Duka');
      expect(
        runtime.url,
        'https://api.example/commerce/commerce.v1.CommerceService/GetShop',
      );
      expect(runtime.method, 'POST');
      expect(runtime.headers!['content-type'], 'application/proto');
      expect(
        runtime.headers!.containsKey('authorization'),
        isFalse,
        reason: 'the runtime attaches the token, never the transport',
      );
      expect(
        GetShopRequest.fromBuffer(runtime.body! as List<int>).id,
        'shop-1',
      );
    },
  );

  test('a body the browser already decompressed is accepted', () async {
    final shop = GetShopResponse(
      shop: Shop(id: 'shop-1', name: 'Duka'),
    );
    final decoded = Uint8List.fromList(shop.writeToBuffer());
    // What a browser reports for a gzipped response: the wire headers with
    // the decoded body.
    final runtime = _FakeRuntime(
      () async => ApiResponse(
        status: 200,
        headers: {
          'content-type': 'application/proto',
          'content-encoding': 'gzip',
          'content-length': '${decoded.length + 18}',
        },
        body: decoded,
      ),
    );
    final client = CommerceServiceClient(
      runtimeTransport(runtime, 'https://api.example/commerce'),
    );

    final response = await client.getShop(GetShopRequest(id: 'shop-1'));

    expect(response.shop.name, 'Duka');
  });

  test('a session problem surfaces as unauthenticated', () async {
    final runtime = _FakeRuntime(
      () async => throw AuthError(AuthErrorCode.tokenRefreshFailed, 'expired'),
    );
    final client = CommerceServiceClient(
      runtimeTransport(runtime, 'https://api.example/commerce'),
    );
    await expectLater(
      client.getShop(GetShopRequest(id: 'shop-1')),
      throwsA(
        isA<ConnectException>().having(
          (e) => e.code,
          'code',
          Code.unauthenticated,
        ),
      ),
    );
  });

  test('connectivity problems surface as unavailable', () async {
    final runtime = _FakeRuntime(
      () async => throw AuthError(AuthErrorCode.offline, 'offline'),
    );
    final client = CommerceServiceClient(
      runtimeTransport(runtime, 'https://api.example/commerce'),
    );
    await expectLater(
      client.getShop(GetShopRequest(id: 'shop-1')),
      throwsA(
        isA<ConnectException>().having((e) => e.code, 'code', Code.unavailable),
      ),
    );
  });

  test('server errors keep their Connect code', () async {
    final runtime = _FakeRuntime(
      () async => ApiResponse(
        status: 403,
        headers: {'content-type': 'application/json'},
        body: Uint8List.fromList(
          '{"code":"permission_denied","message":"no"}'.codeUnits,
        ),
      ),
    );
    final client = CommerceServiceClient(
      runtimeTransport(runtime, 'https://api.example/commerce'),
    );
    await expectLater(
      client.getShop(GetShopRequest(id: 'shop-1')),
      throwsA(
        isA<ConnectException>().having(
          (e) => e.code,
          'code',
          Code.permissionDenied,
        ),
      ),
    );
  });
}
