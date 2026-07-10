class UserProfile {
  final int id;
  final String username;
  final String email;
  final String provider;
  final String nickname;
  final bool onboardingCompleted;
  final bool deleted;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.provider,
    required this.nickname,
    required this.onboardingCompleted,
    required this.deleted,
  });
}
