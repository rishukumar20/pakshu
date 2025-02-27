import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WeeklyPlanScreen extends StatefulWidget {
  @override
  _WeeklyPlanScreenState createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  DateTimeRange? _dateRange;
  final List<Map<String, dynamic>> _todos = [];
  final List<Map<String, dynamic>> _completedPlans = [];
  final _firestore = FirebaseFirestore.instance;

  // Save locally using SharedPreferences
  Future<void> _saveLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final weeklyPlan = {
      'dateRange': {
        'start': _dateRange?.start.toIso8601String(),
        'end': _dateRange?.end.toIso8601String(),
      },
      'todos': _todos,
    };
    prefs.setString('weeklyPlan', jsonEncode(weeklyPlan));
  }

  // Save to Firebase
  Future<void> _saveToFirebase() async {
    if (_dateRange != null) {
      final weeklyPlan = {
        'dateRange': {
          'start': _dateRange?.start.toIso8601String(),
          'end': _dateRange?.end.toIso8601String(),
        },
        'todos': _todos,
        'timestamp': Timestamp.now(),
      };
      await _firestore.collection('weeklyPlans').add(weeklyPlan);
    }
  }

  // Load locally saved data
  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('weeklyPlan');
    if (data != null) {
      final decodedData = jsonDecode(data);
      setState(() {
        _dateRange = DateTimeRange(
          start: DateTime.parse(decodedData['dateRange']['start']),
          end: DateTime.parse(decodedData['dateRange']['end']),
        );
        _todos.addAll(List<Map<String, dynamic>>.from(decodedData['todos']));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFromLocal();
  }

  // Add Weekly Target
  void _addWeeklyTarget() {
    final today = DateTime.now();
    final nextWeek = today.add(Duration(days: 6));
    setState(() {
      _dateRange = DateTimeRange(start: today, end: nextWeek);
    });
    _saveLocally();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Weekly Target set: $today to $nextWeek')),
    );
  }

  // Add To-Do Dialog
  void _addTodo() {
    showDialog(
      context: context,
      builder: (ctx) {
        final TextEditingController todoController = TextEditingController();
        return AlertDialog(
          title: Text('Add To-Do'),
          content: TextField(
            controller: todoController,
            decoration: InputDecoration(hintText: 'Enter task'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (todoController.text.isNotEmpty) {
                  setState(() {
                    _todos.add({'task': todoController.text, 'completed': false});
                  });
                  _saveLocally();
                }
                Navigator.of(ctx).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Toggle Task Completion
  void _toggleTodoCompletion(int index) {
    setState(() {
      _todos[index]['completed'] = !_todos[index]['completed'];
      if (_todos.every((todo) => todo['completed'] == true)) {
        _addCompletedPlan();
      }
    });
    _saveLocally();
  }

  // Add Completed Plan
  void _addCompletedPlan() {
    final totalTodos = _todos.length;
    final completedTodos = _todos.where((todo) => todo['completed'] == true).length;
    final ratio = totalTodos > 0 ? (completedTodos / totalTodos) : 0.0;

    setState(() {
      _completedPlans.add({
        'dateRange': _dateRange,
        'totalTodos': totalTodos,
        'completedTodos': completedTodos,
        'ratio': ratio,
      });
      _todos.clear();
      _dateRange = null;
    });

    _saveLocally();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Plan'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await _saveLocally();
              await _saveToFirebase();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Weekly Plan saved successfully!')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Weekly Target Button
            ElevatedButton(
              onPressed: _addWeeklyTarget,
              child: Text('Add Weekly Target'),
            ),
            SizedBox(height: 16),
            // Date Range Picker
            ElevatedButton(
              onPressed: () async {
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (dateRange != null && dateRange.start.weekday == 1 && dateRange.end.weekday == 7) {
                  setState(() {
                    _dateRange = dateRange;
                  });
                  _saveLocally();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a date range from Monday to Sunday')),
                  );
                }
              },
              child: Text(_dateRange == null
                  ? 'Select Date Range'
                  : '${_dateRange!.start.toLocal()} - ${_dateRange!.end.toLocal()}'),
            ),
            SizedBox(height: 16),
            // To-Do List
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (ctx, index) {
                  final todo = _todos[index];
                  return ListTile(
                    title: Text(
                      todo['task'],
                      style: TextStyle(
                        decoration: todo['completed'] ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: Checkbox(
                      value: todo['completed'],
                      onChanged: (_) => _toggleTodoCompletion(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addTodo,
              child: Text('Add To-Do'),
            ),
            SizedBox(height: 16),
            // Completed Weekly Plans
            if (_completedPlans.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _completedPlans.length,
                  itemBuilder: (ctx, index) {
                    final plan = _completedPlans[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          'Week: ${plan['dateRange'].start.toLocal()} - ${plan['dateRange'].end.toLocal()}',
                        ),
                        subtitle: Text(
                          'Todos: ${plan['completedTodos']}/${plan['totalTodos']} '
                          '(Ratio: ${(plan['ratio'] * 100).toStringAsFixed(1)}%)',
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
}
