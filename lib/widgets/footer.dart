import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Footer extends StatefulWidget {
  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _playButtonAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF2A6BFF);

    // Get the current user's ID from Firebase Auth
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      items: [
        BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () {
              _playButtonAnimation();
              Navigator.pushNamed(context, '/home');
            },
            child: AnimatedBuilder(
              animation: _buttonScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonScaleAnimation.value,
                  child: Icon(Icons.home),
                );
              },
            ),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () {
              _playButtonAnimation();
              Navigator.pushNamed(context, '/event_list');
            },
            child: AnimatedBuilder(
              animation: _buttonScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonScaleAnimation.value,
                  child: Icon(FontAwesomeIcons.calendar),
                );
              },
            ),
          ),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () {
              _playButtonAnimation();
              if (userId != null) {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: userId, // Pass the userId as an argument
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: User not logged in."),
                  ),
                );
              }
            },
            child: AnimatedBuilder(
              animation: _buttonScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonScaleAnimation.value,
                  child: Icon(Icons.account_circle),
                );
              },
            ),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
