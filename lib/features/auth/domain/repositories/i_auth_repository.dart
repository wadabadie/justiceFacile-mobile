import '../entities/user_entity.dart';

abstract interface class IAuthRepository {
  Future<String?> getAccessToken();
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  });
  Future<void> logout();
}
