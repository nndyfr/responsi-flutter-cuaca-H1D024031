class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final double windSpeed;
  final int weatherCode;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCode,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> j) => CurrentWeather(
    temperature: (j['temperature_2m'] as num).toDouble(),
    apparentTemperature: (j['apparent_temperature'] as num).toDouble(),
    humidity: (j['relative_humidity_2m'] as num).toInt(),
    precipitation: (j['precipitation'] as num).toDouble(),
    windSpeed: (j['wind_speed_10m'] as num).toDouble(),
    weatherCode: (j['weather_code'] as num).toInt(),
  );
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final int rainChance;

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.rainChance,
  });
}

class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherData({required this.current, required this.daily});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final d = json['daily'];
    final times = List<String>.from(d['time']);
    final daily = List.generate(times.length, (i) => DailyForecast(
      date: DateTime.parse(times[i]),
      weatherCode: (d['weather_code'][i] as num).toInt(),
      maxTemp: (d['temperature_2m_max'][i] as num).toDouble(),
      minTemp: (d['temperature_2m_min'][i] as num).toDouble(),
      rainChance:
      ((d['precipitation_probability_max'][i] ?? 0) as num).toInt(),
    ));
    return WeatherData(
      current: CurrentWeather.fromJson(json['current']),
      daily: daily,
    );
  }
}

/// Ubah kode cuaca WMO jadi teks (dipakai di View).
String weatherDescription(int code) {
  if (code == 0) return 'Cerah';
  if (code <= 3) return 'Berawan';
  if (code == 45 || code == 48) return 'Berkabut';
  if (code >= 51 && code <= 57) return 'Gerimis';
  if (code >= 61 && code <= 67) return 'Hujan';
  if (code >= 71 && code <= 77) return 'Salju';
  if (code >= 80 && code <= 82) return 'Hujan lebat';
  if (code >= 95) return 'Badai petir';
  return 'Tidak diketahui';
}