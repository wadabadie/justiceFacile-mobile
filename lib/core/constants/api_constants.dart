abstract final class ApiConstants {
  // Production API hosted on Railway
  static const baseUrl = 'https://justicefacile-backend-production.up.railway.app/api/v1';

  // Auth endpoints
  static const login        = '$baseUrl/auth/login/';
  static const register     = '$baseUrl/auth/register/';
  static const tokenRefresh = '$baseUrl/auth/token/refresh/';
  static const verifyEmail  = '$baseUrl/auth/verify-email/';
  static const resendCode   = '$baseUrl/auth/resend-verification/';
  static const googleAuth   = '$baseUrl/auth/google/';
}
