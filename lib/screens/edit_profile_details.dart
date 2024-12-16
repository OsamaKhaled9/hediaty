import 'package:flutter/material.dart';
import 'package:hediaty/controllers/profile_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/widgets/custom_button.dart';
import 'package:hediaty/widgets/custom_text_field.dart';


class EditProfileDetails extends StatefulWidget {
  final user currentUser;

  const EditProfileDetails({Key? key, required this.currentUser}) : super(key: key);

  @override
  _EditProfileDetailsState createState() => _EditProfileDetailsState();
}

class _EditProfileDetailsState extends State<EditProfileDetails> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController();

    // Initialize controllers with current user data
    _fullNameController = TextEditingController(text: widget.currentUser.fullName);
    _emailController = TextEditingController(text: widget.currentUser.email);
    _phoneController = TextEditingController(text: widget.currentUser.phoneNumber);
  }

  @override
  void dispose() {
    // Dispose controllers
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileDetails() async {
    final updatedUser = widget.currentUser.copyWith(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
    );

    try {
      // Update in Firestore
      await _profileController.updateUserProfile(updatedUser);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );

      // Navigate back
      Navigator.pop(context, updatedUser);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Full Name Field
            CustomTextField(
              controller: _fullNameController,
              labelText: "Full Name",
              icon: Icons.person,
            ),
            SizedBox(height: 16),

            // Email Field
            CustomTextField(
              controller: _emailController,
              labelText: "Email",
              icon: Icons.email,
            ),
            SizedBox(height: 16),

            // Phone Number Field
            CustomTextField(
              controller: _phoneController,
              labelText: "Phone Number",
              icon: Icons.phone,
            ),
            SizedBox(height: 16),

            // Save Button
            CustomButton(
              label: "Save",
              onPressed: _saveProfileDetails,
            ),
          ],
        ),
      ),
    );
  }

}
