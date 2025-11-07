/// API constants and endpoints
class ApiConstants {
  // Base URLs
  static const String devBaseUrl = 'https://api.dev.example.com';
  static const String prodBaseUrl = 'https://api.example.com';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Add your API endpoints here
  // Example:
  // static const String users = '/users';
  // static const String posts = '/posts';
}
