import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import './task_screen.dart';

class TimeTrackerScreen extends StatefulWidget {
  const TimeTrackerScreen({super.key});

  @override
  _TimeTrackerScreenState createState() => _TimeTrackerScreenState();
}

class _TimeTrackerScreenState extends State<TimeTrackerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dynamically replace the userEmail with your logic (e.g., Firebase Auth)
  final String userEmail = 'rishu970820@gmail.com';

  void _createTimeSheet() async {
    // Get current date as document ID
    String documentId = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Create initial 24-hour timesheet data
    List<Map<String, dynamic>> timeSheetData = List.generate(24, (index) {
      return {
        'task': '',
        'efficiency': 0,
        'tracked': false,
        'hour': index,
      };
    });

    try {
      // Create document in Firestore using the specified collection structure
      await _firestore
          .collection('Users')
          .doc(userEmail)
          .collection('timesheets')
          .doc(documentId)
          .set({
        'data': timeSheetData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timesheet created for $documentId')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating timesheet: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createTimeSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Your Timesheets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Users')
                  .doc(userEmail)
                  .collection('timesheets')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No timesheets yet. Create one!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var timesheet = snapshot.data!.docs[index];
                    return _TimesheetCard(timesheet: timesheet);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimesheetCard extends StatelessWidget {
  final QueryDocumentSnapshot timesheet;
  final String userEmail = 'rishu970820@gmail.com';

  const _TimesheetCard({
    super.key,
    required this.timesheet,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data from the timesheet
    List<dynamic> timesheetData = timesheet['data'];

    return Card(
      color: Colors.blue[100],
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with date and stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timesheet.id, // Date
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      'Points: ${_sumPoints(timesheetData)}',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Tracked: ${_countTrackedTasks(timesheetData)}/24',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            // Task row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getFirstNonEmptyTask(timesheetData) ?? 'No tasks',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue[800]),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskScreen(
                          timesheet: timesheet,
                          userEmail: userEmail,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to calculate average efficiency
  int _sumPoints(List<dynamic> timesheetData) {
  if (timesheetData.isEmpty) return 0;

  // Sum all points, treating null points as 0
  int totalPoints = timesheetData
      .map((task) => (task['points'] ?? 0) as int)
      .reduce((a, b) => a + b);

  return totalPoints;
}

  // Helper method to count tracked tasks
  int _countTrackedTasks(List<dynamic> timesheetData) {
    return timesheetData.where((task) => task['tracked'] == true).length;
  }

  // Helper method to get the first non-empty task
  String? _getFirstNonEmptyTask(List<dynamic> timesheetData) {
    var nonEmptyTasks = timesheetData.where((task) =>
    task['task'] != null && task['task'].toString().isNotEmpty);

    return nonEmptyTasks.isNotEmpty ? nonEmptyTasks.first['task'] : null;
  }
}
