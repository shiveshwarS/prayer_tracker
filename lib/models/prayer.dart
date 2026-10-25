enum PrayerId {
  fajr('Fajr', 'Dawn'),
  dhuhr('Dhuhr', 'Midday'),
  asr('Asr', 'Afternoon'),
  maghrib('Maghrib', 'Sunset'),
  isha('Isha', 'Night');

  const PrayerId(this.label, this.translation);

  final String label;
  final String translation;

  static PrayerId? fromStorage(String? value) {
    for (final PrayerId prayer in PrayerId.values) {
      if (prayer.name == value) {
        return prayer;
      }
    }
    return null;
  }
}
