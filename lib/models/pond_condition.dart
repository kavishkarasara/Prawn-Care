/// Enumeration representing the possible statuses of a pond's condition.
/// This enum is used to categorize the health and operational state of ponds.
enum PondStatus {
  /// The pond is in good condition with optimal parameters.
  good,

  /// The pond has some parameters that require attention.
  warning,

  /// The pond is in a critical state and needs immediate action.
  alert,

  /// The pond is in a normal, acceptable condition.
  normal,
}

/// Represents the condition and parameters of a pond in the prawn farm.
/// This model holds sensor data, connectivity status, and computed health metrics for monitoring pond conditions.
class PondCondition {
  /// Unique identifier for the pond.
  final String id;

  /// Name of the pond.
  final String pondName;

  /// Base URL for accessing the pond's sensor data.
  final String baseUrl;

  /// Base URL specifically for pH sensor data.
  final String phBaseUrl;

  /// Current water level in the pond.
  final double waterLevel;

  /// Clarity of the water, often related to dissolved oxygen.
  final double clarity;

  /// pH level of the water.
  final double phLevel;

  /// Temperature of the water in degrees Celsius.
  final double temperature;

  /// Indicates whether the pond's sensors are connected and reporting data.
  final bool isConnected;

  /// Timestamp of the last update from the pond's sensors.
  final DateTime lastUpdated;

  /// Constructor for PondCondition.
  PondCondition({
    required this.id,
    required this.pondName,
    required this.baseUrl,
    required this.phBaseUrl,
    this.waterLevel = 0.0,
    this.clarity = 0.0,
    this.phLevel = 0.0,
    this.temperature = 0.0,
    this.isConnected = false,
    required this.lastUpdated,
  });

  /// Determines if the pond is in a healthy state based on sensor readings.
  /// Returns true if all parameters are within acceptable ranges and the pond is connected.
  bool get isHealthy {
    if (!isConnected) return false;
    return clarity >= 500 &&
        phLevel >= 6.0 &&
        phLevel <= 8.5 &&
        waterLevel >= 1.0 &&
        temperature >= 18.0 &&
        temperature <= 28.0;
  }

  /// Gets the dissolved oxygen level, which is represented by clarity in this model.
  double get dissolvedOxygen => clarity;

  /// Gets the turbidity level, currently mapped to water level.
  /// Note: This may need adjustment if a dedicated turbidity field is added.
  double get turbidity =>
      waterLevel; // Assuming turbidity relates to water level or add a field if needed

  /// Extracts the IP address from the base URL.
  String get ipAddress =>
      baseUrl.replaceFirst('http://', '').replaceFirst('https://', '');

  /// Gets the pH level of the water.
  double get ph => phLevel;

  /// Computes the overall status of the pond based on connectivity and health.
  PondStatus? get status {
    if (!isConnected) return PondStatus.alert;
    if (isHealthy) return PondStatus.good;
    return PondStatus.warning;
  }

  /// Equality operator based on the pond ID.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PondCondition && other.id == id;
  }

  /// Hash code based on the pond ID.
  @override
  int get hashCode => id.hashCode;
}
