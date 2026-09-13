import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/unavailable_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.demoMode) return MockAuthRepository();

  if (AppConfig.supabaseAuthEnabled) {
    if (AppConfig.supabaseReady) return SupabaseAuthRepository();
    return const UnavailableAuthRepository();
  }

  // Firebase remains a compatibility path only when Supabase auth is
  // explicitly disabled at build time.
  return FirebaseAuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

enum OtpStage { idle, codeSent, verifying, success, error }

class LoginState {
  const LoginState({
    this.stage = OtpStage.idle,
    this.phone = '',
    this.verificationId,
    this.errorKey,
    this.loading = false,
  });

  final OtpStage stage;
  final String phone;
  final String? verificationId;
  final String? errorKey;
  final bool loading;

  LoginState copyWith({
    OtpStage? stage,
    String? phone,
    String? verificationId,
    String? errorKey,
    bool? loading,
  }) {
    return LoginState(
      stage: stage ?? this.stage,
      phone: phone ?? this.phone,
      verificationId: verificationId ?? this.verificationId,
      errorKey: errorKey,
      loading: loading ?? this.loading,
    );
  }
}

class LoginController extends Notifier<LoginState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);
  SecureStorageService get _secure => ref.read(secureStorageProvider);

  @override
  LoginState build() => const LoginState();

  Future<bool> sendCode(String e164Phone, {required bool rememberMe}) async {
    state = state.copyWith(loading: true, errorKey: null, phone: e164Phone);
    try {
      await _secure.setRememberMe(rememberMe);
      final res = await _repo.startPhoneVerification(e164Phone);
      state = state.copyWith(
        stage: OtpStage.codeSent,
        verificationId: res.verificationId,
        loading: false,
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        loading: false,
        stage: OtpStage.error,
        errorKey: 'loginFailed',
      );
      return false;
    }
  }

  Future<bool> verify(String smsCode) async {
    final verificationId = state.verificationId;
    if (verificationId == null) return false;
    state = state.copyWith(
      loading: true,
      stage: OtpStage.verifying,
      errorKey: null,
    );
    try {
      final user = await _repo.confirmOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _secure.saveUserId(user.uid);
      state = state.copyWith(loading: false, stage: OtpStage.success);
      return true;
    } catch (_) {
      state = state.copyWith(
        loading: false,
        stage: OtpStage.error,
        errorKey: 'invalidOtp',
      );
      return false;
    }
  }

  void reset() => state = const LoginState();
}

final loginControllerProvider =
    NotifierProvider<LoginController, LoginState>(LoginController.new);

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, AppUser?>(ProfileController.new);

class ProfileController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    return ref.watch(authStateProvider).valueOrNull;
  }

  Future<void> save(AppUser updated) async {
    state = const AsyncValue.loading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => repo.updateProfile(updated));
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await ref.read(secureStorageProvider).clear();
    await repo.signOut();
  }
}
