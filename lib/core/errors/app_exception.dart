/// Lightweight application-level exception for the data layer.
///
/// Repository implementations catch low-level/Supabase errors and rethrow them
/// as an [AppException] so the presentation layer can depend on a single,
/// stable error type that always carries a user-presentable [message].
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
