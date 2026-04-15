// Базовые модели для всех генераторов документов.
// Каждый тип документа добавляет свои Data-классы в отдельный файл.

/// Результат генерации любого документа
class GeneratorResult {
  final bool success;
  final String filePath;
  final String? error;

  const GeneratorResult({
    required this.success,
    required this.filePath,
    this.error,
  });
}

// ─────────────────────────────────────────────────────────────
// Вспомогательные типы — общие для нескольких документов
// ─────────────────────────────────────────────────────────────

/// Единица измерения испытательного срока (для трудового договора)
enum IspSrokUnit { chasy, dni, nedeli, mesyacy }

extension IspSrokUnitExt on IspSrokUnit {
  String get label {
    switch (this) {
      case IspSrokUnit.chasy:
        return 'часов';
      case IspSrokUnit.dni:
        return 'дней';
      case IspSrokUnit.nedeli:
        return 'недель';
      case IspSrokUnit.mesyacy:
        return 'месяцев';
    }
  }

  String labelFor(int n) {
    switch (this) {
      case IspSrokUnit.chasy:
        return _plural(n, 'час', 'часа', 'часов');
      case IspSrokUnit.dni:
        return _plural(n, 'день', 'дня', 'дней');
      case IspSrokUnit.nedeli:
        return _plural(n, 'неделю', 'недели', 'недель');
      case IspSrokUnit.mesyacy:
        return _plural(n, 'месяц', 'месяца', 'месяцев');
    }
  }

  static String _plural(int n, String one, String few, String many) {
    final m10 = n % 10;
    final m100 = n % 100;
    if (m100 >= 11 && m100 <= 14) return '$n $many';
    if (m10 == 1) return '$n $one';
    if (m10 >= 2 && m10 <= 4) return '$n $few';
    return '$n $many';
  }
}
