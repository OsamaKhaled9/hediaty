import 'package:flutter/material.dart';
import 'package:hediaty/controllers/user_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/widgets/custom_text_field.dart';
import 'package:hediaty/widgets/custom_button.dart';
import 'package:hediaty/widgets/profile_picture_picker.dart';
import 'dart:io';  // For using the File class
import 'package:image_picker/image_picker.dart';  // For picking images

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String _selectedAvatar = 'assets/images/default_avatar.JPG'; // Default avatar

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  String _errorMessage = "";
  final UserController _userController = UserController();

  // This function is called when an avatar is selected
  void _onAvatarSelected(String avatarPath) {
    setState(() {
      _selectedAvatar = avatarPath;  // Update selected avatar path
    });
  }
  String? validatePhoneNumber(String? value)  {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 11) {
      return 'Phone number must be exactly 11 digits';
    }
    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please fill all the required fields.";
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match.";
      });
      return;
    }

    // Rename 'user' to 'newUser'
    user newUser = user(
      id: "",
      fullName: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,  // Assume phone number is optional
      profilePictureUrl: _selectedAvatar, // Profile picture now comes from the selected avatar
      passwordHash: "",  // Password hash will be updated later
    );

    String? error = await _userController.signUpUser(newUser, _passwordController.text,_phoneController.text, _selectedAvatar);
    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Sign Up"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);  // Navigate back to the landing page
        },
      ),
    ),
    body: SingleChildScrollView(  // Wrap the Column with SingleChildScrollView
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Open the avatar selection menu immediately
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return AvatarPicker(
                    onAvatarSelected: (String avatarPath) {
                      // Set the selected avatar immediately when chosen
                      setState(() {
                        _selectedAvatar = avatarPath;
                      });
                      Navigator.pop(context); // Close the bottom sheet after selection
                    },
                  );
                },
              );
            },
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(_selectedAvatar),  // Show selected avatar
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _nameController,  // Add controller for full name
            labelText: "Full Name",
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            labelText: "Email",
            icon: Icons.email,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            labelText: "Password",
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: "Confirm Password",
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            labelText: "Phone (Optional)",
            icon: Icons.phone,
          ),
          const SizedBox(height: 24),
          CustomButton(label: "Sign Up", onPressed: _signUp),
          if (_errorMessage.isNotEmpty)
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text("Already have an account? Login"),
          ),
        ],
      ),
    ),
  );
}

}