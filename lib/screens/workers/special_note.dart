import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class SpecialNotePage extends StatefulWidget {
  const SpecialNotePage({super.key});

  @override
  State<SpecialNotePage> createState() => _SpecialNotePageState();
}

class _SpecialNotePageState extends State<SpecialNotePage> {
  final TaskApiService _taskService = TaskApiService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final token = prefs.getString('token');
      if (token == null) {
        if (mounted) {
          setState(() {
            _errorMessage =
                'No authentication token found. Please login again.';
            _isLoading = false;
          });
        }
        return;
      }
      final tasks = await _taskService.fetchTasks(token);
      if (!mounted) return;
      tasks.sort((a, b) {
        if (a.status.toLowerCase() == 'pending' &&
            b.status.toLowerCase() != 'pending') return -1;
        if (a.status.toLowerCase() != 'pending' &&
            b.status.toLowerCase() == 'pending') return 1;
        return 0;
      });
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('401') ||
          e.toString().contains('Invalid token')) {
        // Clear invalid token
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        if (mounted) {
          setState(() {
            _errorMessage =
                'Authentication failed. Token may be expired. Please login again.';
            _isLoading = false;
          });
        }
        // Optionally navigate to login screen
        // Navigator.of(context).pushReplacementNamed('/login'); // Uncomment if login route exists
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load tasks: $e';
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 29, 205, 38), Color(0xFF4F46E5)],
          ),
        ),
        child: Column(
          children: [
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _fetchTasks,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Tasks',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 24),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _errorMessage != null
                                ? Center(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.red),
                                    ),
                                  )
                                : _tasks.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No tasks available.',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      )
                                    : ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 16),
                                        itemCount: _tasks.length,
                                        itemBuilder: (context, index) {
                                          final task = _tasks[index];
                                          return Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              task.title,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              task.content,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        '${task.createdAt.toLocal().hour}:${task.createdAt.toLocal().minute.toString().padLeft(2, '0')}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: task.status
                                                                .toLowerCase() ==
                                                            'completed'
                                                        ? Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .green
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .green),
                                                            ),
                                                            child: const Text(
                                                              'Completed',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          )
                                                        : ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              final prefs =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              if (!mounted)
                                                                return;
                                                              final token = prefs
                                                                  .getString(
                                                                      'token');
                                                              if (token ==
                                                                  null) {
                                                                _scaffoldMessenger
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Authentication token not found')),
                                                                );
                                                                return;
                                                              }
                                                              try {
                                                                await _taskService
                                                                    .updateTaskStatus(
                                                                        task.id,
                                                                        token);
                                                                // Refetch tasks to ensure persistence
                                                                await _fetchTasks();
                                                                _scaffoldMessenger
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Task marked as read')),
                                                                );
                                                              } catch (e) {
                                                                _scaffoldMessenger
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          'Failed to update task: $e')),
                                                                );
                                                              }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.green,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                                'Mark as Read'),
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
