import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> tasks = [
    {"title": "Study Flutter", "isDone": false},
    {"title": "Complete Assignment", "isDone": false},
    {"title": "Revise Notes", "isDone": true},
  ];

  void toggleTask(int index) {
    setState(() {
      tasks[index]["isDone"] = !tasks[index]["isDone"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter task",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // print("Button clicked");
                    // print(_controller.text);

                    if (_controller.text.isNotEmpty) {
                      setState(() {
                        tasks.add({
                          "title": _controller.text,
                          "isDone": false,
                        });
                      });
                      _controller.clear();
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      tasks[index]["title"],
                      style: TextStyle(
                        decoration: tasks[index]["isDone"]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Icon(
                      tasks[index]["isDone"]
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                    ),
                    onTap: () => toggleTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}