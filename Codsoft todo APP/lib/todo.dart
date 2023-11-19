// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_flutter/task_controller.dart';

import 'db_controller.dart';

enum Priority { High, Normal, Low }

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  TextEditingController taskNameController = TextEditingController();
  Task? editingTask;
  Priority? _selectedPriority = Priority.Normal;
  List<Task> tasks = [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTasks();
  }

  loadTasks() async {
    setState(() {
      isLoading = true;
    });
    tasks = await DatabaseController.db.getAllTasks();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            buildShowAddTaskModalBottomSheet(context);
          },
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: Icon(Icons.add)),
      appBar: AppBar(
          title: Center(
        child: Text("My TODO"),
      )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.yellow,
              child: ListTile(
                leading: Checkbox(
                    value: tasks[index].isDone,
                    fillColor: MaterialStatePropertyAll(Colors.white),
                    checkColor: Colors.green,
                    onChanged: (value) {
                      setState(() {});
                      tasks[index].isDone = value!;
                    }),
                title: Text(tasks[index].taskName,
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headlineSmall!.fontSize,
                        fontWeight: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.fontWeight,
                        decoration: tasks[index].isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none)),
                subtitle: Text(
                  tasks[index].priority,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          editingTask = tasks[index];
                          buildShowEditTaskModalBottomSheet(context);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.green,
                        )),
                    IconButton(
                        onPressed: () {
                          DatabaseController.db
                              .deleteTask(tasks[index].taskName)
                              .then((value) => loadTasks());
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void editTask(Task task) {
    setState(() {
      editingTask = task;
      taskNameController.text = task.taskName;
      _selectedPriority = Priority.values.firstWhere(
        (priority) => priority.toString().split('.').last == task.priority,
        orElse: () => Priority.Normal,
      );
    });
    buildShowAddTaskModalBottomSheet(context);
  }

  // Method for adding a new task
  void addTask() {
    setState(() {
      editingTask = null;
      taskNameController.text = '';
      _selectedPriority = Priority.Normal;
    });
    buildShowAddTaskModalBottomSheet(context);
  }

  Future<dynamic> buildShowEditTaskModalBottomSheet(BuildContext context) {
    taskNameController.text = editingTask!.taskName.toString();
    _selectedPriority = null;
    return showModalBottomSheet(
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, StateSetter setModalState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: taskNameController,
                decoration: InputDecoration(hintText: 'Edit task'),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Task Priority:',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton<Priority>(
                    value: _selectedPriority,
                    onChanged: (value) {
                      setModalState(() {
                        if (value != null) {
                          _selectedPriority = value;
                        }
                      });
                    },
                    items: Priority.values.map((Priority priority) {
                      return DropdownMenuItem<Priority>(
                        value: priority,
                        child: Text(priority.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      DatabaseController.db.updateTask(
                          Task(
                            taskName: taskNameController.text,
                            priority:
                                _selectedPriority.toString().split('.').last,
                          ),
                          editingTask!.taskName.toString());
                      loadTasks();
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<dynamic> buildShowAddTaskModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, StateSetter setModalState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: taskNameController,
                decoration: InputDecoration(hintText: 'Add a new task'),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Task Priority:',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton<Priority>(
                    value: _selectedPriority,
                    onChanged: (value) {
                      setModalState(() {
                        if (value != null) {
                          _selectedPriority = value;
                        }
                      });
                    },
                    items: Priority.values.map((Priority priority) {
                      return DropdownMenuItem<Priority>(
                        value: priority,
                        child: Text(priority.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      DatabaseController.db.addTask(
                        Task(
                          taskName: taskNameController.text,
                          priority:
                              _selectedPriority.toString().split('.').last,
                        ),
                      );
                      _selectedPriority = null;
                      taskNameController.clear();
                      loadTasks();
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
