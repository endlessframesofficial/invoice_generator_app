import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const String keyPremiumEnabled = 'premium_enabled';
  static const String keyFreeInvoiceLimit = 'free_invoice_limit';
  static const String keyMinimumAppVersion = 'minimum_app_version';
  static const String keyMaintenanceMode = 'maintenance_mode';

  /// Initialize Remote Config with default fallback parameters
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode ? const Duration(hours: 0) : const Duration(hours: 12),
      ));

      await _remoteConfig.setDefaults({
        keyPremiumEnabled: false,
        keyFreeInvoiceLimit: 999999,
        keyMinimumAppVersion: '1.0.0',
        keyMaintenanceMode: false,
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config initialization warning: $e');
    }
  }

  bool get isPremiumEnabled => _remoteConfig.getBool(keyPremiumEnabled);
  int get freeInvoiceLimit => _remoteConfig.getInt(keyFreeInvoiceLimit);
  String get minimumAppVersion => _remoteConfig.getString(keyMinimumAppVersion);
  bool get isMaintenanceMode => _remoteConfig.getBool(keyMaintenanceMode);
}
