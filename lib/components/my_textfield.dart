import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final IconData? icon; // Add icon parameter

  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.icon, // Initialize icon
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon) : null, // Use the icon
        filled: true, // Enable fill color
        fillColor: Color(0x8096B5B6), // Set background color using hex code
      ),
      obscureText: obscureText,
    );
  }
}