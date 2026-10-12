import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _onSignOut(BuildContext context) =>
      context.read<AuthBloc>().add(const AuthSignOutPressed());

  @override
  Widget build(BuildContext context) {
    final idToken = context.select(
      (AuthBloc bloc) => bloc.state.session?.idToken,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signed in'),
        actions: [
          TextButton(
            onPressed: () => _onSignOut(context),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: [
            Text(
              'Google ID token',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            // Shortened on purpose: never show or log a full token.
            SelectableText(_preview(idToken)),
          ],
        ),
      ),
    );
  }

  static String _preview(String? token) {
    const visibleChars = 24;
    if (token == null) return '-';
    if (token.length <= visibleChars) return token;
    return '${token.substring(0, visibleChars)}… (${token.length} chars)';
  }
}
