## 0.0.1

* Initial release: one Google Sign-In API for Android, iOS and web that
  publishes the Google ID token through the `idTokenChanges` stream.
* `GoogleSignInMerged.init()` now returns a `Future` and is safe to call
  more than once.
* Added `signIn()` (Android/iOS), `dispose()` and `usesRenderedButton`.
* `authToken` (`ValueNotifier`) replaced by `idTokenChanges` (`Stream<String?>`,
  replays the current value) and `idToken`. It emits `null` on sign-out.
* **Breaking:** `EnvGoogle.webPushCertificate` removed. It was wrongly used
  as the mobile `serverClientId`. Added optional `EnvGoogle.clientId` (iOS).
* Mobile `signOut()` now signs out instead of revoking access (`disconnect`).
* Web implementation is selected with `dart.library.js_interop`
  (works with `--wasm`).
