import 'package:flutter/foundation.dart';

import '../models/prayer.dart';
import '../models/prayer_history.dart';
import '../models/streak_summary.dart';
import '../services/local_storage_service.dart';
import '../utils/date_utils.dart';

class PrayerController extends ChangeNotifier {
  PrayerController({
    required LocalStorageService storage,
    DateTime Function()? clock,
  }) : _storage = storage,
       _clock = clock ?? DateTime.now;

  final LocalStorageService _storage;
  final DateTime Function() _clock;

  PrayerHistory _history = PrayerHistory.empty();
  bool _isInitialized = false;
  String _activeDateKey = '';
  Future<void> _writeQueue = Future<void>.value();
  bool _persistenceFailed = false;

  PrayerHistory get history => _history;
  bool get isInitialized => _isInitialized;
  bool get persistenceFailed => _persistenceFailed;

  DateTime get today => AppDate.dateOnly(_clock());

  StreakSummary get summary =>
      StreakSummary.fromHistory(_history, today: today);

  int get currentStreak => _history.currentStreak(today: today);

  int get longestStreak => _history.longestStreak;

  int get totalSuccessfulDays => _history.totalSuccessfulDays;

  bool get isTodayComplete => _history.isDayComplete(today);

  int get todayCompleted => _history.completedCount(today);

  bool isCompleted(PrayerId prayer) =>
      _history.isPrayerCompleted(today, prayer);

  bool isDayComplete(DateTime date) => _history.isDayComplete(date);

  int completedCountFor(DateTime date) => _history.completedCount(date);

  Set<PrayerId> completedFor(DateTime date) => _history.completedForDate(date);

  Future<void> initialize() async {
    try {
      _history = await _storage.loadHistory();
    } on Object {
      _history = PrayerHistory.empty();
    }
    _activeDateKey = AppDate.dateKey(today);
    _isInitialized = true;
    notifyListeners();
  }

  /// Returns true when the prayer is now completed.
  bool togglePrayer(PrayerId prayer) {
    final bool completed = _history.toggle(today, prayer);
    _activeDateKey = AppDate.dateKey(today);
    notifyListeners();
    _schedulePersist();
    return completed;
  }

  void refreshToday() {
    final String key = AppDate.dateKey(today);
    if (key != _activeDateKey) {
      _activeDateKey = key;
      notifyListeners();
    }
  }

  void _schedulePersist() {
    final PrayerHistory snapshot = PrayerHistory.fromJson(_history.toJson());
    _writeQueue = _writeQueue
        .then((_) => _storage.saveHistory(snapshot))
        .catchError((Object _) {
          _persistenceFailed = true;
        });
  }

  Future<void> flush() => _writeQueue;

  void clearLocal() {
    _history.clear();
    _persistenceFailed = false;
    notifyListeners();
  }
}
