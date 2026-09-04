import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/secure_storage_service.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final SecureStorageService _secureStorageService;
  final SharedPreferences? _prefs;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    SecureStorageService? secureStorageService,
    SharedPreferences? prefs,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _secureStorageService = secureStorageService ?? SecureStorageService(),
        _prefs = prefs;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Canceled by user
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _secureStorageService.saveUserSession(
          userId: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          idToken: googleAuth.idToken,
        );
        if (_prefs != null) {
          await _prefs.setBool('is_logged_in', true);
          await _prefs.setBool('is_guest', false);
        }
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = userCredential.user;

    if (user != null) {
      final token = await user.getIdToken();
      await _secureStorageService.saveUserSession(
        userId: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        idToken: token,
      );
      if (_prefs != null) {
        await _prefs.setBool('is_logged_in', true);
        await _prefs.setBool('is_guest', false);
      }
    }

    return userCredential;
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = userCredential.user;

    if (user != null) {
      final token = await user.getIdToken();
      await _secureStorageService.saveUserSession(
        userId: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        idToken: token,
      );
      if (_prefs != null) {
        await _prefs.setBool('is_logged_in', true);
        await _prefs.setBool('is_guest', false);
      }
    }

    return userCredential;
  }

  /// Save fallback local session when Firebase is unavailable/offline
  Future<void> saveFallbackSession({required String email, String? displayName}) async {
    await _secureStorageService.saveUserSession(
      userId: 'local_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName ?? 'User',
    );
    if (_prefs != null) {
      await _prefs.setBool('is_logged_in', true);
      await _prefs.setBool('is_guest', false);
    }
  }

  /// Complete sign out: clears secure storage, shared preferences, Google & Firebase Auth sessions
  Future<void> signOut() async {
    try {
      await _secureStorageService.clearAllData();
    } catch (_) {}

    if (_prefs != null) {
      await _prefs.setBool('is_logged_in', false);
      await _prefs.setBool('is_guest', false);
      await _prefs.remove('company_info_data');
      await _prefs.remove('saved_invoices');
    }

    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
  }
}
