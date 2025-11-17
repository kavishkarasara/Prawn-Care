/// Represents a task assigned to a worker in the prawn farm system.
/// This model contains task details such as title, content, creation date, and status.
class Task {
  /// Unique identifier for the task.
  final int id;

  /// Identifier of the user (worker) assigned to the task.
  final int userId;

  /// Title or name of the task.
  final String title;

  /// Detailed content or description of the task.
  final String content;

  /// Date and time when the task was created.
  final DateTime createdAt;

  /// Current status of the task (e.g., pending, completed).
  final String status;

  /// Constructor for Task.
  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.status,
  });

  /// Factory constructor to create a Task from a JSON map.
  /// Handles type conversions and provides default values for missing fields.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['task_id'] != null
          ? int.tryParse(json['task_id'].toString()) ?? 0
          : 0,
      userId: json['worker_id'] != null
          ? int.tryParse(json['worker_id'].toString()) ?? 0
          : 0,
      title: json['title'] ?? '',
      content: json['description'] ?? '',
      createdAt: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }

  /// Returns a string representation of the Task.
  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status)';
  }
}
