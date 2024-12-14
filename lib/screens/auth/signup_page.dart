import 'package:flutter/material.dart';
import 'package:hediaty/controllers/user_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/widgets/custom_text_field.dart';
import 'package:hediaty/widgets/custom_button.dart';
import 'package:hediaty/widgets/profile_picture_picker.dart';
import 'dart:io';  // For using the File class
import 'package:image_picker/image_picker.dart';  // For picking images

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _profilePicture;

  String _errorMessage = "";
  final UserController _userController = UserController();

  Future<void> _pickProfilePicture() async {
    final ImagePicker _picker = ImagePicker();

    // Show bottom sheet or dialog to choose between gallery and camera
    final ImageSource source = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a profile picture'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text('Camera'),
          ),
        ],
      ),
    ) ?? ImageSource.gallery; // Default to gallery if no selection is made

    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _profilePicture = File(image.path);
      });
    }
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
      profilePictureUrl: "", // Assume profile picture is optional
      passwordHash: "",  // Password hash will be updated later

    );

    String? error = await _userController.signUpUser(newUser, _passwordController.text, _profilePicture);
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
        title: Text("Sign Up"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // Navigate back to the landing page
          },
        ),
      ),      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ProfilePicturePicker(onPickImage: (pickedImage) {
              setState(() {
                _profilePicture = pickedImage;
              });
            }),
            SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              labelText: "Full Name",
              icon: Icons.person,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              labelText: "Email",
              icon: Icons.email,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              labelText: "Password",
              icon: Icons.lock,
              obscureText: true,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: "Confirm Password",
              icon: Icons.lock,
              obscureText: true,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              labelText: "Phone (Optional)",
              icon: Icons.phone,
            ),
            SizedBox(height: 24),
            CustomButton(label: "Sign Up", onPressed: _signUp),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text("Already have an account? Login"),
        ),
          ],
      ),
    ),
    );
  }
}
