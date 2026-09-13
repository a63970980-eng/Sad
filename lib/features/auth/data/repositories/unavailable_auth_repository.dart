import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Safe failure mode for production when the configured authentication
/// backend is temporarily unavailable. It deliberately never falls back to
/// mock/demo authentication.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  AuthException get _error =>
      const AuthException('خدمة تسجيل الدخول غير متاحة حالياً. يرجى المحاولة مرة أخرى.');

  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.value(null);

  @override
  Future<PhoneVerificationResult> startPhoneVerification(String e164Phone) async {
    throw _error;
  }

  @override
  Future<AppUser> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    throw _error;
  }

  @override
  Future<AppUser?> fetchProfile(String uid) async => null;

  @override
  Future<AppUser> updateProfile(AppUser user) async => throw _error;

  @override
  Future<void> signOut() async {}
}
