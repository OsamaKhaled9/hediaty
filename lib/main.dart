import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart'; // For navigation
import 'package:provider/provider.dart';
import 'package:hediaty/core/models/friends.dart';
import 'package:hediaty/screens/home_page.dart';
import 'package:hediaty/screens/event_list_page.dart';
import 'package:hediaty/screens/gift_list_page.dart';
import 'package:hediaty/screens/gift_details_page.dart';
import 'package:hediaty/screens/profile_page.dart';
import 'package:hediaty/screens/create_event_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Friends(),
      child: MaterialApp(
        title: 'Hedieaty',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),
          '/create_event': (context) => CreateEventPage(),
          '/event_list': (context) => EventListPage(),
          '/gift_list': (context) => GiftListPage(),
          '/gift_details': (context) => GiftDetailsPage(),
          '/profile': (context) => ProfilePage(),
        },
      ),
    );
  }
}
