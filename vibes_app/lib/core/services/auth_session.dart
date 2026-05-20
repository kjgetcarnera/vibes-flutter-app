import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  static const _keyToken = 'auth_token';
  static const _keyUserId = 'auth_user_id';
  static const _keyOnboarding = 'auth_onboarding_status';

  String? _accessToken;
  int? _userId;
  String? _onboardingStatus;

  String? get accessToken => _accessToken;
  int? get userId => _userId;
  String? get onboardingStatus => _onboardingStatus;
  bool get isLoggedIn => _accessToken != null;

  String get authHeader => 'Bearer $_accessToken';

  /// Called once at app start to restore a previously saved session.
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_keyToken);
    _userId = prefs.getInt(_keyUserId);
    _onboardingStatus = prefs.getString(_keyOnboarding);
  }

  Future<void> save({
    required String accessToken,
    required int userId,
    required String onboardingStatus,
  }) async {
    _accessToken = accessToken;
    _userId = userId;
    _onboardingStatus = onboardingStatus;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, accessToken);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyOnboarding, onboardingStatus);
  }

  Future<void> clear() async {
    _accessToken = null;
    _userId = null;
    _onboardingStatus = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyOnboarding);
  }
}
