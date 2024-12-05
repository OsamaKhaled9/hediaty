import 'package:flutter/material.dart';

class Friend {
  final String name;
  final String profilePic;
  final int upcomingEvents;

  Friend({required this.name, required this.profilePic, required this.upcomingEvents});
}

class Friends extends ChangeNotifier {
  final List<Friend> _friends = [
    Friend(name: 'John Doe', profilePic: 'https://via.placeholder.com/150', upcomingEvents: 1),
    Friend(name: 'Jane Smith', profilePic: 'https://via.placeholder.com/150', upcomingEvents: 0),
  ];

  List<Friend> get friends => _friends;

  void addFriend(Friend friend) {
    _friends.add(friend);
    notifyListeners();
  }
}
