import 'package:flutter/material.dart';
import 'package:flutter_application/oldagepension.dart';

class SocialServicesScreen extends StatelessWidget {
  final int userId;

  const SocialServicesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Grants'),
        backgroundColor: const Color(0xFF7C77B9), // Updated header color
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
                  'Social Grants',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildListItem(
                  context,
                  'Old Age Pension',
                  Icons.person,
                  Colors.blue[700]!,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              OldAgePensionScreen(userId: userId)),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildComingSoonItem(
                  context,
                  'Disability Pensions',
                  Icons.accessibility,
                ),
                const SizedBox(height: 16),
                _buildComingSoonItem(
                  context,
                  'Child Support',
                  Icons.child_care,
                ),
                const SizedBox(height: 16),
                _buildComingSoonItem(
                  context,
                  'Unemployed Benefits',
                  Icons.group,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
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

  Widget _buildComingSoonItem(
      BuildContext context, String title, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This service is coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.grey, // Fade the text and icon color
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
          const SizedBox(width: 12), // Adjusted spacing
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey, // Faded text color
            ),
          ),
          const SizedBox(width: 8), // Added for consistent spacing
          const Icon(Icons.hourglass_empty, color: Colors.grey),
        ],
      ),
    );
  }
}
