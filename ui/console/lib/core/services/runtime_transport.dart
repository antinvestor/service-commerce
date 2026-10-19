import 'dart:typed_data';

import 'package:antinvestor_auth_runtime/antinvestor_auth_runtime.dart';
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as protocol;

/// A Connect [HttpClient] that sends every request through the auth
/// runtime's [AuthRuntime.fetch].
///
/// The runtime never hands out the access token; it attaches the bearer (or
/// DPoP) token itself, refreshes on 401 and retries once. Routing Connect
/// through it is therefore the only way RPCs carry the signed-in user's
/// identity. Requests are unary (the body is buffered), which covers every
/// RPC the console makes.
HttpClient runtimeHttpClient(AuthRuntime runtime) {
  return (HttpRequest request) async {
    final body = await _collect(request.body);
    final headers = <String, String>{
      for (final entry in request.header.entries) entry.name: entry.value,
    };

    final ApiResponse response;
    try {
      response = await runtime.fetch(
        request.url,
        method: request.method,
        headers: headers,
        body: body.isEmpty ? null : body,
      );
    } on AuthError catch (e) {
      throw ConnectException(_codeFor(e.code), e.message, cause: e);
    }

    final responseHeaders = Headers();
    response.headers.forEach(responseHeaders.add);
    return HttpResponse(
      response.status,
      responseHeaders,
      Stream<Uint8List>.value(response.body),
      Headers(),
    );
  };
}

/// A Connect transport for [baseUrl] whose calls are authenticated by
/// [runtime].
Transport runtimeTransport(AuthRuntime runtime, String baseUrl) {
  return protocol.Transport(
    baseUrl: baseUrl,
    codec: const ProtoCodec(),
    httpClient: runtimeHttpClient(runtime),
    useHttpGet: false,
  );
}

Future<Uint8List> _collect(Stream<Uint8List>? body) async {
  if (body == null) return Uint8List(0);
  final builder = BytesBuilder(copy: false);
  await for (final chunk in body) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}

/// Maps a runtime failure onto the Connect code the UI already handles:
/// sign-in problems surface as unauthenticated (the router sends the user to
/// sign in), connectivity as unavailable.
Code _codeFor(AuthErrorCode code) => switch (code) {
  AuthErrorCode.networkTimeout => Code.deadlineExceeded,
  AuthErrorCode.networkError ||
  AuthErrorCode.offline ||
  AuthErrorCode.discoveryFailed => Code.unavailable,
  AuthErrorCode.apiForbidden => Code.permissionDenied,
  AuthErrorCode.apiNotFound => Code.notFound,
  AuthErrorCode.apiValidation => Code.invalidArgument,
  _ => Code.unauthenticated,
};
