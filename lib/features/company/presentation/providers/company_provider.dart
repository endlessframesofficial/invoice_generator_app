import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/app_constants.dart';
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
        // Fallback to default constants on parsing error
      }
    }
    return const CompanyInfo(
      name: AppConstants.companyName,
      address: AppConstants.companyAddress,
      phone: AppConstants.companyPhone,
      email: AppConstants.companyEmail,
    );
  }

  Future<void> updateCompanyInfo(CompanyInfo info) async {
    state = info;
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonStr = jsonEncode(info.toJson());
    await prefs.setString(_prefsKey, jsonStr);
  }
}
