import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
  }

  // Check if the user is new or returning
  void _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;

    // Simulate loading time (1 second)
    await Future.delayed(const Duration(seconds: 1));

    if (isFirstTimeUser) {
      prefs.setBool('isFirstTimeUser', false); // Set after first launch
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Animated Logo Container
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A6BFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // App Title with Modern Typography
              const Text(
                'Hedieaty',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2A2D3D),
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle with Refined Styling
              const Text(
                'Simplify Your Gift Giving Experience',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF7D7D7D),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Sign Up Button with Enhanced Design
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A6BFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF2A6BFF).withOpacity(0.4),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login Option with Improved Layout
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7D7D7D),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFF2A6BFF),
                        fontSize: 16,
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
