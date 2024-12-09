import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hediaty/db/db_init.dart';
import 'package:hediaty/db/database_helper.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    // Initialize database when the screen loads
    DBInit.setupDB();
  }

  Future<void> _signup() async {
    try {
      // Firebase Authentication logic
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _passwordController.text);

      // Store user data in SQLite locally
      Map<String, dynamic> row = {
        'name': _nameController.text,
        'email': _emailController.text
      };
      await DatabaseHelper.instance.insert(row);

      // Navigate to login page
      Navigator.pushReplacementNamed(context, '/login');
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
        //onPressed: () => Navigator.of(context).pop(),
          onPressed: () => Navigator.pushReplacementNamed(context, '/landing'),

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
            'Create Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A2D3D),
            ),
          ),
          SizedBox(height: 30),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person, color: Color(0xFF2A6BFF)),
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
            onPressed: _signup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2A6BFF),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Sign Up',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 16),
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    ),
  );
}
}
