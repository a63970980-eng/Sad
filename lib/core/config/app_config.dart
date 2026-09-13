import 'firebase_options.dart';

/// Runtime configuration / capability flags.
class AppConfig {
  AppConfig._();

  /// Legacy Firebase/demo compatibility flag. Firebase is being migrated
  /// feature-by-feature and is not removed until every consumer is migrated.
  static bool demoMode = DefaultFirebaseOptions.isPlaceholder;

  /// Indicates that the production Supabase backend initialized successfully.
  static bool supabaseReady = false;

  /// Demo OTP accepted in legacy demo mode.
  static const String demoOtp = '123456';
}
