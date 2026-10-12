import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in_merged/google_sign_in_merged.dart';

import 'data/data_sources/google_auth_data_source.dart';
import 'data/repositories/auth_repository.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'domain/use_cases/sign_in_with_google_use_case.dart';
import 'domain/use_cases/sign_out_use_case.dart';
import 'domain/use_cases/watch_session_use_case.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/pages/auth_gate.dart';
import 'presentation/pages/missing_config_page.dart';

/// Web application OAuth client id.
const _kServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

/// Optional iOS OAuth client id (omit when GIDClientID is in Info.plist).
const _kIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

/// Composition root: the only place that knows every layer.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_kServerClientId.isEmpty) {
    runApp(const MaterialApp(home: MissingConfigPage()));
    return;
  }

  final googleSignIn = GoogleSignInMerged(
    env: EnvGoogle(
      serverClientId: _kServerClientId,
      clientId: _kIosClientId.isEmpty ? null : _kIosClientId,
    ),
  );
  await googleSignIn.init();

  final IAuthRepository authRepository = AuthRepository(
    GoogleAuthDataSource(googleSignIn),
  );

  runApp(
    RepositoryProvider.value(
      // Exposed only for renderButton() on web.
      value: googleSignIn,
      child: BlocProvider(
        create: (_) => AuthBloc(
          watchSession: WatchSessionUseCase(authRepository),
          signInWithGoogle: SignInWithGoogleUseCase(authRepository),
          signOut: SignOutUseCase(authRepository),
        )..add(const AuthSubscriptionRequested()),
        child: MaterialApp(
          title: 'google_sign_in_merged example',
          theme: ThemeData(colorSchemeSeed: Colors.blue),
          home: const AuthGate(),
        ),
      ),
    ),
  );
}
