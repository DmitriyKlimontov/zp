import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WorkCalendar {
  static const String _prefKey = 'work_calendar_data';

  // ── Встроенные нормы (константы) ─────────────────────────────
  // Ключи: year → monthName → weekHours ('40'|'36'|'24') → hours
  static const Map<int, Map<String, Map<String, double>>> _defaults = {
    2024: {
      'Январь': {'40': 136.0, '36': 122.4, '24': 81.6},
      'Февраль': {'40': 159.0, '36': 143.0, '24': 95.0},
      'Март': {'40': 159.0, '36': 143.0, '24': 95.0},
      'Апрель': {'40': 168.0, '36': 152.2, '24': 100.8},
      'Май': {'40': 159.0, '36': 143.0, '24': 95.0},
      'Июнь': {'40': 151.0, '36': 135.8, '24': 90.2},
      'Июль': {'40': 184.0, '36': 165.6, '24': 110.4},
      'Август': {'40': 176.0, '36': 158.4, '24': 105.6},
      'Сентябрь': {'40': 168.0, '36': 151.2, '24': 100.8},
      'Октябрь': {'40': 184.0, '36': 165.6, '24': 110.4},
      'Ноябрь': {'40': 167.0, '36': 150.2, '24': 99.8},
      'Декабрь': {'40': 168.0, '36': 151.2, '24': 100.8},
    },
    2025: {
      'Январь': {'40': 136.0, '36': 122.4, '24': 81.6},
      'Февраль': {'40': 160.0, '36': 144.0, '24': 96.0},
      'Март': {'40': 167.0, '36': 150.2, '24': 99.8},
      'Апрель': {'40': 175.0, '36': 157.4, '24': 104.6},
      'Май': {'40': 144.0, '36': 129.6, '24': 86.4},
      'Июнь': {'40': 151.0, '36': 135.8, '24': 90.2},
      'Июль': {'40': 184.0, '36': 165.6, '24': 110.4},
      'Август': {'40': 168.0, '36': 151.2, '24': 100.8},
      'Сентябрь': {'40': 176.0, '36': 158.4, '24': 105.6},
      'Октябрь': {'40': 184.0, '36': 165.6, '24': 110.4},
      'Ноябрь': {'40': 151.0, '36': 135.8, '24': 90.2},
      'Декабрь': {'40': 176.0, '36': 158.4, '24': 105.6},
    },
    2026: {
      'Январь': {'40': 120.0, '36': 108.0, '24': 72.0},
      'Февраль': {'40': 152.0, '36': 136.8, '24': 91.2},
      'Март': {'40': 168.0, '36': 151.2, '24': 100.8},
      'Апрель': {'40': 175.0, '36': 157.4, '24': 104.6},
      'Май': {'40': 151.0, '36': 135.8, '24': 90.2},
      'Июнь': {'40': 167.0, '36': 150.2, '24': 99.8},
      'Июль': {'40': 184.0, '36': 165.6, '24': 110.4},
      'Август': {'40': 168.0, '36': 151.2, '24': 100.8},
      'Сентябрь': {'40': 176.0, '36': 158.4, '24': 105.6},
      'Октябрь': {'40': 176.0, '36': 158.4, '24': 105.6},
      'Ноябрь': {'40': 159.0, '36': 143.0, '24': 95.0},
      'Декабрь': {'40': 176.0, '36': 158.4, '24': 105.6},
    },
  };

  static const List<String> monthNames = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  static const List<String> weekTypes = ['40', '36', '24'];

  // ── Рабочие данные (могут быть изменены пользователем) ────────
  late Map<int, Map<String, Map<String, double>>> yearlyWorkHours;

  WorkCalendar() {
    // Инициализируем глубокой копией defaults
    yearlyWorkHours = _deepCopy(_defaults);
  }

  // ── Singleton с ленивой загрузкой ─────────────────────────────
  static WorkCalendar? _instance;
  static WorkCalendar get instance {
    _instance ??= WorkCalendar();
    return _instance!;
  }

  // ── Загрузка из SharedPreferences ─────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefKey);
    if (json == null) return; // нет сохранённых данных — используем defaults

    try {
      final Map<String, dynamic> decoded = jsonDecode(json);
      final loaded = <int, Map<String, Map<String, double>>>{};

      for (final yearEntry in decoded.entries) {
        final year = int.tryParse(yearEntry.key);
        if (year == null) continue;
        final monthMap = <String, Map<String, double>>{};

        for (final monthEntry
            in (yearEntry.value as Map<String, dynamic>).entries) {
          final hoursMap = <String, double>{};
          for (final wtEntry
              in (monthEntry.value as Map<String, dynamic>).entries) {
            hoursMap[wtEntry.key] = (wtEntry.value as num).toDouble();
          }
          monthMap[monthEntry.key] = hoursMap;
        }
        loaded[year] = monthMap;
      }

      // Мержим: defaults + пользовательские поверх defaults
      yearlyWorkHours = _deepCopy(_defaults);
      for (final ye in loaded.entries) {
        yearlyWorkHours[ye.key] ??= {};
        for (final me in ye.value.entries) {
          yearlyWorkHours[ye.key]![me.key] ??= {};
          yearlyWorkHours[ye.key]![me.key]!.addAll(me.value);
        }
      }
    } catch (_) {
      // повреждённые данные — используем defaults
      yearlyWorkHours = _deepCopy(_defaults);
    }
  }

  // ── Сохранение в SharedPreferences ───────────────────────────
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    // Сохраняем только отличия от defaults
    final diff = <String, dynamic>{};

    for (final ye in yearlyWorkHours.entries) {
      final yearDiff = <String, dynamic>{};
      for (final me in ye.value.entries) {
        final monthDiff = <String, dynamic>{};
        for (final wte in me.value.entries) {
          final defVal = _defaults[ye.key]?[me.key]?[wte.key];
          if (defVal == null || defVal != wte.value) {
            monthDiff[wte.key] = wte.value;
          }
        }
        if (monthDiff.isNotEmpty) yearDiff[me.key] = monthDiff;
      }
      if (yearDiff.isNotEmpty) diff[ye.key.toString()] = yearDiff;
    }

    await prefs.setString(_prefKey, jsonEncode(diff));
  }

  // ── Сброс к defaults ─────────────────────────────────────────
  Future<void> resetToDefaults() async {
    yearlyWorkHours = _deepCopy(_defaults);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  // ── Получение значений ────────────────────────────────────────

  /// Часов по норме для year/month/weekType ('40'|'36'|'24')
  double getWorkHours(int year, String month, String weekType) {
    return yearlyWorkHours[year]?[month]?[weekType] ?? 0.0;
  }

  /// Рабочих дней по норме: вычисляется из часов ÷ часов в день
  /// (40-часовая неделя = 8 ч/день, 36 = 7.2, 24 = 4.8)
  double getWorkDays(int year, String month, String weekType) {
    final hours = getWorkHours(year, month, weekType);
    final hoursPerDay = _hoursPerDay(weekType);
    if (hoursPerDay == 0) return 0;
    return (hours / hoursPerDay);
  }

  double _hoursPerDay(String weekType) {
    switch (weekType) {
      case '40':
        return 8.0;
      case '36':
        return 7.2;
      case '24':
        return 4.8;
      default:
        return 8.0;
    }
  }

  /// Часовая ставка сотрудника
  double calculateHourlyWage(
    double totalSalary,
    int year,
    String month,
    String weekType,
  ) {
    final hours = getWorkHours(year, month, weekType);
    if (hours == 0) {
      throw Exception(
        'Нет нормы часов для $month $year (тип недели: $weekType ч.)',
      );
    }
    return totalSalary / hours;
  }

  /// Зарплата по часовой ставке
  double calculateSalPoChasStavke(
    double chasovayaStavka,
    int year,
    String month,
    String weekType,
  ) {
    final hours = getWorkHours(year, month, weekType);
    if (hours == 0) {
      throw Exception(
        'Нет нормы часов для $month $year (тип недели: $weekType ч.)',
      );
    }
    return chasovayaStavka * hours;
  }

  List<int> get years => yearlyWorkHours.keys.toList()..sort();

  // ── Глубокое копирование defaults ────────────────────────────
  static Map<int, Map<String, Map<String, double>>> _deepCopy(
    Map<int, Map<String, Map<String, double>>> src,
  ) {
    return {
      for (final ye in src.entries)
        ye.key: {
          for (final me in ye.value.entries)
            me.key: Map<String, double>.from(me.value),
        },
    };
  }
}
