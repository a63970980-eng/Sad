import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Supabase Auth implementation for the production phone-OTP flow.
///
/// The verification id is intentionally the normalized phone number because
/// Supabase verifies OTPs by phone + token rather than a Firebase-style
/// verification-id exchange.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;

  @override
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fromSupabaseUser(user);
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    final initial = currentUser;
    yield initial;

    await for (final event in _client.auth.onAuthStateChange) {
      final user = event.session?.user;
      if (user == null) {
        yield null;
      } else {
        yield await fetchProfile(user.id) ?? _fromSupabaseUser(user);
      }
    }
  }

  @override
  Future<PhoneVerificationResult> startPhoneVerification(
      String e164Phone) async {
    await _client.auth.signInWithOtp(
      phone: e164Phone,
      shouldCreateUser: true,
    );
    return PhoneVerificationResult(verificationId: e164Phone);
  }

  @override
  Future<AppUser> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final response = await _client.auth.verifyOTP(
      phone: verificationId,
      token: smsCode,
      type: OtpType.sms,
    );

    final user = response.user ?? _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('تعذر إنشاء جلسة تسجيل الدخول.');
    }

    final existing = await fetchProfile(user.id);
    if (existing != null) return existing;

    final profile = _fromSupabaseUser(user);
    await _client.from('profiles').upsert({
      'id': user.id,
      'phone': profile.phoneNumber,
      'full_name': profile.fullName,
      'national_number': profile.nationalNumber,
      'email': profile.email,
      'photo_url': profile.photoUrl,
    });
    return profile;
  }

  @override
  Future<AppUser?> fetchProfile(String uid) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (data == null) return null;

    final authUser = _client.auth.currentUser;
    return AppUser(
      uid: uid,
      phoneNumber: data['phone'] as String? ?? authUser?.phone,
      fullName: data['full_name'] as String?,
      nationalNumber: data['national_number'] as String?,
      email: data['email'] as String? ?? authUser?.email,
      photoUrl: data['photo_url'] as String?,
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid != user.uid) {
      throw const AuthException('جلسة المستخدم غير صالحة.');
    }

    await _client.from('profiles').update({
      'full_name': user.fullName,
      'national_number': user.nationalNumber,
      'email': user.email,
      'photo_url': user.photoUrl,
      'phone': user.phoneNumber,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', user.uid);

    return user;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  AppUser _fromSupabaseUser(User user) {
    return AppUser(
      uid: user.id,
      phoneNumber: user.phone,
      email: user.email,
      fullName: user.userMetadata?['full_name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }
}
