import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../models/env_google/env_google.dart';

import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';


class GoogleSignInServiceWeb {
  GoogleSignInServiceWeb._();

  static final instance = GoogleSignInServiceWeb._();

  late final GoogleSignInPlugin _googleSignIn;

  Future<void> init(
    EnvGoogle env,
    ValueNotifier<String?> authToken,
  ) async {
    if (kIsWeb) {
      _googleSignIn = GoogleSignInPlugin();
      await _googleSignIn.init(
        InitParameters(
          clientId: env.serverClientId,
        ),
      );
      _googleSignIn.renderButton();

      _googleSignIn.authenticationEvents.listen(
        (event) {
          final data = switch (event) {
            AuthenticationEventSignIn() => event.authenticationTokens,
            _ => null,
          };

          if (data?.idToken != null) {
            final token = data!.idToken!;
            if (kDebugMode) {
              print('WEB TOKEN: $token');
            }

            /// 🔥 Write  in shared notifier
            authToken.value = token;
          }
        },
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut(
      SignOutParams(),
    );
  }

  Widget renderButton() {
    return _googleSignIn.renderButton();
  }
}

final instanceImpl = GoogleSignInServiceWeb.instance;
