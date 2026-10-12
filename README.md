# google_sign_in_merged

One Google Sign-In API for **Android, iOS and web**. It wraps
[`google_sign_in`](https://pub.dev/packages/google_sign_in) on mobile and
[`google_sign_in_web`](https://pub.dev/packages/google_sign_in_web) (Google Identity
Services) on web. Whichever platform the user signs in on, the result reaches you the same
way: the Google **ID token** published as a reactive `Stream<String?>`.

Hand that token to Firebase Auth or your own backend.

## Features

- A single `GoogleSignInMerged` class for every platform. The right implementation is
  picked at compile time, and the web build works with `--wasm`.
- `idTokenChanges` is a reactive stream that replays the current ID token and emits
  on every sign-in/sign-out. It plugs straight into `emit.forEach` /
  `StreamBuilder`.
- Web uses the official GIS rendered button (`renderButton()`). Android and iOS use your
  own button calling `signIn()`.
- `init()` is safe to call more than once.

## Installation

```yaml
dependencies:
  google_sign_in_merged:
    path: ../google_sign_in_merged   # or a git: dependency
```

## Platform setup

The package does no native configuration itself. Every platform must be set up exactly as
the underlying official plugins require:

| Platform | Official guide |
|---|---|
| Overview | [google_sign_in — Platform integration](https://pub.dev/packages/google_sign_in#platform-integration) |
| Android | [google_sign_in_android — Integration](https://pub.dev/packages/google_sign_in_android#integration) · [Sign in with Google via Credential Manager](https://developer.android.com/identity/sign-in/credential-manager-siwg) |
| iOS | [google_sign_in_ios — iOS integration](https://pub.dev/packages/google_sign_in_ios#ios-integration) |
| Web | [google_sign_in_web — Integration](https://pub.dev/packages/google_sign_in_web#integration) · [Get your Google API client ID](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid) |
| Firebase (optional) | [Firebase Auth — Google sign-in for Flutter](https://firebase.google.com/docs/auth/flutter/federated-auth#google) |

OAuth clients are created in the
[Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials)
page. If you use Firebase, its project already contains them.

### Which client id goes where

| `EnvGoogle` field | Value | Used as |
|---|---|---|
| `serverClientId` (required) | **Web application** OAuth client id (`…apps.googleusercontent.com`) | `clientId` on web, `serverClientId` on Android/iOS. This sets the ID token's audience. |
| `clientId` (optional) | **iOS** OAuth client id | `clientId` on iOS. Omit it when `GIDClientID` is already in `Info.plist` / `GoogleService-Info.plist`. |

Notes:

- **Android:** register the app's signing SHA-1 (debug and release) on an Android OAuth
  client in the same project. A `DEVELOPER_ERROR` / `canceled` at sign-in almost always
  means a SHA-1 or client-id mismatch.
- **iOS:** add the reversed client id URL scheme to `Info.plist`, as the iOS guide
  describes.
- **Web:** add your origins (including `http://localhost:<port>` for development) under
  *Authorized JavaScript origins*. The client id is passed in code, so the
  `google-signin-client_id` meta tag is optional.

## Usage

The package is **reactive**. `idTokenChanges` is a `Stream<String?>`. Like
`FirebaseAuth.authStateChanges()`, it replays the current value on listen and then emits
every change. Treat it as the single source of truth for the session.

Why a stream instead of the `Future` returned by `signIn()`? On web there *is* no awaitable
sign-in: the user taps Google's rendered button, and the result only arrives as an
event. Subscribing to the stream handles web and mobile identically.

### Minimal

```dart
final googleSignIn = GoogleSignInMerged(
  env: EnvGoogle(
    serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    // clientId: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com', // iOS, optional
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await googleSignIn.init(); // must complete before renderButton/signIn/signOut
  runApp(const App());
}

// anywhere
googleSignIn.idTokenChanges.listen((idToken) { /* null = signed out */ });
```

### Clean Architecture + BLoC (recommended)

The package lives in the **data layer** only. The domain layer knows nothing about Google,
and the BLoC subscribes to a domain stream with `emit.forEach`. There are no listeners
to add or remove by hand and no `ValueNotifier` leaking into the UI.

```
lib/
├── main.dart                                   // composition root
├── data/
│   ├── data_sources/google_auth_data_source.dart
│   └── repositories/auth_repository.dart
├── domain/
│   ├── entities/auth_session.dart
│   ├── exceptions/auth_exceptions.dart
│   ├── repositories/i_auth_repository.dart
│   └── use_cases/ (watch_session, sign_in_with_google, sign_out)
└── presentation/
    ├── bloc/ (auth_bloc, auth_event, auth_state)
    └── pages/sign_in_page.dart
```

#### Domain

```dart
// domain/entities/auth_session.dart
class AuthSession {
  const AuthSession({required this.idToken});
  final String idToken;
}

// domain/exceptions/auth_exceptions.dart
sealed class AuthException implements Exception {}
final class SignInCancelledException extends AuthException {}
final class SignInFailedException extends AuthException {
  SignInFailedException(this.cause);
  final Object cause;
}

// domain/repositories/i_auth_repository.dart
abstract interface class IAuthRepository {
  /// Current session on listen, then every change. `null` = signed out.
  Stream<AuthSession?> watchSession();

  /// Completes when the platform flow finishes. The session itself arrives
  /// through [watchSession]. Throws [AuthException].
  Future<void> signInWithGoogle();

  Future<void> signOut();
}

// domain/use_cases/*.dart
class WatchSessionUseCase {
  const WatchSessionUseCase(this._repository);
  final IAuthRepository _repository;
  Stream<AuthSession?> call() => _repository.watchSession();
}

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);
  final IAuthRepository _repository;
  Future<void> call() => _repository.signInWithGoogle();
}

class SignOutUseCase {
  const SignOutUseCase(this._repository);
  final IAuthRepository _repository;
  Future<void> call() => _repository.signOut();
}
```

#### Data

```dart
// data/data_sources/google_auth_data_source.dart
import 'package:google_sign_in_merged/google_sign_in_merged.dart';

class GoogleAuthDataSource {
  const GoogleAuthDataSource(this._googleSignIn);
  final GoogleSignInMerged _googleSignIn;

  Stream<String?> idTokenChanges() => _googleSignIn.idTokenChanges;
  Future<void> signIn() => _googleSignIn.signIn();
  Future<void> signOut() => _googleSignIn.signOut();
}

// data/repositories/auth_repository.dart
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository implements IAuthRepository {
  const AuthRepository(this._dataSource);
  final GoogleAuthDataSource _dataSource;

  @override
  Stream<AuthSession?> watchSession() => _dataSource.idTokenChanges().map(
    (idToken) => idToken == null ? null : AuthSession(idToken: idToken),
  );

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _dataSource.signIn();
    } on GoogleSignInException catch (e) {
      // SDK errors are translated here, so the domain never sees them.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw SignInCancelledException();
      }
      throw SignInFailedException(e);
    }
  }

  @override
  Future<void> signOut() => _dataSource.signOut();
}
```

**With Firebase Auth**, only `watchSession()` changes. Exchange each token for a Firebase
user inside the stream, and the domain and BLoC stay untouched:

```dart
@override
Stream<AuthSession?> watchSession() => _dataSource.idTokenChanges().asyncMap(
  (idToken) async {
    if (idToken == null) return null;
    await _firebaseAuth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    return AuthSession(idToken: idToken);
  },
);
```

#### Presentation — BLoC

```dart
// presentation/bloc/auth_event.dart
sealed class AuthEvent {
  const AuthEvent();
}
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}
final class AuthGoogleSignInPressed extends AuthEvent {
  const AuthGoogleSignInPressed();
}
final class AuthSignOutPressed extends AuthEvent {
  const AuthSignOutPressed();
}

// presentation/bloc/auth_state.dart
enum EAuthStatus { unknown, authenticated, unauthenticated, failure }

class AuthState {
  const AuthState({this.status = EAuthStatus.unknown, this.session});
  final EAuthStatus status;
  final AuthSession? session;
}

// presentation/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._watchSession,
    required this._signInWithGoogle,
    required this._signOut,
  }) : super(const AuthState()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthGoogleSignInPressed>(_onGoogleSignInPressed);
    on<AuthSignOutPressed>(_onSignOutPressed);
  }

  final WatchSessionUseCase _watchSession;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;

  /// The ONLY place session state is emitted. The subscription lives as long
  /// as the bloc and is cancelled automatically on close().
  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) => emit.forEach<AuthSession?>(
    _watchSession(),
    onData: (session) => AuthState(
      status: session == null
          ? EAuthStatus.unauthenticated
          : EAuthStatus.authenticated,
      session: session,
    ),
    onError: (_, _) => const AuthState(status: EAuthStatus.failure),
  );

  /// Mobile only (web signs in via the rendered button). On success it emits
  /// nothing: the new session arrives through the stream above.
  Future<void> _onGoogleSignInPressed(
    AuthGoogleSignInPressed event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _signInWithGoogle();
    } on SignInCancelledException {
      // user closed the picker — keep the current state
    } on SignInFailedException {
      emit(const AuthState(status: EAuthStatus.failure));
    }
  }

  Future<void> _onSignOutPressed(
    AuthSignOutPressed event,
    Emitter<AuthState> emit,
  ) => _signOut(); // the stream emits null → unauthenticated
}
```

#### Presentation — UI

```dart
// presentation/pages/sign_in_page.dart
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  void _onGooglePressed(BuildContext context) =>
      context.read<AuthBloc>().add(const AuthGoogleSignInPressed());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GoogleSignInMerged.usesRenderedButton
            // Web: GIS draws the button; its result reaches the bloc via the stream.
            ? context.read<GoogleSignInMerged>().renderButton()
            : ElevatedButton(
                onPressed: () => _onGooglePressed(context),
                child: const Text('Continue with Google'),
              ),
      ),
    );
  }
}
```

#### Composition root

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final googleSignIn = GoogleSignInMerged(
    env: EnvGoogle(serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com'),
  );
  await googleSignIn.init();

  final IAuthRepository authRepository =
      AuthRepository(GoogleAuthDataSource(googleSignIn));

  runApp(
    RepositoryProvider.value(
      value: googleSignIn, // only for renderButton() on web
      child: BlocProvider(
        create: (_) => AuthBloc(
          watchSession: WatchSessionUseCase(authRepository),
          signInWithGoogle: SignInWithGoogleUseCase(authRepository),
          signOut: SignOutUseCase(authRepository),
        )..add(const AuthSubscriptionRequested()),
        child: MaterialApp(
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => switch (state.status) {
              EAuthStatus.unknown => const Center(
                child: CircularProgressIndicator(),
              ),
              EAuthStatus.authenticated => const HomePage(),
              EAuthStatus.unauthenticated ||
              EAuthStatus.failure => const SignInPage(),
            },
          ),
        ),
      ),
    ),
  );
}
```

With get_it/injectable, register the same objects as singletons instead of building them
in `main`.

For a runnable version of this exact structure, see the [`example/`](example/) app.

### Avoid

- Calling `signIn()` and reading the token from its result. That path doesn't exist on
  web, and it creates a second source of truth beside the stream.
- Listening with `.listen()` inside widgets or blocs and storing the subscription by
  hand. Use `emit.forEach` (BLoC) or `StreamBuilder` (no BLoC) so cancellation is
  automatic.
- Calling `init()` from widgets. Call it once in `main` before `runApp`.

## Limitations

- Only the **ID token** is exposed: no access token, no extra scopes, and no profile data.
- Every `GoogleSignInMerged` instance shares one underlying sign-in instance and one
  token stream. Create one and reuse it.
- Returning users are not signed in silently on launch. They tap the button again.
- On web, `signOut()` signs out of the app session, not out of the Google account.

## Migrating from the `webPushCertificate` version

`EnvGoogle.webPushCertificate` has been removed. It held the Firebase Cloud Messaging web
push (VAPID) key, which mobile wrongly used as the OAuth `serverClientId`. Pass the Web
client id as `serverClientId` and nothing else. In addition:

- `init()` now returns a `Future`. Await it.
- `authToken` (`ValueNotifier`) was replaced by `idTokenChanges` (`Stream<String?>`)
  and `idToken`. Replace `addListener` with `emit.forEach` / `StreamBuilder`.
- Mobile `signOut()` no longer revokes access (it no longer calls `disconnect()`).
