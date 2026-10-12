/// Google OAuth client ids used to initialize sign-in.
class EnvGoogle {
  /// The **Web application** OAuth client id
  /// (`xxxx.apps.googleusercontent.com`).
  ///
  /// Used as `clientId` on web and as `serverClientId` on Android/iOS, so the
  /// issued ID token's audience is this client (required by Firebase Auth and
  /// most backends).
  final String serverClientId;

  /// Optional platform OAuth client id (iOS client id). Leave `null` when it
  /// is provided by `GoogleService-Info.plist` / `Info.plist` (`GIDClientID`).
  final String? clientId;

  new({
    required this.serverClientId,
    this.clientId,
  });
}
