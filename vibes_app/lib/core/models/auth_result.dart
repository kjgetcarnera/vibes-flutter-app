class AuthUser {
  final int id;
  final String name;
  final String email;
  final String? profilePic;
  final String? nickname;
  final int? bornYear;
  final String status;
  final bool emailVerified;
  final String onboardingStatus;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.profilePic,
    this.nickname,
    this.bornYear,
    required this.status,
    required this.emailVerified,
    required this.onboardingStatus,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        profilePic: json['profile_pic'] as String?,
        nickname: json['nickname'] as String?,
        bornYear: json['born_year'] as int?,
        status: json['status'] as String? ?? '',
        emailVerified: json['email_verified'] as bool? ?? false,
        onboardingStatus: json['onboarding_status'] as String? ?? 'not_started',
      );
}

class AuthResult {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final AuthUser user;
  final bool otpSent;

  const AuthResult({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    required this.otpSent,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String? ?? 'bearer',
        expiresIn: json['expires_in'] as int? ?? 0,
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        otpSent: json['otp_sent'] as bool? ?? false,
      );
}
