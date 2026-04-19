import 'package:flutter/material.dart';
import 'tasks_screen.dart';
import 'schedule_screen.dart';

class HomeScreen extends StatefulWidget{
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // tracks current tab

  final List<Widget> _screens = [   
    Center(child: TasksScreen()),
    Center(child: ScheduleScreen()),
    Center(child: Text("Notes Screen")),
  ];

  void _onTabTapped(int index) {  //onTap when user clicks
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Organizer"),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: "Notes"),
        ],
      ),
    );
  }
}


/*
Full flow

User taps tab
 ↓
onTap triggered
 ↓
setState() updates index
 ↓
build() runs again
 ↓
new screen displayed
*/