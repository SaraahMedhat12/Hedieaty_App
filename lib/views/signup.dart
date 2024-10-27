import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/signup_controller.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final SignupControllers _signupControllers = SignupControllers(); // Initialize the controllers

  @override
  void dispose() {
    _signupControllers.dispose(); // Dispose controllers when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hedieaty - Signup'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background Image
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/bg5.jpeg',
          //     fit: BoxFit.cover,
          //   ),
          // ),
          // Signup Form Container
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Slight transparency for readability
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
                        labelText: 'Name',
                        controller: _signupControllers.nameController,
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 16),
                      _buildLabelAndTextField(
                        labelText: 'Phone Number',
                        controller: _signupControllers.phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      SizedBox(height: 16),
                      _buildLabelAndTextField(
                        labelText: 'Email',
                        controller: _signupControllers.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      _buildLabelAndTextField(
                        labelText: 'Birthday (YYYY-MM-DD)',
                        controller: _signupControllers.birthdayController,
                        keyboardType: TextInputType.datetime,
                      ),
                      SizedBox(height: 16),
                      _buildLabelAndTextField(
                        labelText: 'Password',
                        controller: _signupControllers.passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                      SizedBox(height: 32),
                      _buildSignupButton(),
                      SizedBox(height: 20),
                      _buildLoginRedirectButton(), // Button to navigate to LoginPage
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

  // Method to build input fields with labels on top-left
  Widget _buildLabelAndTextField({
    required String labelText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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

  // Build "Create Account" button
  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            print('Form is valid!');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          padding: EdgeInsets.symmetric(vertical: 16.0),
        ),
        child: Text(
          'Create Account',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Build button to navigate to LoginPage
  Widget _buildLoginRedirectButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage
          );
        },
        child: Text(
          'Click here if you already have an account',
          style: TextStyle(decoration: TextDecoration.underline, color: Colors.brown),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SignupPage(),
  ));
}
