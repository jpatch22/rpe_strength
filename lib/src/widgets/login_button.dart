import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/providers/auth_service.dart';

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return ElevatedButton(
      onPressed: () async {
        User? user = await authService.signInWithGoogle();
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign In Successful: ${user.displayName}'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign In Failed'),
            ),
          );
        }
      },
      child: Text('Sign In with Google'),
    );
  }
}
