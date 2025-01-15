import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TaskScreen extends StatefulWidget {
  final QueryDocumentSnapshot timesheet;
  final String userEmail;

  const TaskScreen({
    super.key, 
    required this.timesheet, 
    required this.userEmail
  });

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late List<Map<String, dynamic>> _timesheetData;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the timesheet data
    _timesheetData = List<Map<String, dynamic>>.from(
      (widget.timesheet['data'] as List).map((item) => Map<String, dynamic>.from(item))
    );
  }

  void _updateTask(int index, String field, dynamic value) {
    setState(() {
      _timesheetData[index][field] = value;
    });
  }

  void _saveChanges() async {
    try {
      await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userEmail)
        .collection('timesheets')
        .doc(widget.timesheet.id)
        .update({
          'data': _timesheetData
        });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timesheet updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating timesheet: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timesheet Details: ${widget.timesheet.id}'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _timesheetData.length,
        itemBuilder: (context, index) {
          var hourData = _timesheetData[index];
          return ExpansionTile(
            title: Text('Hour ${hourData['hour']}'),
            children: [
              // Task Input
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Task',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: hourData['task']),
                  onChanged: (value) => _updateTask(index, 'task', value),
                ),
              ),
              
              // Efficiency Slider
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Efficiency: ${hourData['efficiency'].toInt()}%'),
                    Expanded(
                      child: Slider(
                        value: (hourData['efficiency'] as num).toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 10,
                        label: '${hourData['efficiency'].toInt()}%',
                        onChanged: (value) => _updateTask(index, 'efficiency', value),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tracked Toggle
              SwitchListTile(
                title: Text('Tracked'),
                value: hourData['tracked'],
                onChanged: (value) => _updateTask(index, 'tracked', value),
              ),
            ],
          );
        },
      ),
    );
  }
}
