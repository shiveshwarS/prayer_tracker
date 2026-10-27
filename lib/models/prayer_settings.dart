import 'saved_location.dart';

enum PrayerCalculationMethod {
  muslimWorldLeague('Muslim World League'),
  karachi('University of Islamic Sciences, Karachi'),
  ummAlQura('Umm al-Qura, Makkah'),
  egyptian('Egyptian General Authority'),
  dubai('Dubai'),
  northAmerica('North America (ISNA)'),
  moonsightingCommittee('Moonsighting Committee'),
  singapore('Singapore'),
  turkiye('Diyanet, Türkiye');

  const PrayerCalculationMethod(this.label);

  final String label;

  static PrayerCalculationMethod fromStorage(String? value) {
    for (final PrayerCalculationMethod method
        in PrayerCalculationMethod.values) {
      if (method.name == value) {
        return method;
      }
    }
    return PrayerCalculationMethod.muslimWorldLeague;
  }
}

enum AsrMadhab {
  shafi('Standard (Shafi)'),
  hanafi('Hanafi');

  const AsrMadhab(this.label);

  final String label;

  static AsrMadhab fromStorage(String? value) {
    return value == hanafi.name ? hanafi : shafi;
  }
}

enum AppThemePreference {
  system('System'),
  light('Light'),
  dark('Dark');

  const AppThemePreference(this.label);

  final String label;

  static AppThemePreference fromStorage(String? value) {
    for (final AppThemePreference preference in AppThemePreference.values) {
      if (preference.name == value) {
        return preference;
      }
    }
    return AppThemePreference.system;
  }
}

class PrayerAlarmConfig {
  const PrayerAlarmConfig({
    this.enabled = true,
    this.useCustomSound = false,
  });

  final bool enabled;
  final bool useCustomSound;

  PrayerAlarmConfig copyWith({bool? enabled, bool? useCustomSound}) {
    return PrayerAlarmConfig(
      enabled: enabled ?? this.enabled,
      useCustomSound: useCustomSound ?? this.useCustomSound,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'enabled': enabled,
        'useCustomSound': useCustomSound,
      };

  static PrayerAlarmConfig fromJson(Object? value) {
    if (value is! Map) {
      return const PrayerAlarmConfig();
    }
    return PrayerAlarmConfig(
      enabled: value['enabled'] is bool ? value['enabled']! as bool : true,
      useCustomSound:
          value['useCustomSound'] is bool ? value['useCustomSound']! as bool : false,
    );
  }
}

class PrayerSettings {
  const PrayerSettings({
    this.location,
    this.method = PrayerCalculationMethod.muslimWorldLeague,
    this.madhab = AsrMadhab.shafi,
    this.alarm = const PrayerAlarmConfig(),
  });

  final SavedLocation? location;
  final PrayerCalculationMethod method;
  final AsrMadhab madhab;
  final PrayerAlarmConfig alarm;

  PrayerSettings copyWith({
    SavedLocation? location,
    bool clearLocation = false,
    PrayerCalculationMethod? method,
    AsrMadhab? madhab,
    PrayerAlarmConfig? alarm,
  }) {
    return PrayerSettings(
      location: clearLocation ? null : (location ?? this.location),
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
      alarm: alarm ?? this.alarm,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'location': location?.toJson(),
        'method': method.name,
        'madhab': madhab.name,
        'alarm': alarm.toJson(),
      };

  static PrayerSettings fromJson(Object? value) {
    if (value is! Map) {
      return const PrayerSettings();
    }
    return PrayerSettings(
      location: SavedLocation.fromJson(value['location']),
      method: PrayerCalculationMethod.fromStorage(
        value['method'] is String ? value['method']! as String : null,
      ),
      madhab: AsrMadhab.fromStorage(
        value['madhab'] is String ? value['madhab']! as String : null,
      ),
      alarm: PrayerAlarmConfig.fromJson(value['alarm']),
    );
  }
}
