import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../models/env_google/env_google.dart';



class GoogleSignInServiceMobile {
  GoogleSignInServiceMobile._();

  static final instance = GoogleSignInServiceMobile._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> init(EnvGoogle env, ValueNotifier<String?> authToken) async {
    await _googleSignIn.initialize(
      serverClientId: env.webPushCertificate,
    );
    _googleSignIn.authenticationEvents.listen((event) {
      final user = switch (event) {
        GoogleSignInAuthenticationEventSignIn() => event.user,
        _ => null,
      };

      if (user?.authentication.idToken != null) {
        final token = user!.authentication.idToken!;
        if (kDebugMode) {
          print('MOBILE TOKEN: $token');
        }

        /// 🔥 тот же notifier
        authToken.value = token;
      }
    }, onError: _onAuthenticationEventError);
  }

  /// `authenticate()` rethrows the same error to its caller, which already
  /// maps it (a user cancel included) to a failure. The stream copy must be
  /// consumed here, or it escapes as an uncaught error and is recorded by
  /// Crashlytics as a fatal crash.
  void _onAuthenticationEventError(Object error) {
    if (kDebugMode) {
      print('Google sign-in event error: $error');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }

  Widget renderButton() {
    return Container();
  }
}

final instanceImpl = GoogleSignInServiceMobile.instance;
