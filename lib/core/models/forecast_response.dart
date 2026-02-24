class ForecastResponse {
  final double latitude;
  final double longitude;
  final String timezone;
  final HourlyForecast hourly;
  final DailyForecast daily;
  final CurrentWeather current;

  ForecastResponse({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.hourly,
    required this.daily,
    required this.current,
  });

  factory ForecastResponse.fromJson(Map<String, dynamic> json) {
    return ForecastResponse(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String? ?? 'UTC',
      hourly: HourlyForecast.fromJson(
        json['hourly'] as Map<String, dynamic>? ?? {},
      ),
      daily: DailyForecast.fromJson(
        json['daily'] as Map<String, dynamic>? ?? {},
      ),
      current: CurrentWeather.fromJson(
        json['current'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'hourly': hourly.toJson(),
      'daily': daily.toJson(),
      'current': current.toJson(),
    };
  }
}

class CurrentWeather {
  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final double windSpeed;
  final double windDirection;

  CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: json['time'] != null
          ? DateTime.parse(json['time'] as String)
          : DateTime.now(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      windDirection: (json['wind_direction_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'apparent_temperature': apparentTemperature,
      'weather_code': weatherCode,
      'wind_speed_10m': windSpeed,
      'wind_direction_10m': windDirection,
    };
  }
}

class HourlyForecast {
  final List<DateTime> times;
  final List<double> temperatures;
  final List<double> apparentTemperatures;
  final List<int> weatherCodes;
  final List<double> precipitationProbabilities;
  final List<double> windSpeeds;
  final List<int> relativeHumidities;
  final List<double> pressures;
  final List<double> uvIndices;
  final List<double> visibilities;

  HourlyForecast({
    required this.times,
    required this.temperatures,
    required this.apparentTemperatures,
    required this.weatherCodes,
    required this.precipitationProbabilities,
    required this.windSpeeds,
    required this.relativeHumidities,
    required this.pressures,
    required this.uvIndices,
    required this.visibilities,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final timeList = (json['time'] as List?)?.cast<String>() ?? [];
    final tempList = (json['temperature_2m'] as List?)?.cast<num>() ?? [];
    final apparentTempList =
        (json['apparent_temperature'] as List?)?.cast<num>() ?? [];
    final weatherCodeList = (json['weather_code'] as List?)?.cast<num>() ?? [];
    final precipProbList =
        (json['precipitation_probability'] as List?)?.cast<num>() ?? [];
    final windSpeedList = (json['wind_speed_10m'] as List?)?.cast<num>() ?? [];
    final humidityList =
        (json['relative_humidity_2m'] as List?)?.cast<num>() ?? [];
    final pressureList = (json['pressure_msl'] as List?)?.cast<num>() ?? [];
    final uvIndexList = (json['uv_index'] as List?)?.cast<num>() ?? [];
    final visibilityList = (json['visibility'] as List?)?.cast<num>() ?? [];

    return HourlyForecast(
      times: timeList.map((t) => DateTime.parse(t)).toList(),
      temperatures: tempList.map((t) => t.toDouble()).toList(),
      apparentTemperatures: apparentTempList.map((t) => t.toDouble()).toList(),
      weatherCodes: weatherCodeList.map((w) => w.toInt()).toList(),
      precipitationProbabilities: precipProbList
          .map((p) => p.toDouble())
          .toList(),
      windSpeeds: windSpeedList.map((w) => w.toDouble()).toList(),
      relativeHumidities: humidityList.map((h) => h.toInt()).toList(),
      pressures: pressureList.map((p) => p.toDouble()).toList(),
      uvIndices: uvIndexList.map((u) => u.toDouble()).toList(),
      visibilities: visibilityList.map((v) => v.toDouble()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': times.map((t) => t.toIso8601String()).toList(),
      'temperature_2m': temperatures,
      'apparent_temperature': apparentTemperatures,
      'weather_code': weatherCodes,
      'precipitation_probability': precipitationProbabilities,
      'wind_speed_10m': windSpeeds,
      'relative_humidity_2m': relativeHumidities,
      'pressure_msl': pressures,
      'uv_index': uvIndices,
      'visibility': visibilities,
    };
  }

  /// Get hourly forecast for next N hours
  List<HourlyData> getHoursAhead(int hours) {
    final result = <HourlyData>[];
    for (int i = 0; i < hours && i < times.length; i++) {
      result.add(
        HourlyData(
          time: times[i],
          temperature: temperatures[i],
          apparentTemperature: apparentTemperatures[i],
          weatherCode: weatherCodes[i],
          precipitationProbability: precipitationProbabilities[i],
          windSpeed: windSpeeds[i],
          relativeHumidity: relativeHumidities[i],
          pressure: pressures[i],
          uvIndex: i < uvIndices.length ? uvIndices[i] : 0.0,
          visibility: i < visibilities.length ? visibilities[i] : 10000.0,
        ),
      );
    }
    return result;
  }
}

class HourlyData {
  final DateTime time;
  final double temperature;
  final double apparentTemperature;
  final int weatherCode;
  final double precipitationProbability;
  final double windSpeed;
  final int relativeHumidity;
  final double pressure;
  final double uvIndex;
  final double visibility;

  HourlyData({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.relativeHumidity,
    required this.pressure,
    this.uvIndex = 0.0,
    this.visibility = 10000.0,
  });

  String get formattedTime =>
      '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}

class DailyForecast {
  final List<DateTime> dates;
  final List<double> maxTemperatures;
  final List<double> minTemperatures;
  final List<int> weatherCodes;
  final List<double> precipitationSums;
  final List<int> precipitationProbabilities;
  final List<double> windSpeeds;

  DailyForecast({
    required this.dates,
    required this.maxTemperatures,
    required this.minTemperatures,
    required this.weatherCodes,
    required this.precipitationSums,
    required this.precipitationProbabilities,
    required this.windSpeeds,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final dateList = (json['time'] as List?)?.cast<String>() ?? [];
    final maxTempList =
        (json['temperature_2m_max'] as List?)?.cast<num>() ?? [];
    final minTempList =
        (json['temperature_2m_min'] as List?)?.cast<num>() ?? [];
    final weatherCodeList = (json['weather_code'] as List?)?.cast<num>() ?? [];
    final precipSumList =
        (json['precipitation_sum'] as List?)?.cast<num>() ?? [];
    final precipProbList =
        (json['precipitation_probability_max'] as List?)?.cast<num>() ?? [];
    final windSpeedList =
        (json['wind_speed_10m_max'] as List?)?.cast<num>() ?? [];

    return DailyForecast(
      dates: dateList.map((d) => DateTime.parse(d)).toList(),
      maxTemperatures: maxTempList.map((t) => t.toDouble()).toList(),
      minTemperatures: minTempList.map((t) => t.toDouble()).toList(),
      weatherCodes: weatherCodeList.map((w) => w.toInt()).toList(),
      precipitationSums: precipSumList.map((p) => p.toDouble()).toList(),
      precipitationProbabilities: precipProbList.map((p) => p.toInt()).toList(),
      windSpeeds: windSpeedList.map((w) => w.toDouble()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': dates.map((d) => d.toIso8601String()).toList(),
      'temperature_2m_max': maxTemperatures,
      'temperature_2m_min': minTemperatures,
      'weather_code': weatherCodes,
      'precipitation_sum': precipitationSums,
      'precipitation_probability_max': precipitationProbabilities,
      'wind_speed_10m_max': windSpeeds,
    };
  }

  /// Get daily forecast for next N days
  List<DailyData> getDaysAhead(int days) {
    final result = <DailyData>[];
    for (int i = 0; i < days && i < dates.length; i++) {
      result.add(
        DailyData(
          date: dates[i],
          maxTemperature: maxTemperatures[i],
          minTemperature: minTemperatures[i],
          weatherCode: weatherCodes[i],
          precipitationSum: precipitationSums[i],
          precipitationProbability: precipitationProbabilities[i],
          windSpeed: windSpeeds[i],
        ),
      );
    }
    return result;
  }
}

class DailyData {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;
  final double precipitationSum;
  final int precipitationProbability;
  final double windSpeed;

  DailyData({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
    required this.precipitationSum,
    required this.precipitationProbability,
    required this.windSpeed,
  });

  String get formattedDate => '${date.month}/${date.day}';
}
