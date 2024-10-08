import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/dashboard.dart'; // Assuming this is your dashboard screen
import 'package:flutter_application/registration.dart'; // Import the RegistrationScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Color(0xFF2C2E43), // Dark theme color for the app bar
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFF7F7F7), // Light background color
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2E43), // Dark text color
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(_usernameController, 'Username'),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, 'Password',
                      isPassword: true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text('Login'),
                    onPressed: () {
                      if (_usernameController.text.isNotEmpty &&
                          _passwordController.text.isNotEmpty) {
                        _loginUser(context); // Process login
                      } else {
                        _showErrorDialog(context,
                            'Please enter both username and password.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF2C2E43), // Button text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegistrationScreen()),
                      ); // Navigate to the RegistrationScreen when tapped
                    },
                    child: Text(
                      "Don't have an account? Register here",
                      style: TextStyle(
                        color: Color(0xFF2C2E43), // Dark text for the link
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white, // Light background for text fields
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12), // Rounded corners for modern look
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2C2E43)), // Dark border color
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: isPassword,
      keyboardType: TextInputType.text,
    );
  }

  Future<void> _loginUser(BuildContext context) async {
    // Collect the form data
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      // Define the URL for the login endpoint
      final url = Uri.parse('http://192.168.0.140:8080/login');

      // Create the JSON payload
      final body = jsonEncode({
        'username': username,
        'password': password,
      });

      // Send the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Handle response status
      if (response.statusCode == 200) {
        // Parse the JSON response
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          int userId = responseData['userId']; // Capture the userId
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Successfully logged in: ${responseData['message']}')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardScreen(
                      userId: userId, // Pass the userId to the dashboard
                    )),
          ); // Navigate to the dashboard
        } else {
          _showErrorDialog(context, responseData['message'] ?? 'Login failed.');
        }
      } else {
        // Show the response message for invalid credentials
        _showErrorDialog(context, "Invalid credentials. Please try again.");
      }
    } catch (error) {
      // Show a generic error message if something went wrong
      _showErrorDialog(context, 'An error occurred. Please try again later.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
