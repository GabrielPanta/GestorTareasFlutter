import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List<dynamic> jsonData = jsonDecode(tasksString);
      setState(() {
        tasks = jsonData.map((e) => Task.fromJson(e)).toList();
      });
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await prefs.setString('tasks', encoded);
  }

  void addTask(String title) {
    if (title.isEmpty) return;
    setState(() {
      tasks.add(Task(title: title));
      controller.clear();
    });
    saveTasks();
  }

  void toggleDone(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Tareas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Nueva tarea',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => addTask(controller.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (_) => toggleDone(index),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteTask(index),
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
