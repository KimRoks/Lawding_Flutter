import '../../domain/entities/user_profile.dart';

class UserProfileResponse {
  final int id;
  final String username;
  final String email;
  final String provider;
  final String nickname;
  final bool onboardingCompleted;
  final bool deleted;

  const UserProfileResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.provider,
    required this.nickname,
    required this.onboardingCompleted,
    required this.deleted,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      provider: json['provider'] as String,
      nickname: json['nickname'] as String,
      onboardingCompleted: json['onboardingCompleted'] as bool,
      deleted: json['deleted'] as bool,
    );
  }

  UserProfile toDomain() => UserProfile(
    id: id,
    username: username,
    email: email,
    provider: provider,
    nickname: nickname,
    onboardingCompleted: onboardingCompleted,
    deleted: deleted,
  );
}
