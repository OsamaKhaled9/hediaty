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
import 'package:hediaty/core/models/user.dart';


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
            final Map<String, dynamic> arguments =
                ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

            final user currentUser = arguments['currentUser'] as user;

            return EditProfileDetails(currentUser: currentUser);
          },
          '/event_list': (context) => EventListPage(),
          '/event_details': (context) {
            final Map<String, dynamic> arguments =
                ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

            final String currentUserId = arguments['currentUserId'] as String;
            final String eventId = arguments['eventId'] as String;

            return EventDetailsPage(
              currentUserId: currentUserId,
              eventId: eventId,
            );
          },
          '/gift_list': (context) {
            final String eventId = ModalRoute.of(context)!.settings.arguments as String;
            return GiftListPage(eventId: eventId);
          },
          '/create_edit_gift': (context) {
  final args = ModalRoute.of(context)?.settings.arguments;

  if (args is Map<String, dynamic>) {
    final Gift? gift = args['gift'] as Gift?;
    final String eventId = args['eventId'] as String;
    return CreateEditGiftPage(gift: gift, eventId: eventId);
  } else if (args is Gift) {
    // If only a Gift object is passed (fallback logic)
    return CreateEditGiftPage(gift: args, eventId: args.eventId);
  } else {
    throw ArgumentError("Invalid arguments passed to /create_edit_gift");
  }
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
}//*/
/*
import 'package:flutter/material.dart';
import 'package:hediaty/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final databaseService = DatabaseService();
  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;

  const MyApp({Key? key, required this.databaseService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DatabaseViewerPage(databaseService: databaseService),
    );
  }
}

class DatabaseViewerPage extends StatelessWidget {
  final DatabaseService databaseService;

  const DatabaseViewerPage({Key? key, required this.databaseService})
      : super(key: key);

  Future<Map<String, List<Map<String, dynamic>>>> _getDatabaseContents() async {
    final db = await databaseService.database;

    return {
      "Users": await db.query('users'),
      "Friends": await db.query('friends'),
      "Events": await db.query('events'),
      "Gifts": await db.query('gifts'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Viewer')),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _getDatabaseContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final databaseContents = snapshot.data ?? {};

          return ListView(
            children: databaseContents.entries.map((entry) {
              return ExpansionTile(
                title: Text('${entry.key} Table'),
                children: entry.value.isEmpty
                    ? [
                        const ListTile(
                          title: Text('No records found'),
                        ),
                      ]
                    : entry.value.map((row) {
                        return ListTile(
                          title: Text(row.toString()),
                        );
                      }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

*/
