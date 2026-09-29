class ApiConstants {
  ApiConstants._();

  // Can be overridden at build time via --dart-define=API_BASE_URL=https://your-render-url.onrender.com
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ledgerly-backend.onrender.com',
  );

  static const String healthEndpoint = '/api/health';
  static const String userEndpoint = '/api/user';
  static const String loginEndpoint = '/api/auth/login';
  static const String signupEndpoint = '/api/auth/signup';
  static const String budgetEndpoint = '/api/budget';
  static const String transactionsEndpoint = '/api/transactions';
  static const String analyticsEndpoint = '/api/analytics';
  static const String aiChatEndpoint = '/api/ai/chat';
  static const String notificationsEndpoint = '/api/notifications';
}
