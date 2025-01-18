import 'package:flutter/material.dart';
import 'package:pakshu/screens/time_tracker.dart';
import 'package:pakshu/screens/weekly_target.dart';
import 'package:pakshu/screens/monthly_target.dart'; // Add this line


class TimerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timer Homepage'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Hours Records
            _buildRedirectCard(
              context,
              title: "Daily Hours Records",
              description: "View and track your daily hours.",
              icon: Icons.access_time,
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimeTrackerScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            // Weekly Target
            _buildRedirectCard(
              context,
              title: "Weekly Target",
              description: "Set and track your weekly targets.",
              icon: Icons.calendar_today,
              color: Colors.greenAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeeklyPlanScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            // Monthly Target
            _buildRedirectCard(
              context,
              title: "Monthly Target",
              description: "Set and monitor your monthly goals.",
              icon: Icons.calendar_month,
              color: Colors.purpleAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthlyTargetScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedirectCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.2),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}