import 'package:flutter/material.dart';

class MonthlyTargetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Target'),
      ),
      body: Center(
        child: Text(
          'Set your monthly target here!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}