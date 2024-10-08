import 'package:flutter/material.dart';
import 'package:flutter_application/pensionapplication.dart';

class OldAgePensionScreen extends StatelessWidget {
  final int userId; // Add userId to this screen

  OldAgePensionScreen({required this.userId}); // Modify constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Old Age Pension'),
        backgroundColor: const Color(0xFF7C77B9), // Updated color to fit theme
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF7F7F7), // Light background
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildListItem(
              context,
              'Application for Pension',
              '1',
              Icons.assignment_turned_in,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PensionApplicationScreen(
                        userId: userId)), // Pass userId here
              ),
            ),
            _buildComingSoonItem(
              context,
              'Pension Appeal Services - Coming Soon',
              '2',
              Icons.warning_amber_rounded,
            ),
            _buildComingSoonItem(
              context,
              'Updating Beneficiary Information - Coming Soon',
              '3',
              Icons.update_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, String index,
      IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF7C77B9), // Updated to fit theme
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          subtitle: const Text(
            'Tap for more information',
            style: TextStyle(color: Color(0xFF666666)),
          ),
          trailing:
              const Icon(Icons.arrow_forward_ios, color: Color(0xFF7C77B9)),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildComingSoonItem(
      BuildContext context, String title, String index, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                const Color(0xFFD1D5E1), // Light color to show "Coming Soon"
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF999999), // Grey color for "Coming Soon"
            ),
          ),
          trailing: const Icon(Icons.hourglass_empty, color: Color(0xFF999999)),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("This service is coming soon!"),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
