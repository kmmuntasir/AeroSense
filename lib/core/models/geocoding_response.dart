class GeocodingResponse {
  final List<GeocodingResult> results;
  final double? generationtimeMs;
  final int? resultsCount;

  GeocodingResponse({
    required this.results,
    this.generationtimeMs,
    this.resultsCount,
  });

  factory GeocodingResponse.fromJson(Map<String, dynamic> json) {
    return GeocodingResponse(
      results: (json['results'] as List?)
          ?.map((e) => GeocodingResult.fromJson(e))
          .toList() ??
          [],
      generationtimeMs: (json['generationtime_ms'] as num?)?.toDouble(),
      resultsCount: json['results_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'generationtime_ms': generationtimeMs,
      'results_count': resultsCount,
    };
  }
}

class GeocodingResult {
  final double latitude;
  final double longitude;
  final String name;
  final String country;
  final String countryCode;
  final String? state;
  final String? stateCode;
  final List<String>? admin1;
  final List<String>? admin2;
  final List<String>? admin3;
  final List<String>? admin4;
  final double? elevation;
  final int? timezone;
  final String? timezoneAbbreviation;
  final double? utcOffsetSeconds;

  GeocodingResult({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.country,
    required this.countryCode,
    this.state,
    this.stateCode,
    this.admin1,
    this.admin2,
    this.admin3,
    this.admin4,
    this.elevation,
    this.timezone,
    this.timezoneAbbreviation,
    this.utcOffsetSeconds,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
      state: json['state'],
      stateCode: json['state_code'],
      admin1: json['admin1']?.cast<String>(),
      admin2: json['admin2']?.cast<String>(),
      admin3: json['admin3']?.cast<String>(),
      admin4: json['admin4']?.cast<String>(),
      elevation: (json['elevation'] as num?)?.toDouble(),
      timezone: json['timezone'] as int?,
      timezoneAbbreviation: json['timezone_abbreviation'],
      utcOffsetSeconds: (json['utc_offset_seconds'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'country': country,
      'country_code': countryCode,
      'state': state,
      'state_code': stateCode,
      'admin1': admin1,
      'admin2': admin2,
      'admin3': admin3,
      'admin4': admin4,
      'elevation': elevation,
      'timezone': timezone,
      'timezone_abbreviation': timezoneAbbreviation,
      'utc_offset_seconds': utcOffsetSeconds,
    };
  }

  String get formattedLocation {
    final parts = [name];
    if (state?.isNotEmpty == true) parts.add(state!);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }
}