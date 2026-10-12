import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/use_cases/sign_in_with_google_use_case.dart';
import '../../domain/use_cases/sign_out_use_case.dart';
import '../../domain/use_cases/watch_session_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

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
    onError: (error, _) =>
        AuthState(status: EAuthStatus.failure, errorMessage: '$error'),
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
      // The user closed the picker; keep the current state.
    } on SignInFailedException catch (e) {
      emit(AuthState(status: EAuthStatus.failure, errorMessage: '$e'));
    }
  }

  /// The stream emits `null` afterwards, which maps to unauthenticated.
  Future<void> _onSignOutPressed(
    AuthSignOutPressed event,
    Emitter<AuthState> emit,
  ) => _signOut();
}
