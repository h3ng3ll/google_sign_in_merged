import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../models/env_google/env_google.dart';
import 'src/google_sign_in_service_mobile.dart'
    if (dart.library.html) 'src/google_sign_in_service_web.dart';

class GoogleSignInService {
  GoogleSignInService._();

  static final instance = GoogleSignInService._();

  final ValueNotifier<String?> authToken = ValueNotifier(null);

  Future<void> init(EnvGoogle env) async {
    await instanceImpl.init(
      env,
      authToken,
    );
  }

  Future<void> signOut() async {
    await instanceImpl.signOut();
  }

  Widget renderButton() {
    return instanceImpl.renderButton();
  }
}
