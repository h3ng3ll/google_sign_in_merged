import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import 'home_page.dart';
import 'sign_in_page.dart';

/// Picks the page from the session stream; no navigation calls needed.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => switch (state.status) {
        EAuthStatus.unknown => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        EAuthStatus.authenticated => const HomePage(),
        EAuthStatus.unauthenticated ||
        EAuthStatus.failure => const SignInPage(),
      },
    );
  }
}
