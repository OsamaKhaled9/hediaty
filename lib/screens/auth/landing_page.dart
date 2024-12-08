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
      backgroundColor: const Color(0xFFF1F1F1), // Soft off-white background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // App Logo with more professional styling
                Image.asset(
                  'assets/images/logo.png',
                  width: 180, // Slightly bigger logo for prominence
                  height: 180,
                ),
                const SizedBox(height: 30),

                // App Title with elegant typography
                const Text(
                  'Hedieaty',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A2D3D), // Dark gray color
                    letterSpacing: 2, // Subtle spacing for professionalism
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle with a professional touch
                const Text(
                  'Manage your gift lists effortlessly.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF7D7D7D), // Light gray
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // Sign Up Button (Primary Action)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A6BFF), // Professional blue
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                    shadowColor: Colors.black.withOpacity(0.2), // Shadow for depth
                  ),
                  child: Text('Sign Up'),
                ),
                const SizedBox(height: 20),

                // Login Prompt Text with Login Button
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
                        Navigator.pushReplacementNamed(context, '/login'); // Corrected navigation
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A6BFF), // Same blue as the primary button
                          borderRadius: BorderRadius.circular(25), // Rounded corners
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
