class LocationModel {
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  const LocationModel({
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    name: json['name'] ?? '',
    country: json['country'] ?? '',
    admin1: json['admin1'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'country': country,
    'admin1': admin1,
    'latitude': latitude,
    'longitude': longitude,
  };

  String get label => [name, admin1, country]
      .where((e) => e != null && e.isNotEmpty)
      .join(', ');

  @override
  bool operator ==(Object other) =>
      other is LocationModel &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}