import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../data_sources/google_auth_data_source.dart';

class AuthRepository implements IAuthRepository {
  const AuthRepository(this._dataSource);

  final GoogleAuthDataSource _dataSource;

  @override
  Stream<AuthSession?> watchSession() => _dataSource.idTokenChanges().map(
    (idToken) => idToken == null ? null : AuthSession(idToken: idToken),
  );

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _dataSource.signIn();
    } on GoogleSignInException catch (e) {
      // SDK errors are translated here, so the domain never sees them.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw SignInCancelledException();
      }
      throw SignInFailedException(e);
    }
  }

  @override
  Future<void> signOut() => _dataSource.signOut();
}
