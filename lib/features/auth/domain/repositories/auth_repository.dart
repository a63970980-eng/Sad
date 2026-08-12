import '../entities/app_user.dart';

/// Result of starting a phone verification.
class PhoneVerificationResult {
  const PhoneVerificationResult({
    required this.verificationId,
    this.autoVerified = false,
  });
  final String verificationId;
  final bool autoVerified;
}

abstract class AuthRepository {
  /// Emits the current user (or null) whenever auth state changes.
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  /// Starts SMS verification. Returns a verificationId used to confirm the OTP.
  Future<PhoneVerificationResult> startPhoneVerification(String e164Phone);

  /// Confirms the SMS code and signs the user in. Returns the signed-in user.
  Future<AppUser> confirmOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Loads the full profile (from Firestore) for the given uid.
  Future<AppUser?> fetchProfile(String uid);

  /// Persists profile changes.
  Future<AppUser> updateProfile(AppUser user);

  Future<void> signOut();
}
