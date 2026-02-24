class GeocodingResponse {
  final List<GeocodingResult> results;
  final double? generationtimeMs;

  GeocodingResponse({required this.results, this.generationtimeMs});

  factory GeocodingResponse.fromJson(Map<String, dynamic> json) {
    return GeocodingResponse(
      results:
          (json['results'] as List?)
              ?.map((e) => GeocodingResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      generationtimeMs: (json['generationtime_ms'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'generationtime_ms': generationtimeMs,
    };
  }
}

class GeocodingResult {
  final int? id;
  final double latitude;
  final double longitude;
  final String name;
  final String country;
  final String countryCode;
  // admin1 is the state/province returned by Open-Meteo (e.g. "England")
  final String? admin1;
  final String? admin2;
  final String? admin3;
  final String? admin4;
  final double? elevation;
  // Timezone IANA name, e.g. "Europe/London"
  final String? timezone;
  final double? utcOffsetSeconds;

  GeocodingResult({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.country,
    required this.countryCode,
    this.admin1,
    this.admin2,
    this.admin3,
    this.admin4,
    this.elevation,
    this.timezone,
    this.utcOffsetSeconds,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      id: json['id'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '',
      admin1: json['admin1'] as String?,
      admin2: json['admin2'] as String?,
      admin3: json['admin3'] as String?,
      admin4: json['admin4'] as String?,
      elevation: (json['elevation'] as num?)?.toDouble(),
      timezone: json['timezone'] as String?,
      utcOffsetSeconds: (json['utc_offset_seconds'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'country': country,
      'country_code': countryCode,
      'admin1': admin1,
      'admin2': admin2,
      'admin3': admin3,
      'admin4': admin4,
      'elevation': elevation,
      'timezone': timezone,
      'utc_offset_seconds': utcOffsetSeconds,
    };
  }

  /// "London, England, United Kingdom" — uses admin1 as the state/province.
  String get formattedLocation {
    final parts = [name];
    if (admin1?.isNotEmpty == true) parts.add(admin1!);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }
}
