import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyUserId = 'user_id';
  static const String _keyEmail = 'user_email';
  static const String _keyDisplayName = 'user_display_name';
  static const String _keyIdToken = 'id_token';
  static const String _keyAuthStatus = 'auth_status';

  /// Save user session and token information securely
  Future<void> saveUserSession({
    required String userId,
    required String email,
    String? displayName,
    String? idToken,
  }) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyEmail, value: email);
    if (displayName != null) {
      await _storage.write(key: _keyDisplayName, value: displayName);
    }
    if (idToken != null) {
      await _storage.write(key: _keyIdToken, value: idToken);
    }
    await _storage.write(key: _keyAuthStatus, value: 'logged_in');
  }

  /// Get stored user details
  Future<Map<String, String?>> getUserSession() async {
    final userId = await _storage.read(key: _keyUserId);
    final email = await _storage.read(key: _keyEmail);
    final displayName = await _storage.read(key: _keyDisplayName);
    final idToken = await _storage.read(key: _keyIdToken);
    final authStatus = await _storage.read(key: _keyAuthStatus);

    return {
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'id_token': idToken,
      'auth_status': authStatus,
    };
  }

  /// Check if user session exists in secure storage
  Future<bool> isLoggedIn() async {
    final authStatus = await _storage.read(key: _keyAuthStatus);
    return authStatus == 'logged_in';
  }

  /// Clear all stored data from secure storage on logout
  Future<void> clearAllData() async {
    await _storage.deleteAll();
  }
}
