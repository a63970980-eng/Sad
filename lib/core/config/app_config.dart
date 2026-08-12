import 'firebase_options.dart';

/// Runtime configuration / capability flags.
class AppConfig {
  AppConfig._();

  /// When true, Firebase failed to initialize (or is unconfigured) and the
  /// app runs against in-memory mock services so every screen is usable.
  static bool demoMode = DefaultFirebaseOptions.isPlaceholder;

  /// Demo OTP accepted in demo mode.
  static const String demoOtp = '123456';
}
