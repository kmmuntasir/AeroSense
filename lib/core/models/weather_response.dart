class WeatherResponse {
  final double latitude;
  final double longitude;
  final double elevation;
  final CurrentWeather current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  WeatherResponse({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      elevation: json['elevation']?.toDouble() ?? 0.0,
      current: CurrentWeather.fromJson(json['current'] ?? {}),
      hourly:
          (json['hourly']?['time'] as List?)
              ?.asMap()
              .entries
              .map(
                (entry) => HourlyWeather(
                  time: DateTime.parse(json['hourly']['time'][entry.key]),
                  temperature2M:
                      (json['hourly']['temperature_2m'][entry.key] as num?)
                          ?.toDouble(),
                  relativeHumidity2M:
                      (json['hourly']['relative_humidity_2m'][entry.key]
                              as num?)
                          ?.toDouble(),
                  windSpeed10M:
                      (json['hourly']['wind_speed_10m'][entry.key] as num?)
                          ?.toDouble(),
                  windDirection10M:
                      (json['hourly']['wind_direction_10m'][entry.key] as num?)
                          ?.toDouble(),
                  precipitation:
                      (json['hourly']['precipitation'][entry.key] as num?)
                          ?.toDouble(),
                  weatherCode:
                      json['hourly']['weather_code'][entry.key] as int?,
                ),
              )
              .toList() ??
          [],
      daily:
          (json['daily']?['time'] as List?)
              ?.asMap()
              .entries
              .map(
                (entry) => DailyWeather(
                  date: DateTime.parse(json['daily']['time'][entry.key]),
                  maxTemperature2M:
                      (json['daily']['temperature_2m_max'][entry.key] as num?)
                          ?.toDouble(),
                  minTemperature2M:
                      (json['daily']['temperature_2m_min'][entry.key] as num?)
                          ?.toDouble(),
                  precipitationSum:
                      (json['daily']['precipitation_sum'][entry.key] as num?)
                          ?.toDouble(),
                  weatherCode: json['daily']['weather_code'][entry.key] as int?,
                  sunrise: json['daily']['sunrise'][entry.key] != null
                      ? DateTime.parse(json['daily']['sunrise'][entry.key])
                      : null,
                  sunset: json['daily']['sunset'][entry.key] != null
                      ? DateTime.parse(json['daily']['sunset'][entry.key])
                      : null,
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'current': current.toJson(),
      'hourly': {
        'time': hourly.map((h) => h.time.toIso8601String()).toList(),
        'temperature_2m': hourly.map((h) => h.temperature2M).toList(),
        'relative_humidity_2m': hourly
            .map((h) => h.relativeHumidity2M)
            .toList(),
        'wind_speed_10m': hourly.map((h) => h.windSpeed10M).toList(),
        'wind_direction_10m': hourly.map((h) => h.windDirection10M).toList(),
        'precipitation': hourly.map((h) => h.precipitation).toList(),
        'weather_code': hourly.map((h) => h.weatherCode).toList(),
      },
      'daily': {
        'time': daily.map((d) => d.date.toIso8601String()).toList(),
        'temperature_2m_max': daily.map((d) => d.maxTemperature2M).toList(),
        'temperature_2m_min': daily.map((d) => d.minTemperature2M).toList(),
        'precipitation_sum': daily.map((d) => d.precipitationSum).toList(),
        'weather_code': daily.map((d) => d.weatherCode).toList(),
        'sunrise': daily.map((d) => d.sunrise?.toIso8601String()).toList(),
        'sunset': daily.map((d) => d.sunset?.toIso8601String()).toList(),
      },
    };
  }
}

class CurrentWeather {
  final DateTime time;
  final double? temperature2M;
  final double? relativeHumidity2M;
  final double? windSpeed10M;
  final double? windDirection10M;
  final int? weatherCode;
  final double? precipitation;

  CurrentWeather({
    required this.time,
    this.temperature2M,
    this.relativeHumidity2M,
    this.windSpeed10M,
    this.windDirection10M,
    this.weatherCode,
    this.precipitation,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      temperature2M: (json['temperature_2m'] as num?)?.toDouble(),
      relativeHumidity2M: (json['relative_humidity_2m'] as num?)?.toDouble(),
      windSpeed10M: (json['wind_speed_10m'] as num?)?.toDouble(),
      windDirection10M: (json['wind_direction_10m'] as num?)?.toDouble(),
      weatherCode: json['weather_code'] as int?,
      precipitation: (json['precipitation'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature_2m': temperature2M,
      'relative_humidity_2m': relativeHumidity2M,
      'wind_speed_10m': windSpeed10M,
      'wind_direction_10m': windDirection10M,
      'weather_code': weatherCode,
      'precipitation': precipitation,
    };
  }
}

class HourlyWeather {
  final DateTime time;
  final double? temperature2M;
  final double? relativeHumidity2M;
  final double? windSpeed10M;
  final double? windDirection10M;
  final double? precipitation;
  final int? weatherCode;

  HourlyWeather({
    required this.time,
    this.temperature2M,
    this.relativeHumidity2M,
    this.windSpeed10M,
    this.windDirection10M,
    this.precipitation,
    this.weatherCode,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      temperature2M: (json['temperature_2m'] as num?)?.toDouble(),
      relativeHumidity2M: (json['relative_humidity_2m'] as num?)?.toDouble(),
      windSpeed10M: (json['wind_speed_10m'] as num?)?.toDouble(),
      windDirection10M: (json['wind_direction_10m'] as num?)?.toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble(),
      weatherCode: json['weather_code'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature_2m': temperature2M,
      'relative_humidity_2m': relativeHumidity2M,
      'wind_speed_10m': windSpeed10M,
      'wind_direction_10m': windDirection10M,
      'precipitation': precipitation,
      'weather_code': weatherCode,
    };
  }
}

class DailyWeather {
  final DateTime date;
  final double? maxTemperature2M;
  final double? minTemperature2M;
  final double? precipitationSum;
  final int? weatherCode;
  final DateTime? sunrise;
  final DateTime? sunset;

  DailyWeather({
    required this.date,
    this.maxTemperature2M,
    this.minTemperature2M,
    this.precipitationSum,
    this.weatherCode,
    this.sunrise,
    this.sunset,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      maxTemperature2M: (json['max_temperature_2m'] as num?)?.toDouble(),
      minTemperature2M: (json['min_temperature_2m'] as num?)?.toDouble(),
      precipitationSum: (json['precipitation_sum'] as num?)?.toDouble(),
      weatherCode: json['weather_code'] as int?,
      sunrise: json['sunrise'] != null ? DateTime.parse(json['sunrise']) : null,
      sunset: json['sunset'] != null ? DateTime.parse(json['sunset']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'max_temperature_2m': maxTemperature2M,
      'min_temperature_2m': minTemperature2M,
      'precipitation_sum': precipitationSum,
      'weather_code': weatherCode,
      'sunrise': sunrise?.toIso8601String(),
      'sunset': sunset?.toIso8601String(),
    };
  }
}
