import 'package:flutter/material.dart';
/*import 'package:flutter_router/flutter_router.dart'; // For navigation
import 'package:provider/provider.dart';
import 'package:hediaty/core/models/friends.dart';
import 'package:hediaty/screens/home_page.dart';
import 'package:hediaty/screens/event_list_page.dart';
import 'package:hediaty/screens/gift_list_page.dart';
import 'package:hediaty/screens/gift_details_page.dart';
import 'package:hediaty/screens/profile_page.dart';
import 'package:hediaty/screens/create_event_page.dart';*/
import 'package:hediaty/screens/loading_page.dart';
import 'package:hediaty/screens/auth/landing_page.dart';
import 'package:hediaty/screens/auth/signup_page.dart';
import 'package:hediaty/screens/auth/login_page.dart';
import 'package:firebase_core/firebase_core.dart';





void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadingPage(),
        '/landing': (context) => LandingPage(),
        '/signup': (context) => SignupPage(),
        //'/login': (context) => LoginPage(),
      },
    );
  }
}
