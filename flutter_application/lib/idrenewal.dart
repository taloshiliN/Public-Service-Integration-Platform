import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IDRenewalScreen extends StatefulWidget {
  final int userId;

  IDRenewalScreen({required this.userId});

  @override
  _IDRenewalScreenState createState() => _IDRenewalScreenState();
}

class _IDRenewalScreenState extends State<IDRenewalScreen> {
  String? selectedRegion;
  String? selectedTown;
  final reasonController = TextEditingController();

  // Variables for status
  String? renewalStatus;
  bool isLoading = false;

  // List of regions and towns
  final List<String> namibiaRegions = [
    'Erongo',
    'Hardap',
    '‖Karas',
    'Kavango East',
    'Kavango West',
    'Khomas',
    'Kunene',
    'Ohangwena',
    'Omaheke',
    'Omusati',
    'Oshana',
    'Oshikoto',
    'Otjozondjupa',
    'Zambezi'
  ];

  final List<String> namibianTowns = [
    'Windhoek',
    'Swakopmund',
    'Walvis Bay',
    'Oshakati',
    'Rundu',
    'Katima Mulilo',
    'Otjiwarongo',
    'Keetmanshoop',
    'Mariental',
    'Gobabis',
    'Grootfontein',
    'Okahandja',
    'Rehoboth',
    'Ondangwa',
    'Omaruru',
    'Outjo',
    'Karibib',
    'Lüderitz',
    'Tsumeb',
    'Henties Bay',
    'Karasburg',
    'Aranos',
    'Outapi',
    'Eenhana',
    'Okakarara',
    'Opuwo',
    'Okahao',
    'Nkurenkuru',
    'Omuthiya',
    'Oranjemund',
    'Ongwediva',
    'Usakos',
    'Ruacana',
    'Divundu',
    'Khorixas',
    'Noordoewer',
    'Okongo',
    'Oshikango',
    'Arandis',
    'Aus',
    'Bethanie',
    'Gibeon',
    'Gochas',
    'Kamanjab',
    'Khomasdal',
    'Maltahöhe',
    'Okamatapati',
    'Okanguati',
    'Omatjete',
    'Omitara',
    'Otavi',
    'Oshikuku',
    'Stampriet',
    'Tses',
    'Witvlei'
  ];

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  // Function to check renewal status from the server
  Future<void> checkRenewalStatus() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'http://192.168.0.140:8080/checkIDRenewalStatus/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        renewalStatus = data['renewalStatus'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve status')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  // Function to submit ID renewal
  Future<void> submitIDRenewal(int userId) async {
    var requestBody = jsonEncode({
      'userId': userId,
      'birthCertificate': 'base64EncodedBirthCertificate',
      'guardianBirthCertificate': 'base64EncodedGuardianBirthCertificate',
      'reasonForRenewal': reasonController.text,
    });

    setState(() {
      isLoading = true;
    });

    try {
      var response = await http.post(
        Uri.parse('http://192.168.0.140:8080/applyForIDRenewal'),
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID Renewal submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // After successful submission, check the renewal status
        checkRenewalStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to submit ID Renewal: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting ID Renewal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Always check the status when the screen is loaded
    checkRenewalStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renewal of ID'),
        backgroundColor: Colors.blue[700],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedRegion,
                  items: namibiaRegions.map((String region) {
                    return DropdownMenuItem<String>(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRegion = newValue;
                      selectedTown = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Town',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedTown,
                  items: namibianTowns.map((String town) {
                    return DropdownMenuItem<String>(
                      value: town,
                      child: Text(town),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTown = newValue;
                    });
                  },
                  hint: const Text('Select a town'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Renewal',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Submit'),
                  onPressed:
                      isLoading ? null : () => submitIDRenewal(widget.userId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
          ),
          if (renewalStatus != null)
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
                      renewalStatus == "Pending"
                          ? Icons.hourglass_empty
                          : Icons.check_circle,
                      color: renewalStatus == "Pending"
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Renewal Status: $renewalStatus',
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
