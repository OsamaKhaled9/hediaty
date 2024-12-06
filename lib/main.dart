import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hediaty/screens/auth/signup_page.dart';
import 'firebase_options.dart'; // Import the file that contains Firebase options
import 'package:hediaty/screens/loading_page.dart';
import 'package:hediaty/screens/auth/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase with the options.
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
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/loading', // Make sure to load the first screen
      routes: {
        '/loading': (context) => const LoadingPage(),
        '/landing': (context) => LandingPage(), // Ensure this is correctly defined
        '/signup': (context) =>SignUpPage(),
        // Add any other routes needed here
      },
    );
  }
}
