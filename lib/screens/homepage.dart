import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './time_tracker.dart';
import './notification_services.dart';
import './reading.dart';
import './timer_homepage.dart';

class ExerciseTrackerPage extends StatelessWidget {
  const ExerciseTrackerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise Tracker')),
      body: Center(child: Text('Exercise Tracker Page')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

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
  int _selectedIndex = 0;
  late List<Widget> _pages;

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeGridView(),
      TimerHomePage(),
      ReadingScreen(),
      TimeTrackerScreen(),
      ExerciseTrackerPage(),
    ];

    notificationServices.requestNotificationPermission();
    notificationServices.getDeviceToken().then((value) {
      print(value);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lets track it!'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Time Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Reading',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercise',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}



class HomeGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DatePicker(),
        Expanded(child: HabitList()),
      ],
    );
  }
}

// Global notifier for selected date
ValueNotifier<DateTime> selectedDateNotifier = ValueNotifier(DateTime.now());

class DatePicker extends StatefulWidget {
  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent.shade100,
            Colors.blueAccent.shade200,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Select Date',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 30,
              itemBuilder: (context, index) {
                DateTime date = DateTime.now().subtract(Duration(days: index));
                return ValueListenableBuilder<DateTime>(
                  valueListenable: selectedDateNotifier,
                  builder: (context, selectedDate, child) {
                    bool isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;
                    bool isToday = date.day == DateTime.now().day &&
                        date.month == DateTime.now().month &&
                        date.year == DateTime.now().year;

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 70,
                      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white 
                            : (isToday ? Colors.white54 : Colors.white24),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: isSelected 
                            ? [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          selectedDateNotifier.value = date;
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSelected 
                                    ? Colors.blueAccent 
                                    : (isToday ? Colors.white : Colors.white70),
                              ),
                            ),
                            Text(
                              ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                                  [date.weekday - 1],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected 
                                    ? Colors.blueAccent.shade200 
                                    : (isToday ? Colors.white : Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
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

class HabitList extends StatefulWidget {
  @override
  _HabitListState createState() => _HabitListState();
}

class _HabitListState extends State<HabitList> {
  @override
  void initState() {
    super.initState();
    selectedDateNotifier.addListener(() {
      setState(() {}); // Rebuild when selected date changes
    });
  }

  void _addCategory() {
    if (selectedDateNotifier.value.day != DateTime.now().day) return;
    String categoryName = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Category'),
        content: TextField(
          onChanged: (value) => categoryName = value,
          decoration: InputDecoration(hintText: 'Enter category name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (categoryName.isNotEmpty) {
                _updateFirestore(categoryName, []);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

void _updateFirestore(String category, List tasks) async {
  String currentDate = selectedDateNotifier.value.toIso8601String().split('T')[0];
  var docRef = FirebaseFirestore.instance
      .collection('Users')
      .doc("rishu970820@gmail.com")
      .collection('habbits')
      .doc(currentDate);

  var docSnap = await docRef.get();
  
  List habits = docSnap.exists && docSnap.data() != null ? docSnap.data()!['habbits'] ?? [] : [];
  
  // Check if category already exists
  bool categoryExists = habits.any((habit) => habit['category'] == category);
  
  if (!categoryExists) {
    // Add new category if it doesn't exist
    habits.add({
      'category': category, 
      'tasks': tasks
    });
  } else {
    // If category exists, add tasks to existing category
    for (var habit in habits) {
      if (habit['category'] == category) {
        // Merge new tasks with existing tasks, avoiding duplicates
        List existingTasks = habit['tasks'] ?? [];
        for (var newTask in tasks) {
          bool taskExists = existingTasks.any((task) => task['name'] == newTask['name']);
          if (!taskExists) {
            existingTasks.add(newTask);
          }
        }
        habit['tasks'] = existingTasks;
        break;
      }
    }
  }

  // Update the entire document
  await docRef.set({
    'habbits': habits
  }, SetOptions(merge: true));
}

  @override
  Widget build(BuildContext context) {
    String currentDate = selectedDateNotifier.value.toIso8601String().split('T')[0];
    
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc("rishu970820@gmail.com")
                .collection('habbits')
                .doc(currentDate)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                print('Creating default habits');
                _createDefaultHabits();
                return Center(child: Text('No habits found for this date.'));
              }

              var habits = snapshot.data!.data()?['habbits'] ?? [];
              return ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  var habitCategory = habits[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.pink.shade50,
                          Colors.pink.shade100,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: ExpansionTile(
                      title: Text(
                        habitCategory['category'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade400,
                        ),
                      ),
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: habitCategory['tasks'].map<Widget>((task) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ChoiceChip(
                                  label: Text(task['name']),
                                  selected: task['completed'],
                                  onSelected: selectedDateNotifier.value.day == DateTime.now().day
                                      ? (bool selected) {
                                          _toggleHabit(habitCategory['category'], task['name'], selected);
                                        }
                                      : null,
                                  selectedColor: Colors.pink.shade200,
                                  backgroundColor: Colors.pink.shade50,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // Add Habit Button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            onPressed: () => _addHabit(habitCategory['category']),
                            child: Text('Add Habit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        // Add Category Floating Button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _addCategory,
            backgroundColor: Colors.pink.shade300,
            mini: true,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _addHabit(String category) {
    String habitName = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Habit'),
        content: TextField(
          onChanged: (value) => habitName = value,
          decoration: InputDecoration(hintText: 'Enter habit name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (habitName.isNotEmpty) {
                _updateFirestore(category, [{'name': habitName, 'completed': false}]);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _toggleHabit(String category, String habitName, bool value) async {
    String currentDate = selectedDateNotifier.value.toIso8601String().split('T')[0];
    var docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc("rishu970820@gmail.com")
        .collection('habbits')
        .doc(currentDate);
    var docSnap = await docRef.get();
    if (docSnap.exists) {
      List habits = docSnap.data()?['habbits'] ?? [];
      for (var habit in habits) {
        if (habit['category'] == category) {
          for (var task in habit['tasks']) {
            if (task['name'] == habitName) {
              task['completed'] = value;
              break;
            }
          }
        }
      }
      docRef.update({'habbits': habits});
    }
  }

  void _createDefaultHabits() {
    String currentDate = selectedDateNotifier.value.toIso8601String().split('T')[0];
    List<Map<String, dynamic>> defaultHabits = [
      {
        'category': 'Daily Wellness',
        'tasks': [
          {'name': 'Drink Water', 'completed': false},
          {'name': 'Exercise', 'completed': false},
          {'name': 'Meditate', 'completed': false},
        ]
      },
      {
        'category': 'Productivity',
        'tasks': [
          {'name': 'Read', 'completed': false},
          {'name': 'Plan Day', 'completed': false},
          {'name': 'Learn Something New', 'completed': false},
        ]
      },
      {
        'category': 'Personal Care',
        'tasks': [
          {'name': 'Sleep on Time', 'completed': false},
          {'name': 'Skincare Routine', 'completed': false},
          {'name': 'Healthy Meal', 'completed': false},
        ]
      }
    ];

    FirebaseFirestore.instance
        .collection('Users')
        .doc("rishu970820@gmail.com")
        .collection('habbits')
        .doc(currentDate)
        .set({'habbits': defaultHabits}, SetOptions(merge: true));
  }
}