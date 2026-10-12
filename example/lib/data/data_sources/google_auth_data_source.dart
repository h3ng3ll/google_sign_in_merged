import 'package:google_sign_in_merged/google_sign_in_merged.dart';

/// The only class in the app that talks to the package.
class GoogleAuthDataSource {
  const GoogleAuthDataSource(this._googleSignIn);

  final GoogleSignInMerged _googleSignIn;

  Stream<String?> idTokenChanges() => _googleSignIn.idTokenChanges;

  Future<void> signIn() => _googleSignIn.signIn();

  Future<void> signOut() => _googleSignIn.signOut();
}
