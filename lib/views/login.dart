import 'package:flutter/material.dart';
import '../controllers/signup_controller.dart'; // Reusing the controllers

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
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/bg5.jpeg',
          //      fit: BoxFit.cover,
          //   ),
          // ),
          // Login Form Container
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
          validator: (value) => validateField(value, labelText),
        ),
      ],
    );
  }

  // Build "Login" button
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            print('Login successful!');
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
