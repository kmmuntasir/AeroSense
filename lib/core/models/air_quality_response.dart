class AirQualityResponse {
  final int? usAqi;

  AirQualityResponse({this.usAqi});

  factory AirQualityResponse.fromJson(Map<String, dynamic> json) {
    return AirQualityResponse(
      usAqi: (json['current']?['us_aqi'] as num?)?.toInt(),
    );
  }
}
