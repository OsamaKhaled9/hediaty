import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hediaty/screens/auth/signup_page.dart';
import 'firebase_options.dart';
import 'package:hediaty/screens/loading_page.dart';
import 'package:hediaty/screens/auth/landing_page.dart';
import 'package:hediaty/screens/auth/login_page.dart';
import 'package:hediaty/screens/home_page.dart';
import 'package:hediaty/screens/event_list_page.dart'; // Add these imports
import 'package:hediaty/screens/gift_list_page.dart';
import 'package:hediaty/screens/profile_page.dart';
import 'package:hediaty/screens/create_event_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';  // Import FFI version of sqflite


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hediaty',
      theme: ThemeData(
        primaryColor: const Color(0xFF2A6BFF), // Apply primary color
        scaffoldBackgroundColor: const Color(0xFFF1F1F1),
      ),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => const LoadingPage(),
        '/landing': (context) => const LandingPage(),
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => const HomePage(),
        '/create_event_list': (context) => const CreateEventPage(),
        '/profile': (context) => ProfilePage(),
        '/event_list': (context) => EventListPage(),
        '/gift_list': (context) => GiftListPage(eventId: 1), // Use dynamic data
      },
    );
  }
}
