part of 'auth_bloc.dart';

enum EAuthStatus { unknown, authenticated, unauthenticated, failure }

class AuthState {
  const AuthState({
    this.status = EAuthStatus.unknown,
    this.session,
    this.errorMessage,
  });

  final EAuthStatus status;
  final AuthSession? session;
  final String? errorMessage;
}
