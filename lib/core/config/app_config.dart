import 'firebase_options.dart';

/// Runtime configuration and backend capability flags.
class AppConfig {
  AppConfig._();

  /// Legacy Firebase/demo compatibility flag.
  static bool demoMode = DefaultFirebaseOptions.isPlaceholder;

  /// True when Supabase has initialized successfully.
  static bool supabaseReady = false;

  /// Data repositories can migrate to Supabase independently from Auth.
  static bool supabaseDataEnabled = false;

  /// Keep phone OTP on the proven legacy path until the Supabase SMS provider
  /// is explicitly configured for production. This prevents a backend
  /// initialization from silently breaking the login flow.
  static bool supabaseAuthEnabled = false;

  static const String demoOtp = '123456';
}
