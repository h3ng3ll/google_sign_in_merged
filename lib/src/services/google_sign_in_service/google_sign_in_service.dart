import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../models/env_google/env_google.dart';
import 'src/google_sign_in_service_mobile.dart'
    if (dart.library.js_interop) 'src/google_sign_in_service_web.dart';

class GoogleSignInService {
  GoogleSignInService._();

  static final instance = GoogleSignInService._();

  final StreamController<String?> _idTokenController =
      StreamController<String?>.broadcast();

  String? _idToken;

  String? get idToken => _idToken;

  /// Emits the current token immediately on listen, then every change.
  /// `Stream.multi` subscribes synchronously, so no change between the
  /// replayed value and the live updates can be missed.
  Stream<String?> get idTokenChanges => Stream.multi(
    (controller) {
      controller.add(_idToken);
      final subscription = _idTokenController.stream.listen(
        controller.add,
        onError: controller.addError,
      );
      controller.onCancel = subscription.cancel;
    },
  );

  Future<void> init(EnvGoogle env) async {
    await instanceImpl.init(
      env,
      _setIdToken,
    );
  }

  void _setIdToken(String? token) {
    if (token == _idToken) return;
    _idToken = token;
    _idTokenController.add(token);
  }

  Future<void> signIn() async {
    await instanceImpl.signIn();
  }

  Future<void> signOut() async {
    await instanceImpl.signOut();
  }

  Widget renderButton() {
    return instanceImpl.renderButton();
  }

  Future<void> dispose() async {
    await instanceImpl.dispose();
  }
}
