/// A custom exception class for authentication errors.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}
