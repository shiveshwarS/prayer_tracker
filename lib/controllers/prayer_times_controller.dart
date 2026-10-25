import 'package:flutter/foundation.dart';

import '../models/prayer.dart';
import '../models/prayer_settings.dart';
import '../models/prayer_times.dart';
import '../models/saved_location.dart';
import '../services/local_storage_service.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';
import '../utils/date_utils.dart';

class PrayerTimesController extends ChangeNotifier {
  PrayerTimesController({
    required PrayerTimeService prayerTimeService,
    required LocationService locationService,
    required LocalStorageService storage,
    DateTime Function()? clock,
  }) : _prayerTimeService = prayerTimeService,
       _locationService = locationService,
       _storage = storage,
       _clock = clock ?? DateTime.now;

  final PrayerTimeService _prayerTimeService;
  final LocationService _locationService;
  final LocalStorageService _storage;
  final DateTime Function() _clock;

  PrayerSettings _settings = const PrayerSettings();
  PrayerTimesForDay? _times;
  bool _isInitializing = true;
  bool _isLocating = false;
  LocationFailure? _locationFailure;
  String? _calculationError;
  String? _settingsError;
  DateTime? _calculatedDate;

  PrayerSettings get settings => _settings;
  SavedLocation? get location => _settings.location;
  PrayerCalculationMethod get method => _settings.method;
  AsrMadhab get madhab => _settings.madhab;
  PrayerTimesForDay? get times => _times;
  bool get isInitializing => _isInitializing;
  bool get isLocating => _isLocating;
  LocationFailure? get locationFailure => _locationFailure;
  String? get calculationError => _calculationError;
  String? get settingsError => _settingsError;
  DateTime? get calculatedDate => _calculatedDate;

  bool get hasLocation => _settings.location != null;
  bool get hasTimes => _times?.isComplete ?? false;
  bool get needsLocation => _settings.location == null;

  DateTime? timeFor(PrayerId prayer) => _times?.timeFor(prayer);

  NextPrayerInfo? get nextPrayer {
    final PrayerTimesForDay? times = _times;
    if (times == null) {
      return null;
    }
    return _prayerTimeService.nextPrayer(times: times, now: _clock());
  }

  Future<void> initialize() async {
    _isInitializing = true;
    try {
      _settings = await _storage.loadPrayerSettings();
    } on Object {
      _settings = const PrayerSettings();
    }
    _recalculate();
    _isInitializing = false;
    notifyListeners();
  }

  Future<LocationFailure?> useCurrentLocation() async {
    if (_isLocating) {
      return null;
    }
    _isLocating = true;
    _locationFailure = null;
    _settingsError = null;
    notifyListeners();

    final LocationResult result =
        await _locationService.requestCurrentLocation();
    if (result.location == null) {
      _isLocating = false;
      _locationFailure = result.failure ?? LocationFailure.unavailable;
      notifyListeners();
      return _locationFailure;
    }

    _settings = _settings.copyWith(location: result.location);
    _locationFailure = null;
    _recalculate();
    _isLocating = false;
    notifyListeners();
    await _persistSettings();
    return null;
  }

  Future<void> setManualLocation(SavedLocation location) async {
    if (!location.isValid) {
      return;
    }
    _settings = _settings.copyWith(location: location);
    _locationFailure = null;
    _settingsError = null;
    _recalculate();
    notifyListeners();
    await _persistSettings();
  }

  Future<void> setMethod(PrayerCalculationMethod method) async {
    if (_settings.method == method) {
      return;
    }
    _settings = _settings.copyWith(method: method);
    _recalculate();
    notifyListeners();
    await _persistSettings();
  }

  Future<void> setMadhab(AsrMadhab madhab) async {
    if (_settings.madhab == madhab) {
      return;
    }
    _settings = _settings.copyWith(madhab: madhab);
    _recalculate();
    notifyListeners();
    await _persistSettings();
  }

  Future<void> clearLocation() async {
    _settings = _settings.copyWith(clearLocation: true);
    _locationFailure = null;
    _settingsError = null;
    _recalculate();
    notifyListeners();
    await _persistSettings();
  }

  void refreshForToday() {
    final DateTime today = AppDate.dateOnly(_clock());
    if (_calculatedDate == null || !AppDate.sameDay(_calculatedDate!, today)) {
      _recalculate();
      notifyListeners();
    }
  }

  void clearLocationFailure() {
    if (_locationFailure == null) {
      return;
    }
    _locationFailure = null;
    notifyListeners();
  }

  Future<bool> openAppSettings() => _locationService.openAppSettings();

  Future<bool> openLocationSettings() =>
      _locationService.openLocationSettings();

  void _recalculate() {
    final SavedLocation? location = _settings.location;
    if (location == null) {
      _times = null;
      _calculatedDate = null;
      _calculationError = null;
      return;
    }

    final DateTime today = AppDate.dateOnly(_clock());
    _times = _prayerTimeService.calculateForDay(
      location: location,
      date: today,
      method: _settings.method,
      madhab: _settings.madhab,
    );
    _calculatedDate = today;
    _calculationError =
        _times == null
            ? 'Prayer times are unavailable for this location. Try another location or calculation method.'
            : null;
  }

  Future<void> _persistSettings() async {
    try {
      await _storage.savePrayerSettings(_settings);
      if (_settingsError != null) {
        _settingsError = null;
        notifyListeners();
      }
    } on Object {
      _settingsError = 'Prayer settings could not be saved on this device.';
      notifyListeners();
    }
  }

  void resetLocal() {
    _settings = const PrayerSettings();
    _times = null;
    _isLocating = false;
    _locationFailure = null;
    _calculationError = null;
    _settingsError = null;
    _calculatedDate = null;
    notifyListeners();
  }
}
