/// Represents a feeding item for a specific tank in the prawn farm.
/// This model holds information about scheduled feeding times, completion status, and alarm settings.
class FeedingItem {
  /// Unique identifier for the feeding item.
  final int id;

  /// Name of the tank associated with this feeding item.
  final String tankName;

  /// Scheduled time for the feeding.
  DateTime scheduledTime;

  /// Indicates whether the feeding has been completed.
  bool isCompleted;

  /// Indicates whether an alarm is enabled for this feeding item.
  bool alarmEnabled;

  /// Constructor for FeedingItem.
  FeedingItem({
    required this.id,
    required this.tankName,
    required this.scheduledTime,
    required this.isCompleted,
    required this.alarmEnabled,
  });

  /// Factory constructor to create a FeedingItem from a JSON map.
  factory FeedingItem.fromJson(Map<String, dynamic> json) {
    return FeedingItem(
      id: json['id'] as int,
      tankName: json['tank_name'] as String,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
      alarmEnabled: json['alarm_enabled'] as bool? ?? true,
    );
  }

  /// Converts the FeedingItem to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tank_name': tankName,
      'scheduled_time': scheduledTime.toIso8601String(),
      'is_completed': isCompleted,
      'alarm_enabled': alarmEnabled,
    };
  }
}
