class ProfileMediaSession {
  const ProfileMediaSession({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;

  bool get isExpired => !expiresAt.isAfter(DateTime.now());
}
