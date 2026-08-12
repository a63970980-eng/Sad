import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper over flutter_secure_storage for tokens & sensitive flags.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAuthToken = 'auth_token';
  static const _kRememberMe = 'remember_me';
  static const _kUserId = 'user_id';

  Future<void> saveAuthToken(String token) =>
      _storage.write(key: _kAuthToken, value: token);

  Future<String?> readAuthToken() => _storage.read(key: _kAuthToken);

  Future<void> saveUserId(String id) => _storage.write(key: _kUserId, value: id);

  Future<String?> readUserId() => _storage.read(key: _kUserId);

  Future<void> setRememberMe(bool value) =>
      _storage.write(key: _kRememberMe, value: value.toString());

  Future<bool> getRememberMe() async =>
      (await _storage.read(key: _kRememberMe)) == 'true';

  Future<void> clear() => _storage.deleteAll();
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});
