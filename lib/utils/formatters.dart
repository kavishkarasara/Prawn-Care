class Formatters {
  static String formatTime(DateTime time) {
    String minute = time.minute.toString().padLeft(2, '0');
    String amPm = time.hour >= 12 ? 'pm' : 'am';

    int displayHour = time.hour;
    if (displayHour > 12) {
      displayHour -= 12;
    } else if (displayHour == 0) {
      displayHour = 12;
    }

    return '$displayHour.$minute $amPm';
  }

  static String getTimeRemaining(DateTime scheduledTime) {
    DateTime now = DateTime.now();
    Duration difference = scheduledTime.difference(now);

    if (difference.isNegative) {
      return 'Ready to feed';
    } else {
      int hours = difference.inHours;
      int minutes = difference.inMinutes % 60;
      int seconds = difference.inSeconds % 60;

      if (hours > 0) {
        return '${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
      } else if (minutes > 0) {
        return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
      } else {
        return '${seconds}s';
      }
    }
  }
}
