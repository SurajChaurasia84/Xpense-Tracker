import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService extends ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _lockKey = 'app_lock_enabled';
  bool _isLockEnabled = false;

  bool get isLockEnabledValue => _isLockEnabled;

  SecurityService() {
    init();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLockEnabled = prefs.getBool(_lockKey) ?? false;
    notifyListeners();
  }

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to open Xpense Tracker',
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  Future<void> setLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockKey, enabled);
    _isLockEnabled = enabled;
    notifyListeners();
  }
}
