import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_mysiswa/components/my_button.dart';
import 'package:student_mysiswa/components/my_textfield.dart';
import 'package:student_mysiswa/helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Register method
  void registerUser() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // make sure passwords match
    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      // show error message
      displayMessageToUser('Passwords do not match!', context);
    } else {
      // try creating account
      try {
        // create user
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // create a user document and add to firestore
        createUserDocument(userCredential.user);

        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        // pop the loading circle
        Navigator.pop(context);

        // display error message
        displayMessageToUser(e.code, context);
      }
    }
  }

  // create a user document and collect them in firestore
  Future<void> createUserDocument(User? user) async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': nameController.text,
        'phone_number': phoneNumberController.text,
        'id': idController.text,
        'role': 'student', // Default role or based on some criteria
      });
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
              const SizedBox(height: 10),
              Image.asset(
                'assets/logo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              // App name
              const Text(
                'SiswaCard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              // Name textfield
              MyTextfield(
                hintText: 'Name',
                obscureText: false,
                controller: nameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 10),
              // Phone number textfield
              MyTextfield(
                hintText: 'Phone Number',
                obscureText: false,
                controller: phoneNumberController,
                icon: Icons.phone,
              ),
              const SizedBox(height: 10),
              // ID textfield
              MyTextfield(
                hintText: 'Student ID',
                obscureText: false,
                controller: idController,
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 10),
              // Email textfield
              MyTextfield(
                hintText: 'Email',
                obscureText: false,
                controller: emailController,
                icon: Icons.email,
              ),
              const SizedBox(height: 10),
              // Password textfield
              MyTextfield(
                hintText: 'Password',
                obscureText: true,
                controller: passwordController,
                icon: Icons.lock,
              ),
              const SizedBox(height: 10),
              // Confirm Password textfield
              MyTextfield(
                hintText: 'Confirm Password',
                obscureText: true,
                controller: confirmPasswordController,
                icon: Icons.lock,
              ),
              const SizedBox(height: 25),
              // Register button
              MyButton(text: 'R E G I S T E R', onTap: registerUser),
              const SizedBox(height: 10),
              // Have an account? Login here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Color.fromARGB(255, 111, 111, 111)),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      ' Login here',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
