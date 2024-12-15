import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/constants.dart';

/*class Footer extends StatelessWidget {
  final String currentRoute;

  Footer({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _getCurrentIndex(),
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/events');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.calendarAlt),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.user),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Color(0x2A6BFF),
      unselectedItemColor: Color(0xF2F2F2),
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  int _getCurrentIndex() {
    switch (currentRoute) {
      case '/home':
        return 0;
      case '/events':
        return 1;
      case '/profile':
        return 2;
      default:
        return 0;
    }
  }
}
*/
class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/profile');
        }
      },
    );
  }
}
