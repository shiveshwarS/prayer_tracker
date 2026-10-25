import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/saved_location.dart';

enum LocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  timeout,
  unavailable,
}

class LocationResult {
  const LocationResult._({this.location, this.failure});

  const LocationResult.success(SavedLocation location)
    : this._(location: location);

  const LocationResult.failure(LocationFailure failure)
    : this._(failure: failure);

  final SavedLocation? location;
  final LocationFailure? failure;

  bool get isSuccess => location != null;
}

class LocationService {
  const LocationService();

  Future<LocationResult> requestCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult.failure(LocationFailure.serviceDisabled);
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const LocationResult.failure(LocationFailure.permissionDenied);
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(
          LocationFailure.permissionPermanentlyDenied,
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );

      final SavedLocation location = SavedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        label: 'Current location',
        source: LocationSource.device,
      );
      if (!location.isValid) {
        return const LocationResult.failure(LocationFailure.unavailable);
      }
      return LocationResult.success(location);
    } on LocationServiceDisabledException {
      return const LocationResult.failure(LocationFailure.serviceDisabled);
    } on PermissionDeniedException {
      return const LocationResult.failure(LocationFailure.permissionDenied);
    } on TimeoutException {
      return const LocationResult.failure(LocationFailure.timeout);
    } on Object {
      return const LocationResult.failure(LocationFailure.unavailable);
    }
  }

  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } on Object {
      return false;
    }
  }

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } on Object {
      return false;
    }
  }
}
