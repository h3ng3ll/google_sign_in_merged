import 'package:flutter/material.dart';

class MissingConfigPage extends StatelessWidget {
  const MissingConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'GOOGLE_SERVER_CLIENT_ID is not set.\n\n'
            'Run with:\n'
            'flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<web client id>',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
