import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

// Thrown when the refresh token is expired — the app must redirect to /login.
class SessionExpiredException implements Exception {}

class ApiService {
  ApiService._() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  static final ApiService instance = ApiService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  // ── Interceptors ────────────────────────────────────────────────────────────

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Attempt silent token refresh.
    try {
      final newToken = await _refresh();
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      final response = await _dio.fetch(opts);
      handler.resolve(response);
    } on SessionExpiredException {
      await _clearSession();
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: SessionExpiredException(),
      ));
    } catch (_) {
      handler.next(err);
    }
  }

  // ── Token refresh ───────────────────────────────────────────────────────────

  Future<String> _refresh() async {
    final prefs   = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');
    if (refresh == null) throw SessionExpiredException();

    try {
      final res = await Dio().post(
        ApiConstants.tokenRefresh,
        data: {'refresh': refresh},
      );
      final access = res.data['access'] as String;
      await prefs.setString('access_token', access);
      return access;
    } on DioException {
      throw SessionExpiredException();
    }
  }

  // ── Session helpers ─────────────────────────────────────────────────────────

  Future<String?> _readToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('access_token');
  }

  Future<void> _clearSession() async {
    final p = await SharedPreferences.getInstance();
    for (final k in ['access_token', 'refresh_token', 'user_first_name',
                     'user_last_name', 'user_email', 'user_role']) {
      await p.remove(k);
    }
  }

  // ── Public HTTP methods ─────────────────────────────────────────────────────

  Future<Response> get(String url, {Map<String, dynamic>? params}) =>
      _dio.get(url, queryParameters: params);

  Future<Response> post(String url, {dynamic data}) =>
      _dio.post(url, data: data);

  Future<Response> put(String url, {dynamic data}) =>
      _dio.put(url, data: data);

  Future<Response> patch(String url, {dynamic data}) =>
      _dio.patch(url, data: data);

  Future<Response> delete(String url) => _dio.delete(url);

  // Multipart upload (documents, preuves, photos).
  Future<Response> postForm(String url, FormData form) =>
      _dio.post(url, data: form);

  // ── Error helper ────────────────────────────────────────────────────────────

  static String extractError(dynamic data) {
    if (data is Map) {
      if (data.containsKey('error'))  return data['error'] as String;
      if (data.containsKey('detail')) return data['detail'] as String;
      final first = data.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    return 'Une erreur est survenue.';
  }
}
