import 'package:flutter/material.dart';
import 'package:flutter_application/incometaxregistration.dart';

class TaxServicesScreen extends StatelessWidget {
  final int userId;

  const TaxServicesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Filing'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tax Filing',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // Active button for Income Tax Registration
                _buildButton(
                  context,
                  'Income Tax Registration',
                  Icons.person,
                  Colors.blue[700]!,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IncomeTaxRegistrationScreen(
                          userId:
                              userId, // Pass the userId to the registration screen
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Greyed out button for Filing Annual Tax Returns
                _buildDisabledButton(
                  context,
                  'Filing Annual Tax Returns',
                  Icons.person,
                  Colors.grey,
                ),
                const SizedBox(height: 16),
                // Greyed out button for Tax Returns Status
                _buildDisabledButton(
                  context,
                  'Tax Returns Status',
                  Icons.query_stats,
                  Colors.grey,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Active button
  Widget _buildButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Disabled button
  Widget _buildDisabledButton(
      BuildContext context, String title, IconData icon, Color color) {
    return ElevatedButton(
      onPressed: null, // Disable the button
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.grey,
        backgroundColor: Colors.grey[300], // Greyed out background
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0, // Remove elevation for disabled buttons
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]), // Greyed out icon
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
