import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../main.dart';
import '../../data/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserSessionProvider = FutureProvider<Map<String, String?>>((ref) async {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return await secureStorage.getUserSession();
});
