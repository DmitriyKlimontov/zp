import 'package:intl/intl.dart';
import 'package:zp/db/database.dart';
import 'package:zp/services/generators/generator_models.dart';
import 'td_data.dart';

class TdRepository {
  final DatabaseHelper _db;
  TdRepository([DatabaseHelper? db]) : _db = db ?? DatabaseHelper();

  Future<TrudovoyDogovorData?> load({
    required int sotrudnikId,
    required int organizaciyaId,
    String? nomerDogovora,
    bool estIspSrok = false,
    int ispSrokKolichestvo = 3,
    IspSrokUnit ispSrokUnit = IspSrokUnit.mesyacy,
  }) async {
    final db = await _db.database;

    final sotRows = await db.rawQuery(
      '''
      SELECT s.*,
             d.nazvanie          AS dolzhnostNazvanie,
             d.oklad             AS oklad,
             d.chasovayaStavka   AS chasovayaStavka,
             d.isOklad           AS isOklad,
             p.nazvanie          AS podrazdelenie,
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

    final orgRows = await db.rawQuery(
      'SELECT * FROM organizaciya WHERE id = ? LIMIT 1',
      [organizaciyaId],
    );
    if (orgRows.isEmpty) return null;
    final o = orgRows.first;

    return TrudovoyDogovorData(
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
      dolzhnostNazvanie: s['dolzhnostNazvanie']?.toString() ?? '',
      podrazdelenie: s['podrazdelenie']?.toString() ?? '',
      isOklad: (s['isOklad'] as int? ?? 1) == 1,
      oklad: (s['oklad'] as num?)?.toDouble() ?? 0.0,
      chasovayaStavka: (s['chasovayaStavka'] as num?)?.toDouble() ?? 0.0,
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
      estIspSrok: estIspSrok,
      ispSrokKolichestvo: ispSrokKolichestvo,
      ispSrokUnit: ispSrokUnit,
      nomerDogovora: nomerDogovora ?? '',
      dateSostavleniya: DateFormat('dd.MM.yyyy').format(DateTime.now()),
    );
  }

  Future<List<Map<String, dynamic>>> getOrganizacii() =>
      _db.getAll('organizaciya');
}
