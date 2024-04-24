import 'package:electech/pages/HomePage.dart';
import 'package:electech/pages/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth extends StatelessWidget {
  const Auth({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
