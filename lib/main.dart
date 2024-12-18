import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firebase Config
import 'firebase_options.dart';

// Controllers
import 'package:hediaty/controllers/home_controller.dart';
import 'package:hediaty/controllers/user_controller.dart';
import 'package:hediaty/controllers/event_controller.dart';
import 'package:hediaty/controllers/gift_controller.dart';

// Models
import 'package:hediaty/core/models/gift.dart';

// Pages
import 'package:hediaty/screens/loading_page.dart';
import 'package:hediaty/screens/auth/landing_page.dart';
import 'package:hediaty/screens/auth/signup_page.dart';
import 'package:hediaty/screens/auth/login_page.dart';
import 'package:hediaty/screens/home_page.dart';
import 'package:hediaty/screens/profile_page.dart';
import 'package:hediaty/screens/edit_profile_details.dart';
import 'package:hediaty/screens/event_list_page.dart';
import 'package:hediaty/screens/event_details_page.dart';
import 'package:hediaty/screens/gift_list_page.dart';
import 'package:hediaty/screens/create_edit_gift_page.dart';
import 'package:hediaty/screens/gift_details_page.dart';
import 'package:hediaty/screens/create_edit_event_page.dart';
import 'package:hediaty/screens/pledged_gifts.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => EventController()),
        ChangeNotifierProvider(create: (_) => GiftController()), // Added GiftController
      ],
      child: MaterialApp(
        title: 'Hediaty',
        theme: ThemeData(
          primaryColor: const Color(0xFF2A6BFF),
          scaffoldBackgroundColor: const Color(0xFFF1F1F1),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/loading',
        routes: {
          '/loading': (context) => const LoadingPage(),
          '/landing': (context) => const LandingPage(),
          '/signup': (context) => SignUpPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/profile': (context) {
            final userId = FirebaseAuth.instance.currentUser?.uid;
            return ProfilePage(userId: userId ?? '');
          },
          '/edit_profile_details': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return EditProfileDetails(currentUser: args?['user']);
          },
          '/event_list': (context) => EventListPage(),
          '/event_details': (context) {
            final String eventId = ModalRoute.of(context)!.settings.arguments as String;
            return EventDetailsPage(eventId: eventId);
          },
          '/gift_list': (context) {
            final String eventId = ModalRoute.of(context)!.settings.arguments as String;
            return GiftListPage(eventId: eventId);
          },
          '/create_edit_gift': (context) {
            final Gift? gift = ModalRoute.of(context)?.settings.arguments as Gift?;
            return CreateEditGiftPage(gift: gift);
          },
          '/gift_details': (context) {
            final String giftId = ModalRoute.of(context)!.settings.arguments as String;
            return GiftDetailsPage(giftId: giftId);
          },
          '/pledged_gifts': (context) => PledgedGiftsPage(),
          '/create_edit_event': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return CreateEditEventPage(event: args?['event']);
          },
        },
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';
import 'package:hediaty/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();
  await viewAllDatabaseContents(databaseService);

  runApp(const MyApp());
}

Future<void> viewAllDatabaseContents(DatabaseService databaseService) async {
  final db = await databaseService.database;

  try {
    print("Users Table:");
    final users = await db.query('users');
    for (var user in users) {
      print(user);
    }

    print("Friends Table:");
    final friends = await db.query('friends');
    for (var friend in friends) {
      print(friend);
    }

    print("Events Table:");
    final events = await db.query('events');
    for (var event in events) {
      print(event);
    }

    print("Gifts Table:");
    final gifts = await db.query('gifts');
    for (var gift in gifts) {
      print(gift);
    }

  } catch (e) {
    print("Error viewing database contents: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('Database Viewer')),
        body: const Center(child: Text('Check the console for database output')),
      ),
    );
  }
}
*/
