import 'dart:async';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory auth used only when explicitly running in demo mode.
/// Accepts OTP code [AppConfig.demoOtp].
class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current;
  final Map<String, AppUser> _store = {};

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<PhoneVerificationResult> startPhoneVerification(String e164Phone) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return PhoneVerificationResult(verificationId: 'demo::$e164Phone');
  }

  @override
  Future<AppUser> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (smsCode != AppConfig.demoOtp) {
      throw Exception('invalid-otp');
    }
    final phone = verificationId.replaceFirst('demo::', '');
    final uid = 'demo_${phone.hashCode.abs()}';
    final user = _store[uid] ??
        AppUser(
          uid: uid,
          phoneNumber: phone,
          fullName: 'مواطن عدن',
          nationalNumber: '0${phone.hashCode.abs() % 1000000000}',
          createdAt: DateTime.now(),
        );
    _store[uid] = user;
    _current = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AppUser?> fetchProfile(String uid) async => _store[uid] ?? _current;

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    _store[user.uid] = user;
    _current = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }
}
