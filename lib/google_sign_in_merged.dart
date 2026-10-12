library;

import 'package:flutter/material.dart';

import 'src/models/env_google/env_google.dart';
import 'src/services/google_sign_in_service/google_sign_in_service.dart';

export 'src/models/env_google/env_google.dart';

class GoogleSignInMerged {
  final GoogleSignInService _googleSignInService = GoogleSignInService.instance;

  final EnvGoogle _env;

  new({
    required this._env,
  });

  ValueNotifier<String?> get authToken => _googleSignInService.authToken;

  void init() {
    _googleSignInService.init(
      _env,
    );
  }

  Future<void> signOut() => _googleSignInService.signOut();

  Widget renderButton() => _googleSignInService.renderButton();
}
