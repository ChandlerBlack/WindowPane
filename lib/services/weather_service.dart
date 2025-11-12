import 'dart:convert';
import 'package:http/http.dart' as http;

// This is not working lmao 


class WeatherService {
  // Using Open-Meteo API (free, no key required)
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> getWeather(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '$baseUrl?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code&temperature_unit=celsius'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        
        return {
          'temperature': current['temperature_2m'],
          'condition': _getWeatherCondition(current['weather_code']),
        };
      } else {
        return {'temperature': 0.0, 'condition': 'Unknown'};
      }
    } catch (e) {
      return {'temperature': 0.0, 'condition': 'Unknown'};
    }
  }

  String _getWeatherCondition(int code) {
    // WMO Weather interpretation codes
    if (code == 0) return 'Clear skies';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain showers';
    if (code <= 86) return 'Snow showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }
}