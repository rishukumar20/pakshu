import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './time_tracker.dart';
import './notification_services.dart';
import './reading.dart';


// Define pages for each tracker





class ExerciseTrackerPage extends StatelessWidget {
  const ExerciseTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise Tracker')),
      body: Center(child: Text('Exercise Tracker Page')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(child: Text('Profile Page')),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  NotificationServices notificationServices = NotificationServices();
  void check() {
    print("checked");
  }
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.getDeviceToken().then((value) {
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              check();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // App name at the top of the page
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Tracker',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            // Grid of products
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Redirect to the corresponding page
                      switch (index) {
                        case 0:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TimeTrackerScreen()),
                          );
                          break;
                        case 1:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReadingScreen()),
                          );
                          break;
                        case 2:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TimeTrackerScreen()),
                          );
                          break;
                        case 3:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExerciseTrackerPage()),
                          );
                          break;
                      }
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        color: _getCardColor(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getCardIcon(index),
                              size: 50,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10),
                            Text(
                              _getProductName(index),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to get the product name based on index
  String _getProductName(int index) {
    switch (index) {
      case 0:
        return 'Time Tracker';
      case 1:
        return 'Reading Tracker';
      case 2:
        return 'Health Tracker';
      case 3:
        return 'Exercise Tracker';
      default:
        return 'Unknown';
    }
  }

  // Method to get the card color based on the index
  Color _getCardColor(int index) {
    switch (index) {
      case 0:
        return Colors.blueAccent;
      case 1:
        return Colors.greenAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }

  // Method to get the icon based on the index
  IconData _getCardIcon(int index) {
    switch (index) {
      case 0:
        return Icons.timer;
      case 1:
        return Icons.book;
      case 2:
        return Icons.health_and_safety;
      case 3:
        return Icons.fitness_center;
      default:
        return Icons.help;
    }
  }
}
