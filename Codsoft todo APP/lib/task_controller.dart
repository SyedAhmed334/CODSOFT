class Task {
  final String taskName;
  final String priority;
  bool isDone;
  Task({required this.taskName, required this.priority, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {
      'taskName': taskName,
      'priority': priority,
      'isDone': isDone ? 1 : 0
    };
  }

  static Task fromMap(Map<String, dynamic> json) {
    return Task(
        taskName: json["taskName"],
        priority: json["priority"],
        isDone: json["isDone"] == 0 ? false : true);
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
