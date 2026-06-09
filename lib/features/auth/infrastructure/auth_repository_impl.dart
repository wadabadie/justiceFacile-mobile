import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/i_auth_repository.dart';

// Stub implementation — swap every method body with a real HTTP call (Dio)
// when the Django API is ready. Keys must stay consistent with restoreSession().
final class AuthRepositoryImpl implements IAuthRepository {
  static const _kToken     = 'access_token';
  static const _kRefresh   = 'refresh_token';
  static const _kFirstName = 'user_first_name';
  static const _kLastName  = 'user_last_name';
  static const _kEmail     = 'user_email';
  static const _kRole      = 'user_role';

  @override
  Future<String?> getAccessToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kToken);
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    // TODO: replace with POST /api/v1/auth/login/ — expect {tokens, user}
    await Future.delayed(const Duration(milliseconds: 900));
    if (email.isEmpty || password.length < 8) {
      throw Exception('invalid_credentials');
    }
    const token   = 'stub_access_token';
    const refresh = 'stub_refresh_token';
    await _persistSession(
      token: token, refresh: refresh,
      firstName: 'Marie', lastName: 'Dupont',
      email: email, role: 'citoyen',
    );
    return const UserEntity(
      id: 1, firstName: 'Marie', lastName: 'Dupont',
      email: 'marie@example.com', role: 'citoyen',
      accessToken: token, refreshToken: refresh,
    );
  }

  @override
  Future<UserEntity> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    // TODO: replace with POST /api/v1/auth/register/ — expect {tokens, user}
    await Future.delayed(const Duration(milliseconds: 900));
    const token   = 'stub_access_new';
    const refresh = 'stub_refresh_new';
    await _persistSession(
      token: token, refresh: refresh,
      firstName: firstName, lastName: lastName,
      email: email, role: role,
    );
    return UserEntity(
      id: 2, firstName: firstName, lastName: lastName,
      email: email, role: role,
      accessToken: token, refreshToken: refresh,
    );
  }

  @override
  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    // Clear all session keys on logout — never leave a stale token on device
    for (final k in [_kToken, _kRefresh, _kFirstName, _kLastName, _kEmail, _kRole]) {
      await p.remove(k);
    }
  }

  // Rehydrate UserEntity from local storage — called by SplashScreen to skip login
  Future<UserEntity?> restoreSession() async {
    final p     = await SharedPreferences.getInstance();
    final token = p.getString(_kToken);
    if (token == null) return null;
    return UserEntity(
      id:        0,
      firstName: p.getString(_kFirstName) ?? '',
      lastName:  p.getString(_kLastName)  ?? '',
      email:     p.getString(_kEmail)     ?? '',
      role:      p.getString(_kRole)      ?? 'citoyen',
      accessToken: token,
    );
  }

  Future<void> _persistSession({
    required String token,
    required String refresh,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken,     token);
    await p.setString(_kRefresh,   refresh);
    await p.setString(_kFirstName, firstName);
    await p.setString(_kLastName,  lastName);
    await p.setString(_kEmail,     email);
    await p.setString(_kRole,      role);
  }
}
