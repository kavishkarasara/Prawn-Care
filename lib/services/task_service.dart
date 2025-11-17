import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../utils/constants.dart';

class TaskApiService {
  Future<List<Task>> fetchTasks(String token) async {
    final url = Uri.parse('$BACKEND_BASE_URL/api/mobile/worker/tasks');
    print('Fetching tasks from: $url');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Parsed data: $data');
      final tasks = data.map((json) => Task.fromJson(json)).toList();
      print('Tasks: $tasks');
      return tasks;
    } else if (response.statusCode == 401) {
      throw Exception('401 {"error":"Invalid token"}');
    } else {
      throw Exception(
          'Failed to load tasks: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> updateTaskStatus(int taskId, String token) async {
    final url =
        Uri.parse('$BACKEND_BASE_URL/api/mobile/worker/update-task-status');
    print('Updating task status for task ID: $taskId');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'task_id': taskId, 'status': 'completed'}),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('Task status updated successfully');
    } else if (response.statusCode == 401) {
      throw Exception('401 {"error":"Invalid token"}');
    } else if (response.statusCode == 404) {
      throw Exception('Task not found or not assigned to this worker');
    } else {
      throw Exception(
          'Failed to update task status: ${response.statusCode} ${response.body}');
    }
  }
}
