part of 'auth_bloc.dart';

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
