/// This file defines the Weather model for storing weather data.

/// Represents weather conditions with temperature and humidity.
/// This model is used to store and pass weather information throughout the app.
class Weather {
  /// The temperature in degrees Celsius.
  final double temperature;

  /// The humidity percentage.
  final int humidity;

  /// Constructor for Weather.
  Weather({
    required this.temperature,
    required this.humidity,
  });
}
