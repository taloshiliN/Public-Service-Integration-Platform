import 'package:flutter/material.dart';
import 'package:flutter_application/idservices.dart';
import 'package:flutter_application/socialservices.dart';
import 'package:flutter_application/taxservices.dart';

import 'profile.dart';

class DashboardScreen extends StatelessWidget {
  final int userId;

  const DashboardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Calculate the number of columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return Scaffold(
      body: Container(
        color: const Color(0xFFF0F2F5),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C77B9), Color(0xFF57A773)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row for notification and profile icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            color: Colors.white,
                            onPressed: () {
                              // Handle notifications
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.account_circle_outlined),
                            color: Colors.white,
                            onPressed: () {
                              // Navigate to the ProfileScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                      userId: userId), // Pass userId
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Text for the title
                      Text(
                        'Government Services',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Welcome to PSIP',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildDashboardItem(
                      context,
                      'Social Grants',
                      Icons.people_outline,
                      const Color(0xFF7C77B9),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SocialServicesScreen(userId: userId),
                        ),
                      ),
                    ),
                    _buildDashboardItem(
                      context,
                      'Tax Filing',
                      Icons.account_balance_outlined,
                      const Color(0xFF57A773),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaxServicesScreen(userId: userId),
                        ),
                      ),
                    ),
                    _buildDashboardItem(
                      context,
                      'ID Services',
                      Icons.badge_outlined,
                      const Color(0xFFEE964B),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              IDServicesScreen(userId: userId),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
