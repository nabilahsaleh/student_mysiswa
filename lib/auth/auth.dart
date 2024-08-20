import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_mysiswa/auth/login_or_register.dart';
import 'package:student_mysiswa/pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user id logged in
          if (snapshot.hasData) {
            return const HomePage();
          }

          // user is not logged in
          else {
            return const LoginOrRegister();
          }
        },
      )
    );
  }
}