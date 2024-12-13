import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _isLoggedInKey = "is_logged_in";

  Future<void> saveSession(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  Future<bool> isSessionActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_isLoggedInKey);
  }
}
