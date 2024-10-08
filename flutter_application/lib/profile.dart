import 'package:flutter/material.dart';
import 'package:flutter_application/login.dart'; // Assuming you have a login screen
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart'; // Assuming you have a dashboard screen

class ProfileScreen extends StatelessWidget {
  final int userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    // Clear session and navigate to login screen
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data (logout)

    // Navigate to login screen and clear all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the dashboard screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(userId: userId),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile avatar
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://www.example.com/profile_picture.png', // Placeholder image URL
                  ),
                  backgroundColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 12),
              // Edit button below the profile avatar
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(80, 40),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.grey[400]!,
                      ),
                    ),
                  ),
                  onPressed: () {
                    // Handle edit action (optional)
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              // Account, Notifications, Language
              _buildOptionRow(Icons.account_circle, 'Account'),
              _buildOptionRow(Icons.notifications, 'Notifications'),
              _buildOptionRow(Icons.language, 'Language'),
              const SizedBox(height: 30),
              // Logout button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for options like Account, Notifications, Language
  Widget _buildOptionRow(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
