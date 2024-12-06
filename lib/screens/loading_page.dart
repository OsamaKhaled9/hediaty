import 'package:flutter/material.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart'; // For loading spinner
import 'package:shared_preferences/shared_preferences.dart'; // To check if the user is logged in

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if user is logged in
  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Simulate loading screen (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/landing');
    } else {
      Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gift Icon with animation
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              width: 80,
              height: 80,
              child: const Icon(
                Icons.card_giftcard, // Gift icon
                size: 80,
                color: Color(0xFF2A6BFF), // Same blue color for consistency
              ),
            ),
            const SizedBox(height: 20),
            // Loading text below the icon
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF7D7D7D),
              ),
            ),
          ],
        ),
      ),
    );
  }
  }
