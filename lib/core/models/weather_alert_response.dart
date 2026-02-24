class WeatherAlert {
  final String id;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime issuedTime;
  final DateTime expiresTime;
  final String severity; // Critical, Severe, Moderate, Minor
  final String? source;
  final String? eventType;

  WeatherAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.issuedTime,
    required this.expiresTime,
    required this.severity,
    this.source,
    this.eventType,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      issuedTime: json['issued_time'] != null
          ? DateTime.parse(json['issued_time'] as String)
          : DateTime.now(),
      expiresTime: json['expires_time'] != null
          ? DateTime.parse(json['expires_time'] as String)
          : DateTime.now().add(const Duration(days: 1)),
      severity: json['severity'] as String? ?? 'Moderate',
      source: json['source'] as String?,
      eventType: json['event_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'issued_time': issuedTime.toIso8601String(),
      'expires_time': expiresTime.toIso8601String(),
      'severity': severity,
      'source': source,
      'event_type': eventType,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresTime);

  String get timeRemaining {
    final duration = expiresTime.difference(DateTime.now());
    if (duration.isNegative) return 'Expired';
    if (duration.inHours > 0) return 'Until ${duration.inHours}h';
    return 'Until ${duration.inMinutes}m';
  }
}
