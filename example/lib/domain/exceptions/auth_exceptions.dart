sealed class AuthException implements Exception {}

final class SignInCancelledException extends AuthException {}

final class SignInFailedException extends AuthException {
  SignInFailedException(this.cause);

  final Object cause;

  @override
  String toString() => 'Sign-in failed: $cause';
}
