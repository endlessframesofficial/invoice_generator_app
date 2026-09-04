import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../main.dart';
import '../../domain/company_info.dart';

part 'company_provider.g.dart';

@riverpod
class CompanyInfoState extends _$CompanyInfoState {
  static const _prefsKey = 'company_info_data';

  @override
  CompanyInfo build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        return CompanyInfo.fromJson(json);
      } catch (_) {
        // Fallback
      }
    }

    // Default to actual logged in user's profile details if available
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return CompanyInfo(
        name: user.displayName ?? '',
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
        address: '',
      );
    }

    return const CompanyInfo(
      name: '',
      address: '',
      phone: '',
      email: '',
    );
  }

  Future<void> updateCompanyInfo(CompanyInfo info) async {
    state = info;
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonStr = jsonEncode(info.toJson());
    await prefs.setString(_prefsKey, jsonStr);
  }
}
