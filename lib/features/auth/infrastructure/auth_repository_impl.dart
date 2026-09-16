import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/i_auth_repository.dart';

final class AuthRepositoryImpl implements IAuthRepository {
  static const _kToken     = 'access_token';
  static const _kRefresh   = 'refresh_token';
  static const _kFirstName = 'user_first_name';
  static const _kLastName  = 'user_last_name';
  static const _kEmail     = 'user_email';
  static const _kRole      = 'user_role';

  // Backend uses dj-rest-auth with GoogleOAuth2Adapter which expects access_token (not id_token).
  // serverClientId is not needed for the access_token flow.
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

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

  // Signs in with Google, then exchanges the Google access token with the backend.
  Future<UserEntity> loginWithGoogle() async {
    // Step 1 — Google account picker
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('google_cancelled');

    // Step 2 — Google OAuth tokens
    final auth        = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) throw Exception('google_no_token');

    // Step 3 — Backend exchange
    try {
      final res  = await _dio.post(
        ApiConstants.googleAuth,
        data: {'access_token': accessToken},
      );
      final data = res.data as Map<String, dynamic>;

      // dj-rest-auth returns {access, refresh, user}
      // custom login_view returns {user, tokens:{access, refresh}}
      if (data.containsKey('tokens')) {
        return _handleAuthResponse(data);
      }
      return _handleSocialAuthResponse(data);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final body       = e.response?.data;
      // Propagate a tagged error so the UI can show the real cause.
      throw Exception('google_backend_${statusCode}_${_extractError(body)}');
    }
  }

  // Submits the 6-digit verification code received by email.
  // Backend returns real JWT tokens after verification — save them so the user is logged in.
  Future<void> verifyEmail(String email, String code) async {
    try {
      final res = await _dio.post(
        ApiConstants.verifyEmail,
        data: {'email': email, 'code': code},
      );
      final data = res.data as Map<String, dynamic>? ?? {};
      final tokens = data['tokens'] as Map<String, dynamic>?;
      if (tokens != null) {
        final access  = tokens['access']  as String? ?? '';
        final refresh = tokens['refresh'] as String? ?? '';
        final user    = data['user']      as Map<String, dynamic>? ?? {};
        if (access.isNotEmpty) {
          await _persistSession(
            token:     access,
            refresh:   refresh,
            firstName: user['first_name'] as String? ?? '',
            lastName:  user['last_name']  as String? ?? '',
            email:     email,
            role:      (user['profile'] as Map?)?['role'] as String? ?? 'citoyen',
          );
        }
      }
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

  // Requests a password reset link (deep link) to be sent by email. Backend
  // always returns 200 with a generic message to avoid account enumeration.
  Future<void> requestPasswordReset(String email) async {
    try {
      await _dio.post(ApiConstants.demanderResetMdp, data: {'email': email});
    } on DioException catch (_) {
      throw Exception('reset_request_failed');
    }
  }

  // Uploads a single file (image or PDF) to Supabase via the backend proxy.
  // Returns the public URL to be sent later when submitting the certification.
  Future<String> uploadCertificationDocument({
    required String filePath,
    String categorie = 'certification',
  }) async {
    try {
      final form = FormData.fromMap({
        'categorie': categorie,
        'fichier': await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.post(ApiConstants.uploadDocument, data: form);
      final url = (res.data as Map<String, dynamic>?)?['url'] as String?;
      if (url == null || url.isEmpty) throw Exception('upload_no_url');
      return url;
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['error'] ?? 'upload_failed';
      throw Exception(msg);
    }
  }

  // Submits the certification package (URLs of already-uploaded documents +
  // role-specific text fields) for admin validation.
  Future<void> submitCertification(Map<String, dynamic> payload) async {
    try {
      await _dio.post(ApiConstants.soumettreDocuments, data: payload);
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map && body.isNotEmpty) {
        // Backend returns {champ: "raison"} for missing/invalid fields.
        final missing = body.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n');
        throw Exception(missing);
      }
      throw Exception('cert_submit_failed');
    }
  }

  // Fetches the current user's raw profile (including certification fields).
  // Used by the certification screen which needs details not exposed on UserEntity.
  Future<Map<String, dynamic>> fetchMyProfileRaw() async {
    final res = await ApiService.instance.get(ApiConstants.me);
    final data = res.data as Map<String, dynamic>;
    return (data['profile'] as Map<String, dynamic>?) ?? {};
  }

  // Confirms the reset with the 6-digit OTP received by email + new password.
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _dio.post(ApiConstants.confirmerResetMdp, data: {
        'email': email,
        'code': code,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['error'] ?? 'reset_confirm_failed';
      throw Exception(msg);
    }
  }

  @override
  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    for (final k in [_kToken, _kRefresh, _kFirstName, _kLastName, _kEmail, _kRole]) {
      await p.remove(k);
    }
    await _googleSignIn.signOut();
  }

  // Fetch full profile from API — includes phone, region, 2FA status.
  Future<UserEntity?> fetchMe() async {
    try {
      final res  = await ApiService.instance.get(ApiConstants.me);
      final data = res.data as Map<String, dynamic>;
      final prof = data['profile'] as Map<String, dynamic>? ?? {};
      return UserEntity(
        id:          data['id']         as int?    ?? 0,
        firstName:   data['first_name'] as String? ?? '',
        lastName:    data['last_name']  as String? ?? '',
        email:       data['email']      as String? ?? '',
        role:        prof['role']       as String? ?? 'citoyen',
        phone:       prof['telephone']  as String? ?? prof['phone'] as String?,
        region:      prof['region']     as String?,
        deuxFaActif: prof['deux_fa_actif'] as bool?
                  ?? prof['two_factor_enabled'] as bool?
                  ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  // Update profile fields — tries PATCH then PUT on /auth/me/.
  Future<void> updateMe({
    String? firstName,
    String? lastName,
    String? phone,
    String? region,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName  != null) body['last_name']  = lastName;
    if (phone     != null) body['telephone']  = phone;
    if (region    != null) body['region']     = region;
    try {
      await ApiService.instance.patch(ApiConstants.me, data: body);
    } on DioException catch (e) {
      if (e.response?.statusCode == 405) {
        // Backend doesn't expose a write endpoint yet — rethrow with clear message.
        throw Exception('endpoint_indisponible');
      }
      rethrow;
    }
  }

  // Toggle 2FA on/off — backend flips the current state.
  Future<void> toggle2FA() async {
    await ApiService.instance.post(ApiConstants.toggleDeuxFa, data: {});
  }

  // Permanently delete account.
  Future<void> deleteAccount() async {
    await ApiService.instance.delete(ApiConstants.supprimerCompte);
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

  // Handles dj-rest-auth social login response: {access, refresh, user:{pk,...}}
  UserEntity _handleSocialAuthResponse(Map<String, dynamic> data) {
    final access  = data['access']  as String? ?? '';
    final refresh = data['refresh'] as String? ?? '';
    final user    = data['user']    as Map<String, dynamic>? ?? {};

    final entity = UserEntity(
      id:           user['pk']         as int?    ?? user['id'] as int? ?? 0,
      firstName:    user['first_name'] as String? ?? '',
      lastName:     user['last_name']  as String? ?? '',
      email:        user['email']      as String? ?? '',
      role:         'citoyen',
      accessToken:  access,
      refreshToken: refresh,
    );

    _persistSession(
      token:     access,
      refresh:   refresh,
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
