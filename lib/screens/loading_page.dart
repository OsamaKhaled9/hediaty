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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2A6BFF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.card_giftcard,
                  size: 80,
                  color: Color(0xFF2A6BFF),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hedieaty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2D3D),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A6BFF)),
            ),
          ],
        ),
      ),
    );
  }
  }
