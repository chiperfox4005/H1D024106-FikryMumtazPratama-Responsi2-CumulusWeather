class LocationModel {
  final int id;
  final String name;
  final String country;
  final String admin1;
  final double latitude;
  final double longitude;

  const LocationModel({
    required this.id,
    required this.name,
    required this.country,
    required this.admin1,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      admin1: (json['admin1'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get subtitle {
    if (admin1.isNotEmpty && country.isNotEmpty) {
      return '$admin1, $country';
    }
    if (country.isNotEmpty) {
      return country;
    }
    return admin1;
  }

  bool isSameAs(LocationModel other) {
    if (id != 0 && other.id != 0) {
      return id == other.id;
    }
    return latitude == other.latitude && longitude == other.longitude;
  }
}
