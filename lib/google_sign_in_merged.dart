library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'src/models/env_google/env_google.dart';
import 'src/services/google_sign_in_service/google_sign_in_service.dart';

export 'src/models/env_google/env_google.dart';

class GoogleSignInMerged {
  final GoogleSignInService _googleSignInService = GoogleSignInService.instance;

  final EnvGoogle _env;

  new({
    required this._env,
  });

  /// `true` on web, where sign-in happens only through [renderButton];
  /// `false` on Android/iOS, where your own button calls [signIn].
  static bool get usesRenderedButton => kIsWeb;

  /// Google ID token of the signed-in user (`null` when signed out).
  /// Emits the current value on listen, then every change — like
  /// `FirebaseAuth.authStateChanges()`.
  Stream<String?> get idTokenChanges => _googleSignInService.idTokenChanges;

  /// The latest ID token, or `null` when signed out.
  String? get idToken => _googleSignInService.idToken;

  Future<void> init() => _googleSignInService.init(_env);

  Future<void> signIn() => _googleSignInService.signIn();

  Future<void> signOut() => _googleSignInService.signOut();

  Widget renderButton() => _googleSignInService.renderButton();

  Future<void> dispose() => _googleSignInService.dispose();
}
