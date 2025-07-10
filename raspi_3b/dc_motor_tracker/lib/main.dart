import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(DCMotorTrackerApp());
}

class DCMotorTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DC Motor Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        fontFamily: 'Roboto',
      ),
      home: StartScreen(),
    );
  }
}
