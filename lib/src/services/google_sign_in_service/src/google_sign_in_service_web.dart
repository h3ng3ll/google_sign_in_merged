import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';

import '../../../models/env_google/env_google.dart';

class GoogleSignInServiceWeb {
  GoogleSignInServiceWeb._();

  static final instance = GoogleSignInServiceWeb._();

  GoogleSignInPlugin? _googleSignIn;

  StreamSubscription<AuthenticationEvent>? _subscription;

  void Function(String? idToken)? _onIdToken;

  /// Concurrent and repeated `init` calls share this future.
  Future<void>? _initialization;

  Future<void> init(
    EnvGoogle env,
    void Function(String? idToken) onIdToken,
  ) async {
    _onIdToken = onIdToken;
    await (_initialization ??= _initialize(env));
    _subscription ??= _plugin.authenticationEvents.listen(
      _onAuthenticationEvent,
      onError: _onAuthenticationEventError,
    );
  }

  Future<void> _initialize(EnvGoogle env) async {
    final googleSignIn = GoogleSignInPlugin();
    await googleSignIn.init(
      InitParameters(
        clientId: env.serverClientId,
      ),
    );
    _googleSignIn = googleSignIn;
  }

  void _onAuthenticationEvent(AuthenticationEvent event) {
    switch (event) {
      case AuthenticationEventSignIn():
        final token = event.authenticationTokens.idToken;
        if (token != null) {
          _onIdToken?.call(token);
        }
      case AuthenticationEventSignOut():
        _onIdToken?.call(null);
      case AuthenticationEventException():
        debugPrint('Google sign-in event error: ${event.exception}');
    }
  }

  void _onAuthenticationEventError(Object error) {
    debugPrint('Google sign-in event error: $error');
  }

  /// Google Identity Services on web only signs in through its own rendered
  /// button — use [renderButton] instead.
  Future<void> signIn() {
    throw UnsupportedError(
      'signIn() is not supported on web. Show renderButton() instead.',
    );
  }

  Future<void> signOut() async {
    await _plugin.signOut(
      SignOutParams(),
    );
    _onIdToken?.call(null);
  }

  Widget renderButton() {
    return _plugin.renderButton();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  GoogleSignInPlugin get _plugin {
    final googleSignIn = _googleSignIn;
    if (googleSignIn == null) {
      throw StateError('GoogleSignInMerged.init() must complete first.');
    }
    return googleSignIn;
  }
}

final instanceImpl = GoogleSignInServiceWeb.instance;
