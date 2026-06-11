/// API endpoint and OAuth2 configuration for the Antinvestor Console.
///
/// ## Endpoint resolution
///
/// Each service URL resolves in this priority order:
///   1. Explicit per-service env var (e.g. `COMMERCE_URL=https://commerce.custom.io`)
///   2. Shared base URL + service path  (e.g. `API_BASE_URL=https://api.example.com` → `.../commerce`)
///   3. Built-in default               (`https://api.antinvestor.com/commerce`)
class ApiConfig {
  const ApiConfig._();

  // ── Shared base URL ─────────────────────────────────────────────────────

  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.antinvestor.com',
  );

  /// Shared base URL for all Antinvestor services. Equivalent to the
  /// `API_BASE_URL` dart-define.
  static const String apiBaseUrl = _apiBaseUrl;

  // ── Per-service endpoint overrides ──────────────────────────────────────

  static const String _commerceExplicit =
      String.fromEnvironment('COMMERCE_URL');
  static String get commerceBaseUrl => _commerceExplicit.isNotEmpty
      ? _commerceExplicit
      : '$_apiBaseUrl/commerce';

  static const String _manufacturingExplicit =
      String.fromEnvironment('MANUFACTURING_URL');
  static String get manufacturingBaseUrl => _manufacturingExplicit.isNotEmpty
      ? _manufacturingExplicit
      : '$_apiBaseUrl/manufacturing';

  static const String _profileExplicit = String.fromEnvironment('PROFILE_URL');
  static String get profileBaseUrl =>
      _profileExplicit.isNotEmpty ? _profileExplicit : '$_apiBaseUrl/profile';

  static const String _notificationExplicit =
      String.fromEnvironment('NOTIFICATION_URL');
  static String get notificationBaseUrl => _notificationExplicit.isNotEmpty
      ? _notificationExplicit
      : '$_apiBaseUrl/notification';

  static const String _paymentExplicit =
      String.fromEnvironment('PAYMENT_URL');
  static String get paymentBaseUrl =>
      _paymentExplicit.isNotEmpty ? _paymentExplicit : '$_apiBaseUrl/payment';

  static const String _tenancyExplicit = String.fromEnvironment('TENANCY_URL');
  static String get tenancyBaseUrl =>
      _tenancyExplicit.isNotEmpty ? _tenancyExplicit : '$_apiBaseUrl/tenancy';

  static const String _auditExplicit = String.fromEnvironment('AUDIT_URL');
  static String get auditBaseUrl =>
      _auditExplicit.isNotEmpty ? _auditExplicit : '$_apiBaseUrl/audit';

  // ── All endpoints (for iteration / diagnostics) ─────────────────────────

  static Map<String, String> get allEndpoints => {
        'commerce': commerceBaseUrl,
        'manufacturing': manufacturingBaseUrl,
        'profile': profileBaseUrl,
        'notification': notificationBaseUrl,
        'payment': paymentBaseUrl,
        'tenancy': tenancyBaseUrl,
        'audit': auditBaseUrl,
      };

  // ── OAuth2 configuration ────────────────────────────────────────────────

  static const String oauth2IssuerUrl = String.fromEnvironment(
    'OAUTH2_ISSUER_URL',
    defaultValue: 'https://auth.antinvestor.com',
  );
  static const String oauth2ClientId = String.fromEnvironment(
    'OAUTH2_CLIENT_ID',
    defaultValue: 'console-dev',
  );

  /// Explicit redirect URI override. When set, takes precedence over
  /// automatic web-origin detection and the localhost fallback.
  static const String oauth2RedirectUri = String.fromEnvironment(
    'OAUTH2_REDIRECT_URI',
  );

  // ── Connection settings ─────────────────────────────────────────────────

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration idleTimeout = Duration(seconds: 120);
}
