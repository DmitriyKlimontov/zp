// Модель данных для трудового договора.
// Изолирована от других документов.

import 'package:zp/services/generators/generator_models.dart';

class TrudovoyDogovorData {
  // Организация
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

  // Сотрудник
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

  // Должность и тип оплаты
  final String dolzhnostNazvanie;
  final String podrazdelenie;
  final bool isOklad;
  final double oklad;
  final double chasovayaStavka;

  // Условия труда
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

  // Испытательный срок
  final bool estIspSrok;
  final int ispSrokKolichestvo;
  final IspSrokUnit ispSrokUnit;

  // Служебные
  final String nomerDogovora;
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
    required this.isOklad,
    required this.oklad,
    required this.chasovayaStavka,
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
    required this.estIspSrok,
    required this.ispSrokKolichestvo,
    required this.ispSrokUnit,
    required this.nomerDogovora,
    required this.dateSostavleniya,
  });

  String get sotFio => '$sotFamiliya $sotName $sotOtchestvo';

  String get sotFioShort {
    final n = sotName.isNotEmpty ? '${sotName[0]}.' : '';
    final o = sotOtchestvo.isNotEmpty ? '${sotOtchestvo[0]}.' : '';
    return '$sotFamiliya $n$o';
  }

  String get normirovanieLabel =>
      uslNormirovannoye ? 'нормируемое' : 'ненормируемое';

  String get obedLabel {
    if (uslKolObedennyhPereryv == 0) return 'без обеденного перерыва';
    return 'обеденный перерыв: $uslKolObedennyhPereryv × '
        '$uslProdObedennyhPereryv мин.';
  }

  String get ispSrokLabel {
    if (!estIspSrok) return 'Работник принимается без испытательного срока.';
    return 'Работнику устанавливается испытательный срок: '
        '${ispSrokUnit.labelFor(ispSrokKolichestvo)}.';
  }

  String get oplatyLabel {
    if (isOklad) {
      return 'Работнику устанавливается должностной оклад '
          '${oklad.toStringAsFixed(0)} руб. в месяц. '
          'При расчёте часовой тарифной ставки оклад делится '
          'на норму рабочего времени расчётного месяца.';
    }
    return 'Работнику устанавливается часовая тарифная ставка '
        '${chasovayaStavka.toStringAsFixed(2)} руб./час. '
        'Заработная плата начисляется за фактически отработанные часы.';
  }

  String get tipoplatyLabel =>
      isOklad ? 'Оклад (месячная)' : 'Часовая тарифная ставка';
}
