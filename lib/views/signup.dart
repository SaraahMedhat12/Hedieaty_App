import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login.dart';
import '../controllers/signup_controller.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final SignupControllers _signupControllers = SignupControllers();


  @override
  void dispose() {
    _signupControllers.dispose();
    super.dispose();
  }










  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade700, Colors.brown.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section
                    Column(
                      children: [
                        Icon(
                          Icons.lock_open,
                          size: 80,
                          color: Colors.white,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Welcome to Hedieaty App!',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please create an account to continue.',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Signup Form in a Card
                    Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                              _buildLoginLink(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
            filled: true,
            fillColor: Colors.brown[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.brown),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.brown, width: 2),
            ),
          ),
          validator: (value) => _signupControllers.validateField(value, labelText),
        ),
      ],
    );
  }

  // Build "Create Account" button
  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            print('Form is valid!');

            try {
              // Check if the email is already registered
              bool isRegistered = await _signupControllers.isEmailRegistered(
                _signupControllers.emailController.text.trim(),
              );

              if (isRegistered) {
                // Show error message if email is already registered
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: Email already exists.'),
                    backgroundColor: Colors.brown,
                  ),
                );
                return; // Exit the function without creating the user
              }

              // Use the controller's createUser method to insert user
              bool success = await _signupControllers.createUser();
              if (success) {
                print('User created successfully');

                // Fetch and print the list of users from the database
                List<Map<String, dynamic>> users = await _signupControllers.fetchAllUsers();
                print('Users in database: $users'); // Print users to the console

                // Navigate to Login page after successful signup
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } else {
                throw Exception('Error creating account');
              }
            } catch (e) {
              print('Error: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: Unable to create account.'),
                  backgroundColor: Colors.brown,
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          'Sign Up',
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      ),
    );
  }

  // Build link to navigate to Login Page
  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      child: Text(
        'Already have an account? Log in',
        style: TextStyle(
          color: Colors.brown,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationColor: Colors.brown,
          decorationThickness: 2.0,
          fontSize: 16.0,
        ),
      ),
    );
  }
}
