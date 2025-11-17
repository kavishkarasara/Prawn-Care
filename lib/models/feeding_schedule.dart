/// Represents a feeding schedule item for a specific pond.
/// This model contains the feeding ID, pond ID, and the scheduled feeding time.
class FeedingScheduleItem {
  /// Unique identifier for the feeding schedule item.
  final int feedingID;

  /// Identifier for the pond associated with this feeding schedule.
  final int pondID;

  /// The scheduled time for feeding in string format.
  final String feedingTime;

  /// Constructor for FeedingScheduleItem.
  FeedingScheduleItem({
    required this.feedingID,
    required this.pondID,
    required this.feedingTime,
  });

  /// Factory constructor to create a FeedingScheduleItem from a JSON map.
  factory FeedingScheduleItem.fromJson(Map<String, dynamic> json) {
    return FeedingScheduleItem(
      feedingID: json['feeding_ID'] as int,
      pondID: json['Pond_ID'] as int,
      feedingTime: json['feeding_time'] as String,
    );
  }

  /// Converts the FeedingScheduleItem to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'feeding_ID': feedingID,
      'Pond_ID': pondID,
      'feeding_time': feedingTime,
    };
  }
}
