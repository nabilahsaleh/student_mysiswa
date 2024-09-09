import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_mysiswa/components/my_button.dart';
import 'package:student_mysiswa/components/my_textfield.dart';
import 'package:student_mysiswa/helper/helper_functions.dart';
import 'package:student_mysiswa/pages/home_page.dart';
import 'package:student_mysiswa/pages/admin_page.dart'; 

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Method for password reset
  void resetPassword() async {
    if (emailController.text.isEmpty) {
      // Display a message if the email field is empty
      displayMessageToUser("Please enter your email", context);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      displayMessageToUser("Password reset link sent to your email", context);
    } on FirebaseAuthException catch (e) {
      displayMessageToUser(e.message ?? "An error occurred", context);
    }
  }

  void login() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Log in user
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Get user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).get();
      String role = userDoc.get('role');

      // Pop loading circle
      if (mounted) Navigator.pop(context);

      // Navigate based on role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()), // Admin page
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()), // Student page
        );
      }
    } on FirebaseAuthException catch (e) {
      // Pop loading circle
      if (mounted) Navigator.pop(context);
      // Show error message
      displayMessageToUser(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9BBFDD),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Image.asset(
                'assets/logo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'SiswaCard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              MyTextfield(
                hintText: 'Email',
                obscureText: false,
                controller: emailController,
                icon: Icons.email,
              ),
              const SizedBox(height: 10),
              MyTextfield(
                hintText: 'Password',
                obscureText: true,
                controller: passwordController,
                icon: Icons.lock,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: resetPassword, // Trigger password reset
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color.fromARGB(255, 111, 111, 111),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              MyButton(text: 'L O G I N', onTap: login),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      color: Color.fromARGB(255, 111, 111, 111),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      ' Register here',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

