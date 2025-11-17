import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prawn__farm/models/weather_model.dart';
import 'package:prawn__farm/utils/constants.dart';

class WeatherService {
  Future<Weather> getWeather(double lat, double lon) async {
    final url =
        Uri.parse('$BASE_URL?lat=$lat&lon=$lon&appid=$API_KEY&units=metric');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['main'] != null) {
          final mainData = data['main'];
          if (mainData['temp'] != null && mainData['humidity'] != null) {
            return Weather(
              temperature: mainData['temp'].toDouble(),
              humidity: mainData['humidity'],
            );
          } else {
            throw Exception("Incomplete weather data received.");
          }
        } else {
          throw Exception("Invalid weather data format.");
        }
      } else if (response.statusCode == 401) {
        throw Exception("Invalid API key.");
      } else if (response.statusCode == 429) {
        throw Exception("API rate limit exceeded.");
      } else {
        throw Exception(
            "Failed to fetch weather data: HTTP ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception("The request to the weather API timed out.");
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }
}
