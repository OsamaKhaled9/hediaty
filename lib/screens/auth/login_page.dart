import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = "";

  Future<void> _login() async {
    try {
      // Firebase Authentication logic for login
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text);

      // Set isLoggedIn to true in SharedPreferences after successful login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Navigate to the home page after successful login
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF1F1F1),
    appBar: AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF2A2D3D)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A2D3D),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Login to continue',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7D7D7D),
            ),
          ),
          SizedBox(height: 30),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email, color: Color(0xFF2A6BFF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF2A6BFF), width: 2),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock, color: Color(0xFF2A6BFF)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF2A6BFF), width: 2),
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2A6BFF),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Login',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 16),
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          Spacer(),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/signup');
            },
            child: Text(
              'Don\'t have an account? Sign up',
              style: TextStyle(color: Color(0xFF2A6BFF)),
            ),
          ),
        ],
      ),
    ),
  );
}
}
