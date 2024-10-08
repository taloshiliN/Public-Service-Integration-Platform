import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _poBoxController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _firstNameController.dispose();
    _surnameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _streetNameController.dispose();
    _poBoxController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
        backgroundColor: Color(0xFF2C2E43), // Dark theme
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFF7F7F7), // Light background
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2E43), // Dark text for contrast
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_idController, 'ID', isNumber: true),
                    const SizedBox(height: 10),
                    _buildTextField(_firstNameController, 'First Name'),
                    const SizedBox(height: 10),
                    _buildTextField(_surnameController, 'Surname'),
                    const SizedBox(height: 10),
                    _buildTextField(_userNameController, 'Username'),
                    const SizedBox(height: 10),
                    _buildTextField(_emailController, 'Email', isEmail: true),
                    const SizedBox(height: 10),
                    _buildTextField(_passwordController, 'Password',
                        isPassword: true),
                    const SizedBox(height: 10),
                    _buildTextField(_streetNameController, 'Street Name'),
                    const SizedBox(height: 10),
                    _buildTextField(_poBoxController, 'PO Box', isNumber: true),
                    const SizedBox(height: 10),
                    _buildTextField(_cityController, 'City'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      child: const Text('Register'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _registerUser(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF2C2E43), // Text color
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
                        Navigator.pop(context); // Navigate back to login
                      },
                      child: Text(
                        "Already have an account? Login here",
                        style: TextStyle(
                          color: Color(0xFF2C2E43), // Dark text for link
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false,
      bool isEmail = false,
      bool isNumber = false,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white, // White text fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Modern rounded corners
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Color(0xFF2C2E43)), // Dark border when focused
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: isPassword,
      maxLines: maxLines,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isNumber
              ? TextInputType.number
              : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isEmail &&
            !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Future<void> _registerUser(BuildContext context) async {
    final id = int.tryParse(_idController.text) ?? 0;
    final firstName = _firstNameController.text;
    final surname = _surnameController.text;
    final username = _userNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final streetName = _streetNameController.text;
    final poBox = _poBoxController.text;
    final city = _cityController.text;

    if (_formKey.currentState!.validate()) {
      try {
        final url = Uri.parse('http://192.168.0.140:8080/createUser');
        final body = jsonEncode({
          'id': id,
          'firstName': firstName,
          'secondName': surname, // Changed to Surname
          'username': username,
          'email': email,
          'password': password,
          'address': {
            'streetName': streetName,
            'poBox': int.parse(poBox),
            'city': city
          }
        });

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData.containsKey('message')
                    ? 'Successfully registered: ${responseData['message']}'
                    : 'Successfully registered!',
              ),
            ),
          );
          Navigator.pop(context); // Navigate back to login
        } else {
          _showErrorDialog(context, _parseErrorResponse(response));
        }
      } catch (error) {
        _showErrorDialog(context, 'An error occurred. Please try again later.');
      }
    }
  }

  String _parseErrorResponse(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      return responseData['message'] ?? 'Registration failed';
    } catch (e) {
      return 'Registration failed with status code ${response.statusCode}';
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registration Failed'),
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
