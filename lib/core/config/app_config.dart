/// Runtime configuration and backend capability flags.
///
/// Production builds intentionally default to real Supabase authentication.
/// Demo mode is opt-in only via --dart-define=ADEN_DIGITAL_DEMO_MODE=true.
class AppConfig {
  AppConfig._();

  /// Demo mode is never inferred from backend configuration.
  /// This prevents an accidentally misconfigured release from accepting a
  /// development OTP or mock session.
  static const bool demoMode = bool.fromEnvironment(
    'ADEN_DIGITAL_DEMO_MODE',
    defaultValue: false,
  );

  /// True when Supabase has initialized successfully.
  static bool supabaseReady = false;

  /// Data repositories can migrate to Supabase independently from Auth.
  static bool supabaseDataEnabled = false;

  /// Production authentication is Supabase phone OTP by default. A build may
  /// explicitly disable it for a non-production environment.
  static const bool supabaseAuthEnabled = bool.fromEnvironment(
    'SUPABASE_AUTH_ENABLED',
    defaultValue: true,
  );

  /// Retained only for explicitly enabled demo/test builds.
  static const String demoOtp = '123456';
}
