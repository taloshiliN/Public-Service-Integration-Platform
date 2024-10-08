import 'package:flutter/material.dart';
import 'package:flutter_application/idrenewal.dart';

class IDServicesScreen extends StatelessWidget {
  final int userId;

  const IDServicesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Services'),
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
                  'ID Services',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDisabledButton(
                  context,
                  'Issuing ID',
                  Icons.add_card,
                  Colors.grey, // Greyed out to indicate it's disabled
                ),
                const SizedBox(height: 16),
                _buildDisabledButton(
                  context,
                  'Verification of ID',
                  Icons.verified_user,
                  Colors.grey, // Greyed out to indicate it's disabled
                ),
                const SizedBox(height: 16),
                _buildButton(
                  context,
                  'Renewal of ID',
                  Icons.autorenew,
                  Colors.orange[700]!,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IDRenewalScreen(userId: userId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildDisabledButton(
                  context,
                  'Biometric Integration',
                  Icons.fingerprint,
                  Colors.grey, // Greyed out to indicate it's disabled
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  // Function for disabled buttons
  Widget _buildDisabledButton(
      BuildContext context, String title, IconData icon, Color color) {
    return ElevatedButton(
      onPressed: null, // Disable button
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.grey,
        backgroundColor: Colors.grey[300], // Greyed out background
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
}
