class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  String? _accessToken;
  int? _userId;
  String? _onboardingStatus;

  String? get accessToken => _accessToken;
  int? get userId => _userId;
  String? get onboardingStatus => _onboardingStatus;
  bool get isLoggedIn => _accessToken != null;

  String get authHeader => 'Bearer $_accessToken';

  void save({
    required String accessToken,
    required int userId,
    required String onboardingStatus,
  }) {
    _accessToken = accessToken;
    _userId = userId;
    _onboardingStatus = onboardingStatus;
  }

  void clear() {
    _accessToken = null;
    _userId = null;
    _onboardingStatus = null;
  }
}
