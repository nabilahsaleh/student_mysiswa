import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        // ignore: prefer_const_constructors
        color: Color(0xFF435A7F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all( // Correct property to use
          color: Colors.white,
          width: 3.0, // Increase this value to make the border thicker
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25), // Adjusted padding
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    ),
  );
}

}