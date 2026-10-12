import '../entities/auth_session.dart';

abstract interface class IAuthRepository {
  /// Current session on listen, then every change. `null` = signed out.
  Stream<AuthSession?> watchSession();

  /// Completes when the platform flow finishes. The session itself arrives
  /// through [watchSession]. Throws `AuthException`.
  Future<void> signInWithGoogle();

  Future<void> signOut();
}
