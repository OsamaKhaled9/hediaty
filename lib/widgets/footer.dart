import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hediaty/screens/event_list_page.dart';
import 'package:hediaty/screens/gift_list_page.dart';
import 'package:hediaty/utils/constants.dart';

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
      // Add sound effect here
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF2A6BFF);
    final backgroundColor = Color(0xFFADD8E6);
    final textColor = Color(0xFF333333);

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
              Navigator.pushNamed(context, '/events');
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
              Navigator.pushNamed(context, '/gifts');
            },
            child: AnimatedBuilder(
              animation: _buttonScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonScaleAnimation.value,
                  child: Icon(FontAwesomeIcons.gift),
                );
              },
            ),
          ),
          label: 'Gifts',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () {
              _playButtonAnimation();
              Navigator.pushNamed(context, '/profile');
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