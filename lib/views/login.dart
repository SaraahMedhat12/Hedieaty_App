import 'package:flutter/material.dart';
import '../controllers/signup_controller.dart'; // Reusing the controllers
import '../views/homepage.dart';
import '../database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final SignupControllers _signupControllers = SignupControllers(); // Initialize the controllers for email and password

  @override
  void dispose() {
    _signupControllers.dispose(); // Dispose controllers when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hedieaty - Login'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background Image
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border.all(color: Colors.brown, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      _buildLabelAndTextField(
                        labelText: 'Email',
                        controller: _signupControllers.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      _buildLabelAndTextField(
                        labelText: 'Password',
                        controller: _signupControllers.passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                      SizedBox(height: 32),
                      _buildLoginButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build input fields
  Widget _buildLabelAndTextField({
    required String labelText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.brown),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.brown, width: 2),
            ),
          ),
          validator: (value) =>
              _signupControllers.validateField(value, labelText),
        ),
      ],
    );
  }

  // Build "Login" button
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final email = _signupControllers.emailController.text.trim();
            final password = _signupControllers.passwordController.text.trim();

            // Authenticate user
            bool isAuthenticated = await _signupControllers.authenticateUser(email, password);

            if (isAuthenticated) {
              // Fetch the user by email to get user details
              var user = await _signupControllers.getUserByEmail(email);

              if (user != null) {
                int userId = user['id']; // Get the userId from the returned user data

                // Store userId in SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setInt('userId', userId);

                print('Login successful! User ID: $userId');

                // Navigate to the home page or the next screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              } else {
                print('User not found');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User not found.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              // Handle authentication failure
              print('Authentication failed');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Login failed: Invalid email or password.'),
                  backgroundColor: Colors.brown,
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          'Log In',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
