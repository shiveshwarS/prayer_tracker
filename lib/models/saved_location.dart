enum LocationSource {
  device,
  manual;

  static LocationSource fromStorage(String? value) {
    return value == device.name ? device : manual;
  }
}

class SavedLocation {
  const SavedLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.source,
  });

  final double latitude;
  final double longitude;
  final String label;
  final LocationSource source;

  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'latitude': latitude,
    'longitude': longitude,
    'label': label,
    'source': source.name,
  };

  static SavedLocation? fromJson(Object? value) {
    if (value is! Map) {
      return null;
    }
    final Object? latitude = value['latitude'];
    final Object? longitude = value['longitude'];
    final Object? label = value['label'];
    final Object? source = value['source'];
    if (latitude is! num || longitude is! num) {
      return null;
    }
    final SavedLocation location = SavedLocation(
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      label:
          label is String && label.trim().isNotEmpty
              ? label.trim()
              : 'Saved location',
      source: LocationSource.fromStorage(source is String ? source : null),
    );
    return location.isValid ? location : null;
  }
}
