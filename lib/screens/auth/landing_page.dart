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

  void _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;
    await Future.delayed(const Duration(seconds: 1));
    if (isFirstTimeUser) {
      prefs.setBool('isFirstTimeUser', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Opacity
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay to control background opacity and add gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // App Title with Enhanced Typography
                  const Text(
                    'Hedieaty',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New Slogan with Refined Styling
                  const Text(
                    'A world of gifts, at your fingertips.',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Sign Up Button with Glass Effect
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2A6BFF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A6BFF),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: Colors.white,  // Changed to white
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Compact Login Option with Container
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Color.fromRGBO(0, 0, 0, 0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: Color(0xFF2A6BFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}