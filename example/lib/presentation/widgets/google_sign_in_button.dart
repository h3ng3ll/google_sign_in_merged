import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in_merged/google_sign_in_merged.dart';

import '../bloc/auth_bloc.dart';

/// Web: Google Identity Services draws its own button, and its result reaches
/// the bloc through the token stream. Android/iOS: our button dispatches
/// an intent event.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  void _onPressed(BuildContext context) =>
      context.read<AuthBloc>().add(const AuthGoogleSignInPressed());

  @override
  Widget build(BuildContext context) {
    if (GoogleSignInMerged.usesRenderedButton) {
      return context.read<GoogleSignInMerged>().renderButton();
    }
    return FilledButton(
      onPressed: () => _onPressed(context),
      child: const Text('Continue with Google'),
    );
  }
}
