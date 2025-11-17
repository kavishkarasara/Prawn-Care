import 'package:flutter/material.dart';
import 'package:prawn__farm/models/notification_item.dart';

class NotificationDialog extends StatelessWidget {
  final VoidCallback onMarkAllAsRead;
  final List<NotificationItem> notifications;
  final int unreadCount;

  const NotificationDialog({
    super.key,
    required this.onMarkAllAsRead,
    required this.notifications,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Row(
        children: [
          Icon(Icons.notifications, color: Colors.amber, size: 28),
          SizedBox(width: 10),
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: notifications.isEmpty
              ? [const Text('No notifications')]
              : notifications
                  .map((notification) => Column(
                        children: [
                          _buildNotificationItem(
                            icon: notification.icon,
                            iconColor: notification.iconColor,
                            title: notification.title,
                            message: notification.message,
                            time: notification.time,
                          ),
                          if (notification != notifications.last)
                            const Divider(),
                        ],
                      ))
                  .toList(),
        ),
      ),
      actions: [
        if (unreadCount > 0)
          TextButton(
            onPressed: () {
              onMarkAllAsRead();
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
  }

  Widget _buildNotificationItem({
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
}
