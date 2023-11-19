import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_flutter/task_controller.dart';

class DatabaseController {
  DatabaseController._();
  static final DatabaseController db = DatabaseController._();
  Database? _database;

  Future<Database> get database async {
    return _database ??= await getDatabaseInstance();
  }

  Future<Database> getDatabaseInstance() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'todo.db');
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      db.execute("CREATE TABLE Todo("
          "taskName TEXT primary key,"
          "priority TEXT,"
          "isDone INTEGER"
          ")");
    });
  }

  Future addTask(Task task) async {
    final db = await database;
    var response = await db.insert("Todo", task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return response;
  }

  updateTask(Task newTask, String oldTaskName) async {
    final db = await database;
    var response = await db.update("Todo", newTask.toMap(),
        where: 'taskName= ?', whereArgs: [oldTaskName]);
    return response;
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    List<Task> tasks = [];
    var response = await db.query("Todo");
    for (int i = 0; i < response.length; i++) {
      tasks.add(Task.fromMap(response[i]));
    }
    return tasks;
  }

  Future deleteTask(String taskName) async {
    final db = await database;
    return db.delete("Todo", where: "taskName= ?", whereArgs: [taskName]);
  }
}
