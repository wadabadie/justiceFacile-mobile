final class UserEntity {
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.accessToken,
    this.refreshToken,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? accessToken;
  final String? refreshToken;

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
}
