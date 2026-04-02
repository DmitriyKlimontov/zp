// lib/services/documents/doc_repository.dart
//
// Репозиторий: загружает все нужные данные из БД
// и собирает их в единую модель TrudovoyDogovorData.
// Не зависит от UI.

import 'package:intl/intl.dart';
import 'package:zp/db/database.dart';
import 'doc_models.dart';

class DocRepository {
  final DatabaseHelper _db;
  DocRepository([DatabaseHelper? db]) : _db = db ?? DatabaseHelper();

  /// Загружает все данные для трудового договора сотрудника.
  /// Возвращает null если сотрудник или организация не найдены.
  Future<TrudovoyDogovorData?> loadTrudovoyDogovorData({
    required int sotrudnikId,
    required int organizaciyaId,
    String? nomerDogovora,
  }) async {
    final db = await _db.database;

    // ── Сотрудник + должность + подразделение + условия труда ────
    final sotRows = await db.rawQuery(
      '''
      SELECT s.*,
             d.nazvanie   AS dolzhnostNazvanie,
             d.okladMin   AS okladMin,
             d.okladMax   AS okladMax,
             p.nazvanie   AS podrazdelenie,
             u.nazvanie              AS uslTrudaNazvanie,
             u.klassUslTruda         AS uslKlassUslTruda,
             u.graficRaboty          AS uslGraficRaboty,
             u.chasovVSmene          AS uslChasovVSmene,
             u.vrNachalaRaboty       AS uslVrNachalaRaboty,
             u.vrOkonchaniyaRaboty   AS uslVrOkonchaniyaRaboty,
             u.kolObedennyhPereryv   AS uslKolObedennyhPereryv,
             u.prodObedennyhPereryv  AS uslProdObedennyhPereryv,
             u.normirovannoye        AS uslNormirovannoye,
             u.chasovVechernih       AS uslChasovVechernih,
             u.chasovNochnykh        AS uslChasovNochnykh
      FROM sotrudniki s
      LEFT JOIN dolzhnosti     d ON d.id = s.dolzhnostId
      LEFT JOIN podrazdeleniya p ON p.id = s.podrazdelenieId
      LEFT JOIN uslTruda       u ON u.id = s.uslTrudaId
      WHERE s.id = ?
      LIMIT 1
    ''',
      [sotrudnikId],
    );

    if (sotRows.isEmpty) return null;
    final s = sotRows.first;

    // ── Организация ───────────────────────────────────────────────
    final orgRows = await db.rawQuery(
      'SELECT * FROM organizaciya WHERE id = ? LIMIT 1',
      [organizaciyaId],
    );

    if (orgRows.isEmpty) return null;
    final o = orgRows.first;

    // ── Номер договора и дата ─────────────────────────────────────
    final today = DateFormat('dd.MM.yyyy').format(DateTime.now());
    final nomer = nomerDogovora ?? 'ТД-$sotrudnikId-${DateTime.now().year}';

    return TrudovoyDogovorData(
      // Организация
      orgNazvanie: o['nazvanie']?.toString() ?? '',
      orgKratkoeNazvanie: o['kratkoeNazvanie']?.toString() ?? '',
      orgInn: o['inn']?.toString() ?? '',
      orgKpp: o['kpp']?.toString() ?? '',
      orgOgrn: o['ogrn']?.toString() ?? '',
      orgYuridicheskiyAdres: o['yuridicheskiyAdres']?.toString() ?? '',
      orgFakticheskiyAdres: o['fakticheskiyAdres']?.toString() ?? '',
      orgTelefon: o['telefon']?.toString() ?? '',
      orgElPochta: o['elPochta']?.toString() ?? '',
      orgBankRS: o['bankRS']?.toString() ?? '',
      orgBankKS: o['bankKS']?.toString() ?? '',
      orgBankBIK: o['bankBIK']?.toString() ?? '',
      orgBankName: o['bankName']?.toString() ?? '',
      orgDirektorFio: o['direktorFio']?.toString() ?? '',
      orgBuhgalterFio: o['buhgalterFio']?.toString() ?? '',

      // Сотрудник
      sotFamiliya: s['familiya']?.toString() ?? '',
      sotName: s['name']?.toString() ?? '',
      sotOtchestvo: s['otchestvo']?.toString() ?? '',
      sotDateBirth: s['dateBirth']?.toString() ?? '',
      sotMestoBirth: s['mestoBirth']?.toString() ?? '',
      sotAdresRegistr: s['adresRegistr']?.toString() ?? '',
      sotAdresGitelstva: s['adresGitelstva']?.toString() ?? '',
      sotTelefon: s['telefon']?.toString() ?? '',
      sotElPochta: s['elPochta']?.toString() ?? '',
      sotInn: s['inn']?.toString() ?? '',
      sotSnils: s['snils']?.toString() ?? '',
      sotPasportSeria: s['pasportSeria']?.toString() ?? '',
      sotPasportNomer: s['pasportNomer']?.toString() ?? '',
      sotPasportVidan: s['pasportVidan']?.toString() ?? '',
      sotPasportVidanDateTime: s['pasportVidanDateTime']?.toString() ?? '',
      sotPasportKodPodrazdeleniya:
          s['pasportKodPodrazdeleniya']?.toString() ?? '',
      sotBankRS: s['bankRS']?.toString() ?? '',
      sotBankKS: s['bankKS']?.toString() ?? '',
      sotBankBIK: s['bankBIK']?.toString() ?? '',
      sotBankName: s['bankName']?.toString() ?? '',
      sotDatePriema: s['datePriema']?.toString() ?? '',

      // Должность
      dolzhnostNazvanie: s['dolzhnostNazvanie']?.toString() ?? '',
      podrazdelenie: s['podrazdelenie']?.toString() ?? '',
      okladMin: (s['okladMin'] as num?)?.toDouble() ?? 0.0,
      okladMax: (s['okladMax'] as num?)?.toDouble() ?? 0.0,

      // Условия труда
      uslTrudaNazvanie: s['uslTrudaNazvanie']?.toString() ?? '',
      uslKlassUslTruda: s['uslKlassUslTruda']?.toString() ?? '',
      uslGraficRaboty: s['uslGraficRaboty']?.toString() ?? '',
      uslChasovVSmene: s['uslChasovVSmene'] as int? ?? 8,
      uslVrNachalaRaboty: s['uslVrNachalaRaboty']?.toString() ?? '',
      uslVrOkonchaniyaRaboty: s['uslVrOkonchaniyaRaboty']?.toString() ?? '',
      uslKolObedennyhPereryv: s['uslKolObedennyhPereryv'] as int? ?? 0,
      uslProdObedennyhPereryv: s['uslProdObedennyhPereryv'] as int? ?? 0,
      uslNormirovannoye: (s['uslNormirovannoye'] as int? ?? 1) == 1,
      uslChasovVechernih: s['uslChasovVechernih'] as int? ?? 0,
      uslChasovNochnykh: s['uslChasovNochnykh'] as int? ?? 0,

      // Служебные
      nomerDogovora: nomer,
      dateSostavleniya: today,
    );
  }

  /// Список всех организаций (для выбора при генерации)
  Future<List<Map<String, dynamic>>> getOrganizacii() async {
    return await _db.getAll('organizaciya');
  }
}
