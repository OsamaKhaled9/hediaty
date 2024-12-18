import 'package:flutter/material.dart';
import 'package:hediaty/controllers/profile_controller.dart';
import 'package:hediaty/core/models/user.dart';

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

  void _toggleNotification(bool isEnabled, user currentUser) {
    // Update the Firestore data immediately when toggled
    _profileController.updateNotificationSetting(
      currentUser.copyWith(isNotificationsEnabled: isEnabled),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: StreamBuilder<user?>(
        stream: _profileController.getUserProfileStream(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          user? currentUser = snapshot.data;

          if (currentUser == null) {
            return Center(child: Text("No user data available"));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with edit button
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(currentUser.profilePictureUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/edit_profile_details',
                            arguments: {
                              'currentUser': currentUser,
                            },
                          );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                currentUser.fullName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(currentUser.email),
              SwitchListTile(
                title: Text("Enable Notifications"),
                value: currentUser.isNotificationsEnabled,
                onChanged: (value) => _toggleNotification(value, currentUser),
              ),
              // Links to Events and Pledged Gifts
              ListTile(
                leading: Icon(Icons.event),
                title: Text("My Events"),
                onTap: () {
                  Navigator.pushNamed(context, '/event_list');
                },
              ),
              ListTile(
                leading: Icon(Icons.card_giftcard),
                title: Text("Pledged Gifts"),
                onTap: () {
                  Navigator.pushNamed(context, '/pledged_gifts');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
