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
    _profileController.updateNotificationSetting(
      currentUser.copyWith(isNotificationsEnabled: isEnabled),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background color
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF2A6BFF),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF2A6BFF)),
      ),
      body: StreamBuilder<user?>(
        stream: _profileController.getUserProfileStream(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A6BFF)),
            ));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red[700]),
              ),
            );
          }

          user? currentUser = snapshot.data;

          if (currentUser == null) {
            return Center(
              child: Text(
                "No user data available",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFF2A6BFF),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage(currentUser.profilePictureUrl),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit_profile_details',
                                  arguments: {'currentUser': currentUser},
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF2A6BFF),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                    ),
                                  ],
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
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A6BFF),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        currentUser.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          "Enable Notifications",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        value: currentUser.isNotificationsEnabled,
                        onChanged: (value) => _toggleNotification(value, currentUser),
                        activeColor: Color(0xFF2A6BFF),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.event, color: Color(0xFF2A6BFF)),
                        title: Text(
                          "My Events",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Color(0xFF2A6BFF),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/event_list');
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.card_giftcard, color: Color(0xFF2A6BFF)),
                        title: Text(
                          "Pledged Gifts",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Color(0xFF2A6BFF),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/pledged_gifts');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}