import 'package:flutter/material.dart';
import 'package:hediaty/controllers/user_controller.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/widgets/custom_text_field.dart';
import 'package:hediaty/widgets/custom_button.dart';
import 'package:hediaty/widgets/profile_picture_picker.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String _selectedAvatar = 'assets/images/default_avatar.JPG';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _errorMessage = "";
  final UserController _userController = UserController();

  /// Validates the email field.
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates the phone number field.
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length != 11) {
      return 'Phone number must be exactly 11 digits';
    }
    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  /// Validates the password confirmation.
  String? validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Handles the Sign-Up logic.
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final trimmedEmail = _emailController.text.trim(); // Trim any spaces
      setState(() {
        _errorMessage = "";
      });

      user newUser = user(
        id: "",
        fullName: _nameController.text.trim(),
        email: trimmedEmail,
        phoneNumber: _phoneController.text.trim(),
        profilePictureUrl: _selectedAvatar,
        passwordHash: "",
      );

      String? error = await _userController.signUpUser(
        newUser,
        _passwordController.text,
        _phoneController.text,
        _selectedAvatar,
      );

      if (error != null) {
        setState(() {
          _errorMessage = error;
        });
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(
            color: Color(0xFF2A6BFF),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A2D3D)),
          onPressed: () => Navigator.pushReplacementNamed(context, '/landing'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Selection
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (BuildContext context) {
                      return AvatarPicker(
                        onAvatarSelected: (String avatarPath) {
                          setState(() {
                            _selectedAvatar = avatarPath;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2A6BFF), width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(_selectedAvatar),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              CustomTextField(
                controller: _nameController,
                labelText: "Full Name",
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: "Email",
                icon: Icons.email,
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: "Password",
                icon: Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: "Confirm Password",
                icon: Icons.lock,
                obscureText: true,
                validator: validateConfirmPassword,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: "Phone (Optional)",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: validatePhoneNumber,
              ),
              const SizedBox(height: 24),

              // Sign-Up Button
              CustomButton(
                label: "Sign Up",
                onPressed: _signUp,
              ),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              // Login Navigation
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Color(0xFF2A6BFF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
