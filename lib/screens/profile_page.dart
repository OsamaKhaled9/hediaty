import 'package:flutter/material.dart';
import 'package:hediaty/controllers/profile_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileController _profileController;
  user? _currentUser;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    user? fetchedUser = await _profileController.loadUserProfile(widget.userId);
    setState(() {
      _currentUser = fetchedUser;
    });
  }

  void _toggleNotification(bool isEnabled) {
    if (_currentUser != null) {
      setState(() {
        _currentUser = _currentUser!.copyWith(isNotificationsEnabled: isEnabled);
      });
      _profileController.updateNotificationSetting(_currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: _currentUser == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(_currentUser!.profilePictureUrl),
                ),
                SizedBox(height: 16),
                Text(
                  _currentUser!.fullName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(_currentUser!.email),
                SwitchListTile(
                  title: Text("Enable Notifications"),
                  value: _currentUser!.isNotificationsEnabled,
                  onChanged: _toggleNotification,
                ),
              ],
            ),
    );
  }
}
