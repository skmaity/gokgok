/// Route paths. Use these instead of raw strings so typos fail at
/// compile time instead of at runtime.
abstract final class AppRoutes {
  static const login = '/';
  static const dashboard = '/dashboard';
  static const signup = '/signup';
  static const profile = '/profile';
  static const chat = '/chat';
  static const chatMembers = '/chatMembers';
}
