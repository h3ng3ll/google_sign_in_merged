import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../models/env_google/env_google.dart';

class GoogleSignInServiceMobile {
  GoogleSignInServiceMobile._();

  static final instance = GoogleSignInServiceMobile._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;

  void Function(String? idToken)? _onIdToken;

  /// `GoogleSignIn.initialize` may run only once per app; concurrent and
  /// repeated `init` calls share this future.
  Future<void>? _initialization;

  bool _initialized = false;

  Future<void> init(
    EnvGoogle env,
    void Function(String? idToken) onIdToken,
  ) async {
    _onIdToken = onIdToken;
    await (_initialization ??= _googleSignIn.initialize(
      clientId: env.clientId,
      serverClientId: env.serverClientId,
    ));
    _initialized = true;
    _subscription ??= _googleSignIn.authenticationEvents.listen(
      _onAuthenticationEvent,
      onError: _onAuthenticationEventError,
    );
  }

  void _onAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        final token = event.user.authentication.idToken;
        if (token != null) {
          _onIdToken?.call(token);
        }
      case GoogleSignInAuthenticationEventSignOut():
        _onIdToken?.call(null);
    }
  }

  /// `authenticate()` rethrows the same error to its caller, which already
  /// maps it (a user cancel included) to a failure. The stream copy must be
  /// consumed here, or it escapes as an uncaught error and is recorded by
  /// Crashlytics as a fatal crash.
  void _onAuthenticationEventError(Object error) {
    debugPrint('Google sign-in event error: $error');
  }

  /// Opens the native Google account picker. The ID token is published to
  /// `idTokenChanges` through the authentication event stream; errors (including
  /// a user cancel, `GoogleSignInExceptionCode.canceled`) are rethrown.
  Future<void> signIn() async {
    _ensureInitialized();
    await _googleSignIn.authenticate();
  }

  Future<void> signOut() async {
    _ensureInitialized();
    await _googleSignIn.signOut();
    _onIdToken?.call(null);
  }

  Widget renderButton() {
    return const SizedBox.shrink();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('GoogleSignInMerged.init() must complete first.');
    }
  }
}

final instanceImpl = GoogleSignInServiceMobile.instance;
