import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  final List<Map<String, String>> subjects = [
    {"name": "Math", "time": "9:00 AM"},
    {"name": "Physics", "time": "10:00 AM"},
    {"name": "Chemistry", "time": "11:00 AM"},
    {"name": "English", "time": "12:00 PM"},
    {"name": "CS", "time": "1:00 PM"},
    {"name": "Sports", "time": "2:00 PM"},
  ];

  void showDetails(BuildContext context, Map<String, String> subject) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(subject["name"]!),
          content: Text("Time: ${subject["time"]}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];

        return GestureDetector(
          onTap: () => showDetails(context, subject),
          child: Card(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(subject["name"]!, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 5),
                  Text(subject["time"]!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}