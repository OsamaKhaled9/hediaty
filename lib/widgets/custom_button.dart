import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A6BFF), // Brandeis Blue
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        shadowColor: Colors.black.withOpacity(0.2),
        elevation: 5,
        textStyle: const TextStyle(
          fontFamily: 'Roboto', // Primary font
          fontWeight: FontWeight.bold,
        ),
        foregroundColor: Colors.white, // Text color
        //shadowColor: Color(0xFFADD8E6), // Light Blue for disabled button
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Roboto', // Primary text font
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
