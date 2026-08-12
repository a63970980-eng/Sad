import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Real implementation backed by Firebase Auth (phone) + Cloud Firestore.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  @override
  AppUser? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    return AppUser(uid: u.uid, phoneNumber: u.phoneNumber ?? '');
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((u) async {
      if (u == null) return null;
      final profile = await fetchProfile(u.uid);
      return profile ?? AppUser(uid: u.uid, phoneNumber: u.phoneNumber ?? '');
    });
  }

  @override
  Future<PhoneVerificationResult> startPhoneVerification(String e164Phone) async {
    final completer = Completer<PhoneVerificationResult>();

    await _auth.verifyPhoneNumber(
      phoneNumber: e164Phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (cred) async {
        // Android auto-retrieval. Sign in immediately when possible.
        try {
          await _auth.signInWithCredential(cred);
        } catch (_) {}
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(_mapError(e));
        }
      },
      codeSent: (verificationId, _) {
        if (!completer.isCompleted) {
          completer.complete(PhoneVerificationResult(verificationId: verificationId));
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(PhoneVerificationResult(verificationId: verificationId));
        }
      },
    );

    return completer.future;
  }

  @override
  Future<AppUser> confirmOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final cred = fb.PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(cred);
    final fbUser = result.user!;

    // Ensure a profile document exists.
    final existing = await fetchProfile(fbUser.uid);
    if (existing != null) return existing;

    final newUser = AppUser(
      uid: fbUser.uid,
      phoneNumber: fbUser.phoneNumber ?? '',
      createdAt: DateTime.now(),
    );
    await _users.doc(newUser.uid).set(newUser.toMap());
    return newUser;
  }

  @override
  Future<AppUser?> fetchProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    return user;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  Exception _mapError(fb.FirebaseAuthException e) {
    return Exception(e.message ?? 'Authentication error (${e.code})');
  }
}
