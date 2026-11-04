import '../utils/date_utils.dart';
import 'local_storage_service.dart';

/// Remembers which gentle delight moments have already been shown.
///
/// This is deliberately a small view-support service: it never stores prayer
/// completion or streak data, and animations never decide whether a streak is
/// valid.
class CelebrationMemory {
  CelebrationMemory(this._storage);

  final LocalStorageService _storage;

  bool _initialized = false;
  bool _welcomeSeen = false;
  Set<String> _celebratedMilestones = <String>{};

  bool get welcomeSeen => _welcomeSeen;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _welcomeSeen = await _storage.loadWelcomeSeen();
    _celebratedMilestones = await _storage.loadCelebratedMilestones();
    _initialized = true;
  }

  Future<void> markWelcomeSeen() async {
    if (_welcomeSeen) {
      return;
    }
    _welcomeSeen = true;
    await _storage.saveWelcomeSeen();
  }

  bool hasCelebratedMilestone(String key) {
    return _celebratedMilestones.contains(key);
  }

  Future<void> markMilestoneCelebrated(String key) async {
    if (!_celebratedMilestones.add(key)) {
      return;
    }
    await _storage.saveCelebratedMilestones(_celebratedMilestones);
  }

  void resetLocal() {
    _welcomeSeen = false;
    _celebratedMilestones = <String>{};
  }

  static String milestoneKey(int streak, DateTime date) {
    return 'milestone:$streak:${AppDate.dateKey(date)}';
  }
}
