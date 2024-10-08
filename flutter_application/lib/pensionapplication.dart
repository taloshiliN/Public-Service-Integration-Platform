import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class PensionApplicationScreen extends StatefulWidget {
  final int userId;

  PensionApplicationScreen({required this.userId});

  @override
  _PensionApplicationScreenState createState() =>
      _PensionApplicationScreenState();
}

class _PensionApplicationScreenState extends State<PensionApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Information controllers
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();

  // Residential Address controllers
  final _streetNameController = TextEditingController();
  final _poBoxController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  // Bank Information controllers
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  // Optional Information controllers
  final _maritalStatusController = TextEditingController();
  final _beneficiaryInfoController = TextEditingController();
  final _pensionFundDetailsController = TextEditingController();

  // File upload variables
  File? _proofOfAddressFile;
  File? _proofOfIncomeFile;
  File? _bankStatementFile;

  bool isLoading = true;
  String? applicationStatus;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user profile when the screen is initialized
    _checkIfApplicationExists(); // Check if an existing application exists
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _surnameController.dispose();
    _nationalIdController.dispose();
    _dobController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _streetNameController.dispose();
    _poBoxController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _maritalStatusController.dispose();
    _beneficiaryInfoController.dispose();
    _pensionFundDetailsController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.140:8080/getProfile?id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['status'] == 'success') {
          final profile = decodedResponse['profile'];
          setState(() {
            _firstNameController.text = profile['firstName'];
            _surnameController.text = profile['secondName'];
            _emailController.text = profile['email'];
            _streetNameController.text = profile['address']['streetName'];
            _poBoxController.text = profile['address']['poBox'].toString();
            _cityController.text = profile['address']['city'];
            _countryController.text = "Namibia";
            _nationalIdController.text = profile['id'].toString();
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkIfApplicationExists() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.0.140:8080/checkApplication/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          applicationStatus = decodedResponse['applicationStatus'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitPensionApplication() async {
    if (_formKey.currentState!.validate()) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.0.140:8080/applyForPension'),
      );

      // Personal Information
      request.fields['formData'] = jsonEncode({
        'userId': widget.userId,
        'firstName': _firstNameController.text,
        'surname': _surnameController.text,
        'nationalId': _nationalIdController.text,
        'dob': _dobController.text,
        'phoneNumber': _phoneNumberController.text,
        'email': _emailController.text,
        'address': {
          'streetName': _streetNameController.text,
          'poBox': _poBoxController.text,
          'city': _cityController.text,
          'country': _countryController.text,
        },
        'bankInfo': {
          'bankName': _bankNameController.text,
          'accountNumber': _accountNumberController.text,
        },
        'maritalStatus': _maritalStatusController.text,
        'beneficiaryInfo': _beneficiaryInfoController.text,
        'pensionFundDetails': _pensionFundDetailsController.text,
      });

      // Attach files
      if (_proofOfAddressFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'proofOfAddress',
            _proofOfAddressFile!.path,
          ),
        );
      }

      if (_proofOfIncomeFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'proofOfIncome',
            _proofOfIncomeFile!.path,
          ),
        );
      }

      if (_bankStatementFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'bankStatement',
            _bankStatementFile!.path,
          ),
        );
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      var response = await request.send();

      Navigator.of(context).pop(); // Remove loading indicator

      if (response.statusCode == 200) {
        // Successfully submitted, now check the application status
        await _checkIfApplicationExists(); // Fetch the updated application status
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application submitted successfully')),
        );
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pension application already exists.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit application')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {bool isNumber = false, bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          fillColor: Colors.white,
          filled: true,
        ),
        keyboardType: isNumber
            ? TextInputType.number
            : isDate
                ? TextInputType.datetime
                : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildFilePicker(String label, Function onPressed, File? file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => onPressed(),
          icon: Icon(Icons.upload_file),
          label: Text('Upload $label'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: Colors.blueAccent,
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        if (file != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.path.split('/').last,
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _pickFile(Function(File?) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );
    if (result != null) {
      onFilePicked(File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pension Application'),
        backgroundColor:
            Color.fromARGB(255, 193, 191, 217), // Updated theme color
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information
                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(_firstNameController, 'First Name',
                      'Enter your first name'),
                  _buildTextField(
                      _surnameController, 'Surname', 'Enter your surname'),
                  _buildTextField(_nationalIdController, 'National ID',
                      'Enter your national ID',
                      isNumber: true),
                  _buildTextField(_dobController, 'Date of Birth', 'YYYY-MM-DD',
                      isDate: true),
                  _buildTextField(_phoneNumberController, 'Phone Number',
                      'Enter your phone number',
                      isNumber: true),
                  _buildTextField(
                      _emailController, 'Email', 'Enter your email address'),
                  const SizedBox(height: 20),

                  // Residential Address
                  const Text(
                    'Residential Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(_streetNameController, 'Street Name',
                      'Enter your street name'),
                  _buildTextField(
                      _poBoxController, 'PO Box', 'Enter your PO Box',
                      isNumber: true),
                  _buildTextField(_cityController, 'City', 'Enter your city'),
                  _buildTextField(
                      _countryController, 'Country', 'Enter your country'),
                  const SizedBox(height: 20),

                  // Proof of Eligibility
                  const Text(
                    'Proof of Eligibility',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFilePicker('Proof of Address', () {
                    _pickFile((file) => setState(() {
                          _proofOfAddressFile = file;
                        }));
                  }, _proofOfAddressFile),
                  _buildFilePicker('Proof of Income', () {
                    _pickFile((file) => setState(() {
                          _proofOfIncomeFile = file;
                        }));
                  }, _proofOfIncomeFile),
                  const SizedBox(height: 20),

                  // Bank Information
                  const Text(
                    'Bank Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                      _bankNameController, 'Bank Name', 'Enter your bank name'),
                  _buildTextField(_accountNumberController, 'Account Number',
                      'Enter your account number',
                      isNumber: true),
                  _buildFilePicker('Bank Statement', () {
                    _pickFile((file) => setState(() {
                          _bankStatementFile = file;
                        }));
                  }, _bankStatementFile),
                  const SizedBox(height: 20),

                  // Additional Information
                  const Text(
                    'Additional Information (Optional)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(_maritalStatusController, 'Marital Status',
                      'Enter your marital status'),
                  _buildTextField(_beneficiaryInfoController,
                      'Beneficiary Info', 'Enter beneficiary information'),
                  _buildTextField(_pensionFundDetailsController,
                      'Pension Fund Details', 'Enter pension fund details'),
                  const SizedBox(height: 20),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _submitPensionApplication,
                      child: const Text(
                        'Submit Application',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Color.fromARGB(
                            255, 202, 202, 220), // Consistent theme color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (applicationStatus != null)
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
                      applicationStatus == "Pending"
                          ? Icons.hourglass_empty
                          : Icons.check_circle,
                      color: applicationStatus == "Pending"
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Application Status: $applicationStatus',
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
}
