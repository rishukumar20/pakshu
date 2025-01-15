import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskScreen extends StatefulWidget {
  final QueryDocumentSnapshot timesheet;
  final String userEmail;

  const TaskScreen({
    Key? key,
    required this.timesheet,
    required this.userEmail,
  }) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late List<Map<String, dynamic>> _timesheetData;

  @override
  void initState() {
    super.initState();
    _timesheetData = List<Map<String, dynamic>>.from(
      (widget.timesheet['data'] as List).map((item) => Map<String, dynamic>.from(item)),
    );
  }

  // Helper method to convert hour to time slot
  String _convertToTimeSlot(int hour) {
    if (hour < 0 || hour > 24) return 'Invalid Time';
    
    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour > 12 ? hour - 12 : hour;
    displayHour = displayHour == 0 ? 12 : displayHour;
    
    return '$displayHour:00 $period';
  }

  void _showEditDialog(int index) {
    var hourData = _timesheetData[index];
    
    // Controllers for text and points
    TextEditingController taskController = TextEditingController(
      text: hourData['task'] ?? '',
    );
                          
    // Points dropdown values
    List<int> pointOptions = [2, 3, 4, -1, -2];
    
    // Ensure the current points value is in the list, otherwise default to 2
    int selectedPoints = pointOptions.contains(hourData['points']) 
        ? hourData['points'] 
        : 2;
    
    bool isTracked = hourData['tracked'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit ${_convertToTimeSlot(hourData['hour'])} Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Task TextField
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  hintText: 'Enter task details',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Points Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Points'),
                  DropdownButton<int>(
                    value: selectedPoints,
                    items: pointOptions.map((points) {
                      return DropdownMenuItem<int>(
                        value: points,
                        child: Text(points.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedPoints = value;
                        });
                      }
                    },
                  ),
                ],
              ),

              // Tracked Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tracked'),
                  Switch(
                    value: isTracked,
                    onChanged: (value) {
                      setState(() {
                        isTracked = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                // Update local data
                setState(() {
                  _timesheetData[index]['task'] = taskController.text;
                  _timesheetData[index]['points'] = selectedPoints;
                  _timesheetData[index]['tracked'] = isTracked;
                });
                
                try {
                  // Directly update Firestore
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(widget.userEmail)
                      .collection('timesheets')
                      .doc(widget.timesheet.id)
                      .update({
                    'data': _timesheetData,
                  });

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task updated successfully')),
                  );
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating task: $e')),
                  );
                }
                
                // Close dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timesheet Details'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: _timesheetData.length,
        itemBuilder: (context, index) {
          var hourData = _timesheetData[index];
          
          // Convert hour to time format
          String timeSlot = _convertToTimeSlot(hourData['hour']);

          return GestureDetector(
            onTap: () => _showEditDialog(index),
            child: Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8),
              color: hourData['tracked'] ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Slot
                    Text(
                      timeSlot,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    // Task
                    Text(
                      hourData['task'] ?? 'No task',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),

                    SizedBox(height: 8),

                    // Points (aligned to right)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Points: ${hourData['points'] ?? 0}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
