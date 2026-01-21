/// Configuración para better_auth
class BetterAuthConfig {
  final String baseUrl;
  final Duration tokenRefreshThreshold;
  final bool autoRefreshToken;

  const BetterAuthConfig({
    required this.baseUrl,
    this.tokenRefreshThreshold = const Duration(minutes: 5),
    this.autoRefreshToken = true,
  });

  /// Configuración por defecto para desarrollo
  factory BetterAuthConfig.development() {
    return const BetterAuthConfig(
      baseUrl: 'http://localhost:3000',
    );
  }

  /// Configuración para producción
  factory BetterAuthConfig.production(String baseUrl) {
    return BetterAuthConfig(
      baseUrl: baseUrl,
    );
  }
}
