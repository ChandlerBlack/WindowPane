class PhotoEntry {
  final int? id;
  final String imagePath;
  final String description;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String address;
  final double temperature;
  final String weatherCondition;

  PhotoEntry({
    this.id,
    required this.imagePath,
    required this.description,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.temperature,
    required this.weatherCondition,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'temperature': temperature,
      'weatherCondition': weatherCondition,
    };
  }

  factory PhotoEntry.fromMap(Map<String, dynamic> map) {
    return PhotoEntry(
      id: map['id'],
      imagePath: map['imagePath'],
      description: map['description'],
      timestamp: DateTime.parse(map['timestamp']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      temperature: map['temperature'],
      weatherCondition: map['weatherCondition'],
    );
  }
}