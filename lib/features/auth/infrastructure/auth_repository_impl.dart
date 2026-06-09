import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/i_auth_repository.dart';

final class AuthRepositoryImpl implements IAuthRepository {
  static const _kToken     = 'access_token';
  static const _kRefresh   = 'refresh_token';
  static const _kFirstName = 'user_first_name';
  static const _kLastName  = 'user_last_name';
  static const _kEmail     = 'user_email';
  static const _kRole      = 'user_role';

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  @override
  Future<String?> getAccessToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kToken);
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return _handleAuthResponse(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['error'] ?? 'invalid_credentials';
      throw Exception(msg);
    }
  }

  @override
  Future<UserEntity> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.register,
        data: {
          'first_name': firstName,
          'last_name':  lastName,
          'email':      email,
          'password':   password,
          'role':       role,
        },
      );
      return _handleAuthResponse(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_extractError(e.response?.data));
    }
  }

  // Submits the 6-digit verification code received by email.
  Future<void> verifyEmail(String email, String code) async {
    try {
      await _dio.post(
        ApiConstants.verifyEmail,
        data: {'email': email, 'code': code},
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['error'] ?? 'invalid_code';
      throw Exception(msg);
    }
  }

  // Requests a new verification code to be sent by email.
  Future<void> resendVerificationCode(String email) async {
    try {
      await _dio.post(ApiConstants.resendCode, data: {'email': email});
    } on DioException catch (_) {
      throw Exception('resend_failed');
    }
  }

  @override
  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    for (final k in [_kToken, _kRefresh, _kFirstName, _kLastName, _kEmail, _kRole]) {
      await p.remove(k);
    }
  }

  // Rehydrate UserEntity from local storage — called by SplashScreen to skip login.
  Future<UserEntity?> restoreSession() async {
    final p     = await SharedPreferences.getInstance();
    final token = p.getString(_kToken);
    if (token == null) return null;
    return UserEntity(
      id:          0,
      firstName:   p.getString(_kFirstName) ?? '',
      lastName:    p.getString(_kLastName)  ?? '',
      email:       p.getString(_kEmail)     ?? '',
      role:        p.getString(_kRole)      ?? 'citoyen',
      accessToken: token,
    );
  }

  UserEntity _handleAuthResponse(Map<String, dynamic> data) {
    final user    = data['user']    as Map<String, dynamic>;
    final tokens  = data['tokens']  as Map<String, dynamic>;
    final profile = user['profile'] as Map<String, dynamic>? ?? {};

    final entity = UserEntity(
      id:           user['id'] as int? ?? 0,
      firstName:    user['first_name'] as String? ?? '',
      lastName:     user['last_name']  as String? ?? '',
      email:        user['email']      as String? ?? '',
      role:         profile['role']    as String? ?? 'citoyen',
      accessToken:  tokens['access']   as String? ?? '',
      refreshToken: tokens['refresh']  as String? ?? '',
    );

    _persistSession(
      token:     entity.accessToken ?? '',
      refresh:   entity.refreshToken ?? '',
      firstName: entity.firstName,
      lastName:  entity.lastName,
      email:     entity.email,
      role:      entity.role,
    );

    return entity;
  }

  // Extracts a human-readable message from DRF error responses.
  // Handles both {"error": "msg"} and {"field": ["msg"]} formats.
  String _extractError(dynamic data) {
    if (data is Map) {
      if (data.containsKey('error'))  return data['error'] as String;
      if (data.containsKey('detail')) return data['detail'] as String;
      // DRF field-level errors: take the first message of the first field
      final first = data.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    return 'request_failed';
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
