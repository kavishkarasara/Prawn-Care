import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';

class WorkerNotificationService {
  static Future<void> showNotificationDialog(
      BuildContext context, Function(bool) updateNotificationState) async {
    await WorkerNotificationManager.instance.refreshReminders();

    Timer? autoRefreshTimer;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Start auto-refresh timer when dialog opens
            autoRefreshTimer ??=
                Timer.periodic(const Duration(seconds: 30), (timer) async {
              await WorkerNotificationManager.instance.refreshReminders();
              setState(() {});
            });

            final notifications =
                WorkerNotificationManager.instance.getUnreadNotifications();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  const Icon(Icons.notifications,
                      color: Colors.amber, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${WorkerNotificationManager.instance.notifications.length} notifications',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: notifications.isEmpty
                    ? const Center(
                        child: Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _buildNotificationItem(
                            icon: notification.icon,
                            iconColor: notification.iconColor,
                            title: notification.title,
                            message: notification.message,
                            time: notification.time,
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await WorkerNotificationManager.instance.refreshReminders();
                    setState(() {});
                  },
                  child: const Text(
                    'Refresh',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    WorkerNotificationManager.instance.markAllAsRead();
                    updateNotificationState(false);
                    autoRefreshTimer?.cancel();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Mark All as Read',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    autoRefreshTimer?.cancel();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Cancel timer when dialog is dismissed
      autoRefreshTimer?.cancel();
    });
  }

  static Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildNotificationButton({
    required bool hasNotification,
    required VoidCallback onTap,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: WorkerNotificationManager.instance.unreadCountNotifier,
      builder: (context, unreadCount, child) {
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Color.fromARGB(255, 255, 225, 57),
                  size: 24,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Worker Notification Model
class WorkerNotification {
  final int id;
  final int? feedingId; // Optional, for feeding reminders
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead;

  WorkerNotification({
    required this.id,
    this.feedingId,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType {
  temperature,
  humidity,
  feeding,
  order,
  alert,
  task,
  system,
}

// Feeding Reminder Model
class FeedingReminder {
  final int feedingId;
  final int pondId;
  final String reminderTime;
  final String message;
  final bool acknowledged;

  FeedingReminder({
    required this.feedingId,
    required this.pondId,
    required this.reminderTime,
    required this.message,
    required this.acknowledged,
  });

  factory FeedingReminder.fromJson(Map<String, dynamic> json) {
    return FeedingReminder(
      feedingId: json['feeding_ID'],
      pondId: json['pond_ID'],
      reminderTime: json['reminder_time'],
      message: json['message'],
      acknowledged: json['acknowledged'] ?? false,
    );
  }
}

// Worker Notification Manager
class WorkerNotificationManager {
  static final WorkerNotificationManager instance =
      WorkerNotificationManager._internal();

  WorkerNotificationManager._internal() {
    _initSocket();
    startReminderChecking();
  }

  List<WorkerNotification> notifications = [];

  Timer? _reminderTimer;
  static const Duration reminderCheckInterval = Duration(minutes: 1);
  IO.Socket? _socket;
  ValueNotifier<int> unreadCountNotifier = ValueNotifier(0);

  Future<List<WorkerNotification>> getNotifications() async {
    return notifications;
  }

  int getUnreadCount() {
    return notifications.where((notification) => !notification.isRead).length;
  }

  void markAllAsRead() {
    for (var notification in notifications) {
      notification.isRead = true;
    }
    unreadCountNotifier.value = getUnreadCount();
  }

  void addNotification(WorkerNotification notification) {
    notifications.insert(0, notification);
    unreadCountNotifier.value = getUnreadCount();
    _showPushNotification(notification);
  }

  // Show push notification
  void _showPushNotification(WorkerNotification notification) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'worker_notifications_channel',
      'Worker Notifications',
      channelDescription: 'Notifications for workers',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/launcher_icon',
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    FlutterLocalNotificationsPlugin().show(
      notification.id,
      notification.title,
      notification.message,
      platformChannelSpecifics,
      payload: 'worker_notification_${notification.id}',
    );
  }

  void removeNotification(int id) {
    notifications.removeWhere((notification) => notification.id == id);
  }

  List<WorkerNotification> getNotificationsByType(NotificationType type) {
    return notifications
        .where((notification) => notification.type == type)
        .toList();
  }

  List<WorkerNotification> getUnreadNotifications() {
    return notifications.where((notification) => !notification.isRead).toList();
  }

  Future<void> refreshReminders() async {
    await _checkForReminders();
  }

  // Start periodic reminder checking
  void startReminderChecking() {
    _reminderTimer?.cancel();
    _checkForReminders(); // Initial check
    _reminderTimer = Timer.periodic(reminderCheckInterval, (timer) {
      _checkForReminders();
    });
  }

  // Stop periodic reminder checking
  void stopReminderChecking() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  // Fetch reminders from backend
  Future<List<FeedingReminder>> _fetchReminders() async {
    try {
      final response = await http
          .get(Uri.parse('$BACKEND_BASE_URL/api/mobile/worker/reminder'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FeedingReminder.fromJson(json)).toList();
      } else {
        print('Failed to fetch reminders: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching reminders: $e');
      return [];
    }
  }

  // Initialize Socket.IO connection
  void _initSocket() {
    _socket = IO.io(BACKEND_BASE_URL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from Socket.IO server');
    });

    _socket!.on('feeding-reminder', (data) {
      print('Received feeding reminder: $data');
      _handleFeedingReminder(data);
    });

    _socket!.connect();
  }

  // Handle incoming feeding reminder from Socket.IO
  void _handleFeedingReminder(dynamic data) {
    try {
      FeedingReminder reminder = FeedingReminder.fromJson(data);
      if (!reminder.acknowledged) {
        // Check if notification for this feedingId already exists
        bool alreadyExists =
            notifications.any((n) => n.feedingId == reminder.feedingId);
        if (!alreadyExists) {
          // Create a unique ID for the notification (must be 32-bit integer)
          int notificationId = (reminder.feedingId % 1000000) + 1000000;

          WorkerNotification notification = WorkerNotification(
            id: notificationId,
            feedingId: reminder.feedingId,
            icon: Icons.restaurant,
            iconColor: Colors.green,
            title: 'Feeding Reminder',
            message: reminder.message,
            time: 'Just now',
            timestamp: DateTime.now(),
            type: NotificationType.feeding,
            isRead: false,
          );

          // Add to notifications list
          addNotification(notification);
        }
      }
    } catch (e) {
      print('Error handling feeding reminder: $e');
    }
  }

  // Check for new reminders and add them as notifications
  Future<void> _checkForReminders() async {
    List<FeedingReminder> reminders = await _fetchReminders();
    print('Fetched ${reminders.length} reminders');
    for (var reminder in reminders) {
      print(
          'Reminder: ${reminder.feedingId}, acknowledged: ${reminder.acknowledged}');
      if (!reminder.acknowledged) {
        // Check if notification for this feedingId already exists
        bool alreadyExists =
            notifications.any((n) => n.feedingId == reminder.feedingId);
        if (!alreadyExists) {
          print('Adding notification for reminder ${reminder.feedingId}');
          // Create a unique ID for the notification (must be 32-bit integer)
          int notificationId = (reminder.feedingId % 1000000) + 1000000;

          WorkerNotification notification = WorkerNotification(
            id: notificationId,
            feedingId: reminder.feedingId,
            icon: Icons.restaurant,
            iconColor: Colors.green,
            title: 'Feeding Reminder',
            message: reminder.message,
            time: 'Just now',
            timestamp: DateTime.now(),
            type: NotificationType.feeding,
            isRead: false,
          );

          // Add to notifications list
          addNotification(notification);
          print(
              'Notification added, total notifications: ${notifications.length}');
        } else {
          print(
              'Notification for reminder ${reminder.feedingId} already exists');
        }
      } else {
        print(
            'Skipping reminder ${reminder.feedingId} because acknowledged: ${reminder.acknowledged}');
      }
    }
  }
}
