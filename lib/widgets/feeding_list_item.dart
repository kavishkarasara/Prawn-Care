// lib/screens/feeding_schedule/widgets/feeding_list_item.dart

import 'package:flutter/material.dart';
import '../../../models/feeding_item.dart';
import '../../../utils/colors.dart';
import '../../../utils/formatters.dart';

class FeedingListItem extends StatelessWidget {
  final FeedingItem item;
  final VoidCallback onToggleAlarm;
  final VoidCallback onEditTime;
  final VoidCallback onRemove;
  final VoidCallback onMarkAsCompleted;

  const FeedingListItem({
    super.key,
    required this.item,
    required this.onToggleAlarm,
    required this.onEditTime,
    required this.onRemove,
    required this.onMarkAsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor = AppColors.getCardColor(item.scheduledTime);
    Color timeColor = AppColors.getTimeColor(item.scheduledTime);

    // Change colors if feeding is due soon or overdue
    if (AppColors.isDueSoon(item.scheduledTime)) {
      cardColor = Colors.lightBlue.shade100; // light blue for due soon
      timeColor = Colors.lightBlue.shade700;
    } else if (AppColors.isOverdue(item.scheduledTime)) {
      cardColor = Colors.red.shade100; // light red for overdue
      timeColor = Colors.red.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.tankName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Removed alarm toggle button as per user request
                  // GestureDetector(
                  //   onTap: onToggleAlarm,
                  //   child: Icon(
                  //     item.alarmEnabled ? Icons.alarm : Icons.alarm_off,
                  //     color: item.alarmEnabled ? Colors.orange : Colors.grey,
                  //     size: 24,
                  //   ),
                  // ),
                  // const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onEditTime,
                    child:
                        const Icon(Icons.edit, color: primaryColor, size: 24),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onRemove,
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 24),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onMarkAsCompleted,
                    child: Icon(
                      item.isCompleted
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: item.isCompleted ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onEditTime,
                child: Text(
                  Formatters.formatTime(item.scheduledTime),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: timeColor,
                  ),
                ),
              ),
              Text(
                Formatters.getTimeRemaining(item.scheduledTime),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: timeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
