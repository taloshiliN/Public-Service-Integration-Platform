import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IncomeTaxRegistrationScreen extends StatefulWidget {
  final int userId; // Add userId to the screen

  IncomeTaxRegistrationScreen({required this.userId}); // Modify the constructor

  @override
  _IncomeTaxRegistrationScreenState createState() =>
      _IncomeTaxRegistrationScreenState();
}

class _IncomeTaxRegistrationScreenState
    extends State<IncomeTaxRegistrationScreen> {
  String? employmentStatus;
  String? natureOfEmployment;

  final List<String> employmentStatusOptions = [
    'Employed',
    'Self Employed',
    'Unemployed'
  ];
  final List<String> natureOfEmploymentOptions = [
    'Part-time',
    'Full-time',
    'Remote'
  ];

  // Form field controllers
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _dobController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _genderController = TextEditingController();
  final _postalAddressController = TextEditingController();
  final _employersNameController = TextEditingController();
  final _employersPhysicalAddressController = TextEditingController();
  final _employersPostalAddressController = TextEditingController();
  final _employersContactNumberController = TextEditingController();

  // Variable to store registration status
  String? registrationStatus;
  bool isLoading = false; // To manage loading state

  @override
  void dispose() {
    // Dispose the controllers to avoid memory leaks
    _firstNameController.dispose();
    _surnameController.dispose();
    _dobController.dispose();
    _idNumberController.dispose();
    _genderController.dispose();
    _postalAddressController.dispose();
    _employersNameController.dispose();
    _employersPhysicalAddressController.dispose();
    _employersPostalAddressController.dispose();
    _employersContactNumberController.dispose();
    super.dispose();
  }

  Future<void> submitIncomeTaxRegistration() async {
    // Use the passed userId from the widget
    int userId = widget.userId;

    setState(() {
      isLoading = true;
    });

    // Prepare the data in JSON format
    var requestBody = json.encode({
      'userId': userId,
      'firstName': _firstNameController.text,
      'surname': _surnameController.text,
      'dob': _dobController.text,
      'idNumber': _idNumberController.text,
      'gender': _genderController.text,
      'address': {
        'streetName': _postalAddressController.text,
        'poBox': 56789, // Adjust as needed
        'city': 'Windhoek' // Adjust as needed
      },
      'employmentStatus': employmentStatus,
      'natureOfEmployment': natureOfEmployment,
      'employersName': _employersNameController.text,
      'employersPhysicalAddress': _employersPhysicalAddressController.text,
      'employersPostalAddress': _employersPostalAddressController.text,
      'employersContactNumber': _employersContactNumberController.text,
      'bankConfirmationLetter': 'Placeholder'
    });

    try {
      // Send the POST request to the server
      var response = await http.post(
        Uri.parse('http://192.168.0.140:8080/applyForTax'),
        headers: {
          "Content-Type": "application/json", // Set Content-Type explicitly
        },
        body: utf8.encode(requestBody), // Proper UTF-8 encoding
      );

      // Check the server response
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          print('Registration submitted successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration submitted successfully')),
          );
          // Fetch and display the registration status
          await _checkRegistrationStatus(userId);
        } else if (responseBody['status'] == 'exists') {
          print('User already registered');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User already registered')),
          );
          // Fetch and display the registration status
          await _checkRegistrationStatus(userId);
        } else {
          print('Error: ${responseBody['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseBody['message']}')),
          );
        }
      } else {
        print(
            'Failed to submit registration. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit registration')),
        );
      }
    } catch (e) {
      print('Error submitting registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting registration: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkRegistrationStatus(int userId) async {
    try {
      // Send a GET request to retrieve the registration status
      var response = await http.get(
        Uri.parse('http://192.168.0.140:8080/checkTaxRegistration/$userId'),
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        if (responseBody['status'] == 'exists') {
          setState(() {
            registrationStatus = responseBody['registrationStatus'];
          });
        } else {
          setState(() {
            registrationStatus = null;
          });
        }
      } else {
        print(
            'Failed to retrieve registration status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error retrieving registration status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Tax Registration'),
        backgroundColor: Colors.blue[700],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AbsorbPointer(
              absorbing: isLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildTextField(_firstNameController, 'First Name'),
                  _buildTextField(_surnameController, 'Surname'),
                  _buildTextField(_dobController, 'D.O.B'),
                  _buildTextField(_idNumberController, 'ID Number'),
                  _buildTextField(_genderController, 'Gender'),
                  _buildTextField(_postalAddressController, 'Postal Address'),
                  const SizedBox(height: 20),
                  const Text('Employment Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Employment Status'),
                    value: employmentStatus,
                    items: employmentStatusOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        employmentStatus = newValue;
                        if (newValue == 'Unemployed') {
                          natureOfEmployment = null;
                        }
                      });
                    },
                  ),
                  if (employmentStatus != 'Unemployed') ...[
                    _buildTextField(
                        _employersNameController, 'Employer\'s Name'),
                    _buildTextField(_employersPhysicalAddressController,
                        'Employer\'s Physical Address'),
                    _buildTextField(_employersPostalAddressController,
                        'Employer\'s Postal Address'),
                    _buildTextField(_employersContactNumberController,
                        'Employer\'s Contact Number'),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'Nature of Employment'),
                      value: natureOfEmployment,
                      items: natureOfEmploymentOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          natureOfEmployment = newValue;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      child: isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Submit'),
                      onPressed: isLoading
                          ? null
                          : () {
                              // Call the function to submit the form data to the server
                              if (_validateForm()) {
                                submitIncomeTaxRegistration();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please fill all required fields')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Registration Status Banner
          if (registrationStatus != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      registrationStatus == "Pending"
                          ? Icons.hourglass_empty
                          : Icons.check_circle,
                      color: registrationStatus == "Pending"
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Registration Status: $registrationStatus',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _validateForm() {
    return _firstNameController.text.isNotEmpty &&
        _surnameController.text.isNotEmpty &&
        _dobController.text.isNotEmpty &&
        _idNumberController.text.isNotEmpty &&
        _genderController.text.isNotEmpty &&
        _postalAddressController.text.isNotEmpty &&
        employmentStatus != null;
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
}
