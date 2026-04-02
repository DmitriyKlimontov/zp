// lib/services/documents/doc_models.dart
//
// Модели данных для генерации документов.
// Не зависят от Flutter / БД — чистые Dart-классы.

/// Формат генерируемого документа
enum DocFormat { pdf, docx }

/// Все данные необходимые для генерации трудового договора
class TrudovoyDogovorData {
  // ── Организация ───────────────────────────────────────────────
  final String orgNazvanie;
  final String orgKratkoeNazvanie;
  final String orgInn;
  final String orgKpp;
  final String orgOgrn;
  final String orgYuridicheskiyAdres;
  final String orgFakticheskiyAdres;
  final String orgTelefon;
  final String orgElPochta;
  final String orgBankRS;
  final String orgBankKS;
  final String orgBankBIK;
  final String orgBankName;
  final String orgDirektorFio;
  final String orgBuhgalterFio;

  // ── Сотрудник ─────────────────────────────────────────────────
  final String sotFamiliya;
  final String sotName;
  final String sotOtchestvo;
  final String sotDateBirth;
  final String sotMestoBirth;
  final String sotAdresRegistr;
  final String sotAdresGitelstva;
  final String sotTelefon;
  final String sotElPochta;
  final String sotInn;
  final String sotSnils;
  final String sotPasportSeria;
  final String sotPasportNomer;
  final String sotPasportVidan;
  final String sotPasportVidanDateTime;
  final String sotPasportKodPodrazdeleniya;
  final String sotBankRS;
  final String sotBankKS;
  final String sotBankBIK;
  final String sotBankName;
  final String sotDatePriema;

  // ── Должность ─────────────────────────────────────────────────
  final String dolzhnostNazvanie;
  final String podrazdelenie;
  final double okladMin;
  final double okladMax;

  // ── Условия труда ─────────────────────────────────────────────
  final String uslTrudaNazvanie;
  final String uslKlassUslTruda;
  final String uslGraficRaboty;
  final int uslChasovVSmene;
  final String uslVrNachalaRaboty;
  final String uslVrOkonchaniyaRaboty;
  final int uslKolObedennyhPereryv;
  final int uslProdObedennyhPereryv;
  final bool uslNormirovannoye;
  final int uslChasovVechernih;
  final int uslChasovNochnykh;

  // ── Служебные ─────────────────────────────────────────────────
  final String nomerDogovora; // можно передать или сгенерировать
  final String dateSostavleniya;

  const TrudovoyDogovorData({
    required this.orgNazvanie,
    required this.orgKratkoeNazvanie,
    required this.orgInn,
    required this.orgKpp,
    required this.orgOgrn,
    required this.orgYuridicheskiyAdres,
    required this.orgFakticheskiyAdres,
    required this.orgTelefon,
    required this.orgElPochta,
    required this.orgBankRS,
    required this.orgBankKS,
    required this.orgBankBIK,
    required this.orgBankName,
    required this.orgDirektorFio,
    required this.orgBuhgalterFio,
    required this.sotFamiliya,
    required this.sotName,
    required this.sotOtchestvo,
    required this.sotDateBirth,
    required this.sotMestoBirth,
    required this.sotAdresRegistr,
    required this.sotAdresGitelstva,
    required this.sotTelefon,
    required this.sotElPochta,
    required this.sotInn,
    required this.sotSnils,
    required this.sotPasportSeria,
    required this.sotPasportNomer,
    required this.sotPasportVidan,
    required this.sotPasportVidanDateTime,
    required this.sotPasportKodPodrazdeleniya,
    required this.sotBankRS,
    required this.sotBankKS,
    required this.sotBankBIK,
    required this.sotBankName,
    required this.sotDatePriema,
    required this.dolzhnostNazvanie,
    required this.podrazdelenie,
    required this.okladMin,
    required this.okladMax,
    required this.uslTrudaNazvanie,
    required this.uslKlassUslTruda,
    required this.uslGraficRaboty,
    required this.uslChasovVSmene,
    required this.uslVrNachalaRaboty,
    required this.uslVrOkonchaniyaRaboty,
    required this.uslKolObedennyhPereryv,
    required this.uslProdObedennyhPereryv,
    required this.uslNormirovannoye,
    required this.uslChasovVechernih,
    required this.uslChasovNochnykh,
    required this.nomerDogovora,
    required this.dateSostavleniya,
  });

  // Удобный геттер: ФИО сотрудника полностью
  String get sotFio => '$sotFamiliya $sotName $sotOtchestvo';

  // Удобный геттер: ФИО сотрудника сокращённо (Иванов И.И.)
  String get sotFioShort {
    final n = sotName.isNotEmpty ? '${sotName[0]}.' : '';
    final o = sotOtchestvo.isNotEmpty ? '${sotOtchestvo[0]}.' : '';
    return '$sotFamiliya $n$o';
  }

  // Нормирование рабочего времени строкой
  String get normirovanieLabel =>
      uslNormirovannoye ? 'нормируемое' : 'ненормируемое';

  // Обеденный перерыв строкой
  String get obedLabel {
    if (uslKolObedennyhPereryv == 0) return 'без обеденного перерыва';
    return 'обеденный перерыв: $uslKolObedennyhPereryv × '
        '$uslProdObedennyhPereryv мин.';
  }
}

/// Результат генерации документа
class DocGenerationResult {
  final bool success;
  final String filePath; // путь к временному файлу
  final String? error;

  const DocGenerationResult({
    required this.success,
    required this.filePath,
    this.error,
  });
}
