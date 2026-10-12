# google_sign_in_merged example

A small app showing how to use `google_sign_in_merged` with **Clean Architecture + BLoC**
on top of the package's reactive `idTokenChanges` stream. It runs on Android, iOS and web.

## Run

1. Configure Google Sign-In for each platform you run on. Follow the official guides
   linked in the [package README](../README.md#platform-setup).
2. Pass your **Web application** OAuth client id:

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<id>.apps.googleusercontent.com

# iOS without GIDClientID in Info.plist:
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<web id> \
            --dart-define=GOOGLE_IOS_CLIENT_ID=<ios id>

# Web: the origin must be listed under "Authorized JavaScript origins"
flutter run -d chrome --web-port 5000 --dart-define=GOOGLE_SERVER_CLIENT_ID=<web id>
```

If no client id is passed, the app shows a short hint screen instead of crashing.

Per-platform notes:

- **Android:** the `com.example.google_sign_in_merged_example` package and your debug
  SHA-1 must be registered on an Android OAuth client in the same Cloud project.
- **iOS:** add the reversed iOS client id as a URL scheme in `ios/Runner/Info.plist`
  (`CFBundleURLTypes`), as described in the iOS guide.

## Structure

```
lib/
├── main.dart                       composition root (wires every layer)
├── domain/                         pure Dart, knows nothing about Google
│   ├── entities/auth_session.dart
│   ├── exceptions/auth_exceptions.dart
│   ├── repositories/i_auth_repository.dart
│   └── use_cases/                  watch_session · sign_in_with_google · sign_out
├── data/
│   ├── data_sources/google_auth_data_source.dart   the only file using the package
│   └── repositories/auth_repository.dart           token → AuthSession, SDK errors → domain
└── presentation/
    ├── bloc/                       AuthBloc: emit.forEach(watchSession())
    ├── pages/                      AuthGate · SignInPage · HomePage · MissingConfigPage
    └── widgets/google_sign_in_button.dart          renderButton() on web, FilledButton on mobile
```

## Flow

1. `main` awaits `GoogleSignInMerged.init()` and then creates `AuthBloc`, which subscribes
   once with `AuthSubscriptionRequested`.
2. The user signs in. On web they tap the GIS button; on Android/iOS the button sends
   `AuthGoogleSignInPressed`, which calls `signIn()`.
3. The package publishes the ID token on `idTokenChanges`. The repository maps it to an
   `AuthSession`, and `emit.forEach` emits `authenticated`.
4. `AuthGate` rebuilds and shows `HomePage`. No navigation call is needed.
5. Sign out: the stream emits `null`, the state becomes `unauthenticated`, and the
   `SignInPage` is shown again.
