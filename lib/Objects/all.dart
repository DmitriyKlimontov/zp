// ==================== СОТРУДНИКИ ====================
class Sotrudniki {
  int? id;
  String familiya;
  String name;
  String otchestvo;
  String dateBirth;
  String mestoBirth;
  String adresRegistr;
  String adresGitelstva;
  String telefon;
  String elPochta;
  String pasportSeria;
  String pasportNomer;
  String pasportVidan;
  String pasportVidanDateTime;
  String pasportKodPodrazdeleniya;
  String bankRS;
  String bankKS;
  String bankBIK;
  String bankName;
  String datePriema;
  String dateUvolneniya;
  int dolzhnostId;
  int podrazdelenieId;
  int stavka; // 1 = полная, 2 = 0.5 и т.д.
  String inn;
  String snils;
  int uslTrudaId;

  Sotrudniki({
    this.id,
    this.familiya = '',
    this.name = '',
    this.otchestvo = '',
    this.dateBirth = '',
    this.mestoBirth = '',
    this.adresRegistr = '',
    this.adresGitelstva = '',
    this.telefon = '',
    this.elPochta = '',
    this.pasportSeria = '',
    this.pasportNomer = '',
    this.pasportVidan = '',
    this.pasportVidanDateTime = '',
    this.pasportKodPodrazdeleniya = '',
    this.bankRS = '',
    this.bankKS = '',
    this.bankBIK = '',
    this.bankName = '',
    this.datePriema = '',
    this.dateUvolneniya = '',
    this.dolzhnostId = 0,
    this.podrazdelenieId = 0,
    this.stavka = 1,
    this.inn = '',
    this.snils = '',
    this.uslTrudaId = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? 0,
      'familiya': familiya,
      'name': name,
      'otchestvo': otchestvo,
      'dateBirth': dateBirth,
      'mestoBirth': mestoBirth,
      'adresRegistr': adresRegistr,
      'adresGitelstva': adresGitelstva,
      'telefon': telefon,
      'elPochta': elPochta,
      'pasportSeria': pasportSeria,
      'pasportNomer': pasportNomer,
      'pasportVidan': pasportVidan,
      'pasportVidanDateTime': pasportVidanDateTime,
      'pasportKodPodrazdeleniya': pasportKodPodrazdeleniya,
      'bankRS': bankRS,
      'bankKS': bankKS,
      'bankBIK': bankBIK,
      'bankName': bankName,
      'datePriema': datePriema,
      'dateUvolneniya': dateUvolneniya,
      'dolzhnostId': dolzhnostId,
      'podrazdelenieId': podrazdelenieId,
      'stavka': stavka,
      'inn': inn,
      'snils': snils,
      'uslTrudaId': uslTrudaId,
    };
  }

  factory Sotrudniki.fromMap(Map<String, dynamic> map) {
    return Sotrudniki(
      id: map['id'],
      familiya: map['familiya']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      otchestvo: map['otchestvo']?.toString() ?? '',
      dateBirth: map['dateBirth']?.toString() ?? '',
      mestoBirth: map['mestoBirth']?.toString() ?? '',
      adresRegistr: map['adresRegistr']?.toString() ?? '',
      adresGitelstva: map['adresGitelstva']?.toString() ?? '',
      telefon: map['telefon']?.toString() ?? '',
      elPochta: map['elPochta']?.toString() ?? '',
      pasportSeria: map['pasportSeria']?.toString() ?? '',
      pasportNomer: map['pasportNomer']?.toString() ?? '',
      pasportVidan: map['pasportVidan']?.toString() ?? '',
      pasportVidanDateTime: map['pasportVidanDateTime']?.toString() ?? '',
      pasportKodPodrazdeleniya:
          map['pasportKodPodrazdeleniya']?.toString() ?? '',
      bankRS: map['bankRS']?.toString() ?? '',
      bankKS: map['bankKS']?.toString() ?? '',
      bankBIK: map['bankBIK']?.toString() ?? '',
      bankName: map['bankName']?.toString() ?? '',
      datePriema: map['datePriema']?.toString() ?? '',
      dateUvolneniya: map['dateUvolneniya']?.toString() ?? '',
      dolzhnostId: map['dolzhnostId'] as int? ?? 0,
      podrazdelenieId: map['podrazdelenieId'] as int? ?? 0,
      stavka: map['stavka'] as int? ?? 1,
      inn: map['inn']?.toString() ?? '',
      snils: map['snils']?.toString() ?? '',
      uslTrudaId: map['uslTrudaId'] as int? ?? 0,
    );
  }

  factory Sotrudniki.empty() => Sotrudniki(
    id: 0,
    familiya: '',
    name: '',
    otchestvo: '',
    dateBirth: '',
    mestoBirth: '',
    adresRegistr: '',
    adresGitelstva: '',
    telefon: '',
    elPochta: '',
    pasportSeria: '',
    pasportNomer: '',
    pasportVidan: '',
    pasportVidanDateTime: '',
    pasportKodPodrazdeleniya: '',
    bankRS: '',
    bankKS: '',
    bankBIK: '',
    bankName: '',
    datePriema: '',
    dateUvolneniya: '',
    dolzhnostId: 0,
    podrazdelenieId: 0,
    stavka: 1,
    inn: '',
    snils: '',
    uslTrudaId: 0,
  );

  Sotrudniki copyWith({
    int? id,
    String? familiya,
    String? name,
    String? otchestvo,
    String? dateBirth,
    String? mestoBirth,
    String? adresRegistr,
    String? adresGitelstva,
    String? telefon,
    String? elPochta,
    String? pasportSeria,
    String? pasportNomer,
    String? pasportVidan,
    String? pasportVidanDateTime,
    String? pasportKodPodrazdeleniya,
    String? bankRS,
    String? bankKS,
    String? bankBIK,
    String? bankName,
    String? datePriema,
    String? dateUvolneniya,
    int? dolzhnostId,
    int? podrazdelenieId,
    int? stavka,
    String? inn,
    String? snils,
    int? uslTrudaId,
  }) {
    return Sotrudniki(
      id: id ?? this.id,
      familiya: familiya ?? this.familiya,
      name: name ?? this.name,
      otchestvo: otchestvo ?? this.otchestvo,
      dateBirth: dateBirth ?? this.dateBirth,
      mestoBirth: mestoBirth ?? this.mestoBirth,
      adresRegistr: adresRegistr ?? this.adresRegistr,
      adresGitelstva: adresGitelstva ?? this.adresGitelstva,
      telefon: telefon ?? this.telefon,
      elPochta: elPochta ?? this.elPochta,
      pasportSeria: pasportSeria ?? this.pasportSeria,
      pasportNomer: pasportNomer ?? this.pasportNomer,
      pasportVidan: pasportVidan ?? this.pasportVidan,
      pasportVidanDateTime: pasportVidanDateTime ?? this.pasportVidanDateTime,
      pasportKodPodrazdeleniya:
          pasportKodPodrazdeleniya ?? this.pasportKodPodrazdeleniya,
      bankRS: bankRS ?? this.bankRS,
      bankKS: bankKS ?? this.bankKS,
      bankBIK: bankBIK ?? this.bankBIK,
      bankName: bankName ?? this.bankName,
      datePriema: datePriema ?? this.datePriema,
      dateUvolneniya: dateUvolneniya ?? this.dateUvolneniya,
      dolzhnostId: dolzhnostId ?? this.dolzhnostId,
      podrazdelenieId: podrazdelenieId ?? this.podrazdelenieId,
      stavka: stavka ?? this.stavka,
      inn: inn ?? this.inn,
      snils: snils ?? this.snils,
      uslTrudaId: uslTrudaId ?? this.uslTrudaId,
    );
  }
}

// ==================== УСЛОВИЯ ТРУДА НА РАБОЧЕМ МЕСТЕ ====================
class UslTruda {
  int? id;
  String nazvanie; // Наименование условия труда
  String klassUslTruda; // Класс условий труда (1, 2, 3.1, 3.2, 3.3, 3.4, 4)
  String
  graficRaboty; // График работы (текст: «5-дневная рабочая неделя» и т.д.)
  int chasovVSmene; // Количество рабочих часов в смене
  String vrNachalaRaboty; // Время начала работы (HH:mm)
  String vrOkonchaniyaRaboty; // Время окончания работы (HH:mm)
  int kolObedennyhPereryv; // Количество обеденных перерывов (0 = нет)
  int prodObedennyhPereryv; // Продолжительность обеденных перерывов (мин)
  bool normirovannoye; // true = нормируемое, false = ненормируемое
  int chasovVechernih; // Количество вечерних часов в смене
  int chasovNochnykh; // Количество ночных часов в смене
  String primechanie; // Примечание

  UslTruda({
    this.id,
    this.nazvanie = '',
    this.klassUslTruda = '',
    this.graficRaboty = '',
    this.chasovVSmene = 8,
    this.vrNachalaRaboty = '',
    this.vrOkonchaniyaRaboty = '',
    this.kolObedennyhPereryv = 1,
    this.prodObedennyhPereryv = 60,
    this.normirovannoye = true,
    this.chasovVechernih = 0,
    this.chasovNochnykh = 0,
    this.primechanie = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? 0,
      'nazvanie': nazvanie,
      'klassUslTruda': klassUslTruda,
      'graficRaboty': graficRaboty,
      'chasovVSmene': chasovVSmene,
      'vrNachalaRaboty': vrNachalaRaboty,
      'vrOkonchaniyaRaboty': vrOkonchaniyaRaboty,
      'kolObedennyhPereryv': kolObedennyhPereryv,
      'prodObedennyhPereryv': prodObedennyhPereryv,
      'normirovannoye': normirovannoye ? 1 : 0,
      'chasovVechernih': chasovVechernih,
      'chasovNochnykh': chasovNochnykh,
      'primechanie': primechanie,
    };
  }

  factory UslTruda.fromMap(Map<String, dynamic> map) {
    return UslTruda(
      id: map['id'],
      nazvanie: map['nazvanie']?.toString() ?? '',
      klassUslTruda: map['klassUslTruda']?.toString() ?? '',
      graficRaboty: map['graficRaboty']?.toString() ?? '',
      chasovVSmene: map['chasovVSmene'] as int? ?? 8,
      vrNachalaRaboty: map['vrNachalaRaboty']?.toString() ?? '',
      vrOkonchaniyaRaboty: map['vrOkonchaniyaRaboty']?.toString() ?? '',
      kolObedennyhPereryv: map['kolObedennyhPereryv'] as int? ?? 1,
      prodObedennyhPereryv: map['prodObedennyhPereryv'] as int? ?? 60,
      normirovannoye: (map['normirovannoye'] as int? ?? 1) == 1,
      chasovVechernih: map['chasovVechernih'] as int? ?? 0,
      chasovNochnykh: map['chasovNochnykh'] as int? ?? 0,
      primechanie: map['primechanie']?.toString() ?? '',
    );
  }

  factory UslTruda.empty() => UslTruda(
    id: 0,
    nazvanie: '',
    klassUslTruda: '',
    graficRaboty: '',
    chasovVSmene: 8,
    vrNachalaRaboty: '',
    vrOkonchaniyaRaboty: '',
    kolObedennyhPereryv: 1,
    prodObedennyhPereryv: 60,
    normirovannoye: true,
    chasovVechernih: 0,
    chasovNochnykh: 0,
    primechanie: '',
  );

  UslTruda copyWith({
    int? id,
    String? nazvanie,
    String? klassUslTruda,
    String? graficRaboty,
    int? chasovVSmene,
    String? vrNachalaRaboty,
    String? vrOkonchaniyaRaboty,
    int? kolObedennyhPereryv,
    int? prodObedennyhPereryv,
    bool? normirovannoye,
    int? chasovVechernih,
    int? chasovNochnykh,
    String? primechanie,
  }) {
    return UslTruda(
      id: id ?? this.id,
      nazvanie: nazvanie ?? this.nazvanie,
      klassUslTruda: klassUslTruda ?? this.klassUslTruda,
      graficRaboty: graficRaboty ?? this.graficRaboty,
      chasovVSmene: chasovVSmene ?? this.chasovVSmene,
      vrNachalaRaboty: vrNachalaRaboty ?? this.vrNachalaRaboty,
      vrOkonchaniyaRaboty: vrOkonchaniyaRaboty ?? this.vrOkonchaniyaRaboty,
      kolObedennyhPereryv: kolObedennyhPereryv ?? this.kolObedennyhPereryv,
      prodObedennyhPereryv: prodObedennyhPereryv ?? this.prodObedennyhPereryv,
      normirovannoye: normirovannoye ?? this.normirovannoye,
      chasovVechernih: chasovVechernih ?? this.chasovVechernih,
      chasovNochnykh: chasovNochnykh ?? this.chasovNochnykh,
      primechanie: primechanie ?? this.primechanie,
    );
  }
}

// ==================== ДОЛЖНОСТИ ====================
class Dolzhnosti {
  int? id;
  String nazvanie; // Название должности
  String kod; // Код должности
  double okladMin; // Минимальный оклад
  double okladMax; // Максимальный оклад
  int podrazdelenieId;

  Dolzhnosti({
    this.id,
    this.nazvanie = '',
    this.kod = '',
    this.okladMin = 0.0,
    this.okladMax = 0.0,
    this.podrazdelenieId = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'nazvanie': nazvanie,
    'kod': kod,
    'okladMin': okladMin,
    'okladMax': okladMax,
    'podrazdelenieId': podrazdelenieId,
  };

  factory Dolzhnosti.fromMap(Map<String, dynamic> map) => Dolzhnosti(
    id: map['id'],
    nazvanie: map['nazvanie']?.toString() ?? '',
    kod: map['kod']?.toString() ?? '',
    okladMin: (map['okladMin'] as num?)?.toDouble() ?? 0.0,
    okladMax: (map['okladMax'] as num?)?.toDouble() ?? 0.0,
    podrazdelenieId: map['podrazdelenieId'] as int? ?? 0,
  );

  factory Dolzhnosti.empty() => Dolzhnosti(id: 0);

  Dolzhnosti copyWith({
    int? id,
    String? nazvanie,
    String? kod,
    double? okladMin,
    double? okladMax,
    int? podrazdelenieId,
  }) => Dolzhnosti(
    id: id ?? this.id,
    nazvanie: nazvanie ?? this.nazvanie,
    kod: kod ?? this.kod,
    okladMin: okladMin ?? this.okladMin,
    okladMax: okladMax ?? this.okladMax,
    podrazdelenieId: podrazdelenieId ?? this.podrazdelenieId,
  );
}

// ==================== ПОДРАЗДЕЛЕНИЯ ====================
class Podrazdeleniya {
  int? id;
  String nazvanie; // Название подразделения
  String kod; // Код подразделения
  int rukovoditelId; // ID руководителя (FK -> Sotrudniki)
  int organizaciyaId; // FK -> Organizaciya

  Podrazdeleniya({
    this.id,
    this.nazvanie = '',
    this.kod = '',
    this.rukovoditelId = 0,
    this.organizaciyaId = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'nazvanie': nazvanie,
    'kod': kod,
    'rukovoditelId': rukovoditelId,
    'organizaciyaId': organizaciyaId,
  };

  factory Podrazdeleniya.fromMap(Map<String, dynamic> map) => Podrazdeleniya(
    id: map['id'],
    nazvanie: map['nazvanie']?.toString() ?? '',
    kod: map['kod']?.toString() ?? '',
    rukovoditelId: map['rukovoditelId'] as int? ?? 0,
    organizaciyaId: map['organizaciyaId'] as int? ?? 0,
  );

  factory Podrazdeleniya.empty() => Podrazdeleniya(id: 0);

  Podrazdeleniya copyWith({
    int? id,
    String? nazvanie,
    String? kod,
    int? rukovoditelId,
    int? organizaciyaId,
  }) => Podrazdeleniya(
    id: id ?? this.id,
    nazvanie: nazvanie ?? this.nazvanie,
    kod: kod ?? this.kod,
    rukovoditelId: rukovoditelId ?? this.rukovoditelId,
    organizaciyaId: organizaciyaId ?? this.organizaciyaId,
  );
}

// ==================== ОРГАНИЗАЦИЯ ====================
class Organizaciya {
  int? id;
  String nazvanie;
  String kratkoeNazvanie;
  String inn;
  String kpp;
  String ogrn;
  String yuridicheskiyAdres;
  String fakticheskiyAdres;
  String telefon;
  String elPochta;
  String bankRS;
  String bankKS;
  String bankBIK;
  String bankName;
  String direktorFio; // ФИО директора
  String buhgalterFio; // ФИО главного бухгалтера

  Organizaciya({
    this.id,
    this.nazvanie = '',
    this.kratkoeNazvanie = '',
    this.inn = '',
    this.kpp = '',
    this.ogrn = '',
    this.yuridicheskiyAdres = '',
    this.fakticheskiyAdres = '',
    this.telefon = '',
    this.elPochta = '',
    this.bankRS = '',
    this.bankKS = '',
    this.bankBIK = '',
    this.bankName = '',
    this.direktorFio = '',
    this.buhgalterFio = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'nazvanie': nazvanie,
    'kratkoeNazvanie': kratkoeNazvanie,
    'inn': inn,
    'kpp': kpp,
    'ogrn': ogrn,
    'yuridicheskiyAdres': yuridicheskiyAdres,
    'fakticheskiyAdres': fakticheskiyAdres,
    'telefon': telefon,
    'elPochta': elPochta,
    'bankRS': bankRS,
    'bankKS': bankKS,
    'bankBIK': bankBIK,
    'bankName': bankName,
    'direktorFio': direktorFio,
    'buhgalterFio': buhgalterFio,
  };

  factory Organizaciya.fromMap(Map<String, dynamic> map) => Organizaciya(
    id: map['id'],
    nazvanie: map['nazvanie']?.toString() ?? '',
    kratkoeNazvanie: map['kratkoeNazvanie']?.toString() ?? '',
    inn: map['inn']?.toString() ?? '',
    kpp: map['kpp']?.toString() ?? '',
    ogrn: map['ogrn']?.toString() ?? '',
    yuridicheskiyAdres: map['yuridicheskiyAdres']?.toString() ?? '',
    fakticheskiyAdres: map['fakticheskiyAdres']?.toString() ?? '',
    telefon: map['telefon']?.toString() ?? '',
    elPochta: map['elPochta']?.toString() ?? '',
    bankRS: map['bankRS']?.toString() ?? '',
    bankKS: map['bankKS']?.toString() ?? '',
    bankBIK: map['bankBIK']?.toString() ?? '',
    bankName: map['bankName']?.toString() ?? '',
    direktorFio: map['direktorFio']?.toString() ?? '',
    buhgalterFio: map['buhgalterFio']?.toString() ?? '',
  );

  factory Organizaciya.empty() => Organizaciya(id: 0);

  Organizaciya copyWith({
    int? id,
    String? nazvanie,
    String? kratkoeNazvanie,
    String? inn,
    String? kpp,
    String? ogrn,
    String? yuridicheskiyAdres,
    String? fakticheskiyAdres,
    String? telefon,
    String? elPochta,
    String? bankRS,
    String? bankKS,
    String? bankBIK,
    String? bankName,
    String? direktorFio,
    String? buhgalterFio,
  }) => Organizaciya(
    id: id ?? this.id,
    nazvanie: nazvanie ?? this.nazvanie,
    kratkoeNazvanie: kratkoeNazvanie ?? this.kratkoeNazvanie,
    inn: inn ?? this.inn,
    kpp: kpp ?? this.kpp,
    ogrn: ogrn ?? this.ogrn,
    yuridicheskiyAdres: yuridicheskiyAdres ?? this.yuridicheskiyAdres,
    fakticheskiyAdres: fakticheskiyAdres ?? this.fakticheskiyAdres,
    telefon: telefon ?? this.telefon,
    elPochta: elPochta ?? this.elPochta,
    bankRS: bankRS ?? this.bankRS,
    bankKS: bankKS ?? this.bankKS,
    bankBIK: bankBIK ?? this.bankBIK,
    bankName: bankName ?? this.bankName,
    direktorFio: direktorFio ?? this.direktorFio,
    buhgalterFio: buhgalterFio ?? this.buhgalterFio,
  );
}

// ==================== НАЧИСЛЕНИЯ ====================
class Nachisleniya {
  int? id;
  int sotrudnikId;
  String periodMesyac; // Расчётный месяц (MM.yyyy)
  double oklad; // Оклад за период
  double premiya; // Премия
  double nadbavki; // Надбавки
  double otpusknye; // Отпускные
  double bolnichnye; // Больничные
  double materialPomosh; // Материальная помощь
  double inyeNachisleniya; // Иные начисления
  double itogoNachisleno; // Итого начислено

  Nachisleniya({
    this.id,
    this.sotrudnikId = 0,
    this.periodMesyac = '',
    this.oklad = 0.0,
    this.premiya = 0.0,
    this.nadbavki = 0.0,
    this.otpusknye = 0.0,
    this.bolnichnye = 0.0,
    this.materialPomosh = 0.0,
    this.inyeNachisleniya = 0.0,
    this.itogoNachisleno = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'sotrudnikId': sotrudnikId,
    'periodMesyac': periodMesyac,
    'oklad': oklad,
    'premiya': premiya,
    'nadbavki': nadbavki,
    'otpusknye': otpusknye,
    'bolnichnye': bolnichnye,
    'materialPomosh': materialPomosh,
    'inyeNachisleniya': inyeNachisleniya,
    'itogoNachisleno': itogoNachisleno,
  };

  factory Nachisleniya.fromMap(Map<String, dynamic> map) => Nachisleniya(
    id: map['id'],
    sotrudnikId: map['sotrudnikId'] as int? ?? 0,
    periodMesyac: map['periodMesyac']?.toString() ?? '',
    oklad: (map['oklad'] as num?)?.toDouble() ?? 0.0,
    premiya: (map['premiya'] as num?)?.toDouble() ?? 0.0,
    nadbavki: (map['nadbavki'] as num?)?.toDouble() ?? 0.0,
    otpusknye: (map['otpusknye'] as num?)?.toDouble() ?? 0.0,
    bolnichnye: (map['bolnichnye'] as num?)?.toDouble() ?? 0.0,
    materialPomosh: (map['materialPomosh'] as num?)?.toDouble() ?? 0.0,
    inyeNachisleniya: (map['inyeNachisleniya'] as num?)?.toDouble() ?? 0.0,
    itogoNachisleno: (map['itogoNachisleno'] as num?)?.toDouble() ?? 0.0,
  );

  factory Nachisleniya.empty() => Nachisleniya(id: 0);

  Nachisleniya copyWith({
    int? id,
    int? sotrudnikId,
    String? periodMesyac,
    double? oklad,
    double? premiya,
    double? nadbavki,
    double? otpusknye,
    double? bolnichnye,
    double? materialPomosh,
    double? inyeNachisleniya,
    double? itogoNachisleno,
  }) => Nachisleniya(
    id: id ?? this.id,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    periodMesyac: periodMesyac ?? this.periodMesyac,
    oklad: oklad ?? this.oklad,
    premiya: premiya ?? this.premiya,
    nadbavki: nadbavki ?? this.nadbavki,
    otpusknye: otpusknye ?? this.otpusknye,
    bolnichnye: bolnichnye ?? this.bolnichnye,
    materialPomosh: materialPomosh ?? this.materialPomosh,
    inyeNachisleniya: inyeNachisleniya ?? this.inyeNachisleniya,
    itogoNachisleno: itogoNachisleno ?? this.itogoNachisleno,
  );
}

// ==================== УДЕРЖАНИЯ ====================
class Uderzhaniya {
  int? id;
  int sotrudnikId;
  String periodMesyac;
  double ndfl; // НДФЛ 13%
  double pfr; // Взносы ПФР
  double foms; // Взносы ФОМС
  double fss; // Взносы ФСС
  double alimenty; // Алименты
  double inyeUderzhaniya; // Иные удержания
  double itogoUderzhano; // Итого удержано
  double kVyplate; // К выплате (начислено - удержано)

  Uderzhaniya({
    this.id,
    this.sotrudnikId = 0,
    this.periodMesyac = '',
    this.ndfl = 0.0,
    this.pfr = 0.0,
    this.foms = 0.0,
    this.fss = 0.0,
    this.alimenty = 0.0,
    this.inyeUderzhaniya = 0.0,
    this.itogoUderzhano = 0.0,
    this.kVyplate = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'sotrudnikId': sotrudnikId,
    'periodMesyac': periodMesyac,
    'ndfl': ndfl,
    'pfr': pfr,
    'foms': foms,
    'fss': fss,
    'alimenty': alimenty,
    'inyeUderzhaniya': inyeUderzhaniya,
    'itogoUderzhano': itogoUderzhano,
    'kVyplate': kVyplate,
  };

  factory Uderzhaniya.fromMap(Map<String, dynamic> map) => Uderzhaniya(
    id: map['id'],
    sotrudnikId: map['sotrudnikId'] as int? ?? 0,
    periodMesyac: map['periodMesyac']?.toString() ?? '',
    ndfl: (map['ndfl'] as num?)?.toDouble() ?? 0.0,
    pfr: (map['pfr'] as num?)?.toDouble() ?? 0.0,
    foms: (map['foms'] as num?)?.toDouble() ?? 0.0,
    fss: (map['fss'] as num?)?.toDouble() ?? 0.0,
    alimenty: (map['alimenty'] as num?)?.toDouble() ?? 0.0,
    inyeUderzhaniya: (map['inyeUderzhaniya'] as num?)?.toDouble() ?? 0.0,
    itogoUderzhano: (map['itogoUderzhano'] as num?)?.toDouble() ?? 0.0,
    kVyplate: (map['kVyplate'] as num?)?.toDouble() ?? 0.0,
  );

  factory Uderzhaniya.empty() => Uderzhaniya(id: 0);

  Uderzhaniya copyWith({
    int? id,
    int? sotrudnikId,
    String? periodMesyac,
    double? ndfl,
    double? pfr,
    double? foms,
    double? fss,
    double? alimenty,
    double? inyeUderzhaniya,
    double? itogoUderzhano,
    double? kVyplate,
  }) => Uderzhaniya(
    id: id ?? this.id,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    periodMesyac: periodMesyac ?? this.periodMesyac,
    ndfl: ndfl ?? this.ndfl,
    pfr: pfr ?? this.pfr,
    foms: foms ?? this.foms,
    fss: fss ?? this.fss,
    alimenty: alimenty ?? this.alimenty,
    inyeUderzhaniya: inyeUderzhaniya ?? this.inyeUderzhaniya,
    itogoUderzhano: itogoUderzhano ?? this.itogoUderzhano,
    kVyplate: kVyplate ?? this.kVyplate,
  );
}

// ==================== ТАБЕЛЬ УЧЁТА РАБОЧЕГО ВРЕМЕНИ ====================
class Tabel {
  int? id;
  int sotrudnikId;
  String periodMesyac;
  int rabochihDney; // Рабочих дней по норме
  int faktDney; // Фактически отработано дней
  int faktChasov; // Фактически отработано часов
  int otpuskDney; // Дней в отпуске
  int bolnichnyhDney; // Дней на больничном
  int progulDney; // Прогулы
  int komandirovkaDney; // Командировка (дней)

  Tabel({
    this.id,
    this.sotrudnikId = 0,
    this.periodMesyac = '',
    this.rabochihDney = 0,
    this.faktDney = 0,
    this.faktChasov = 0,
    this.otpuskDney = 0,
    this.bolnichnyhDney = 0,
    this.progulDney = 0,
    this.komandirovkaDney = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'sotrudnikId': sotrudnikId,
    'periodMesyac': periodMesyac,
    'rabochihDney': rabochihDney,
    'faktDney': faktDney,
    'faktChasov': faktChasov,
    'otpuskDney': otpuskDney,
    'bolnichnyhDney': bolnichnyhDney,
    'progulDney': progulDney,
    'komandirovkaDney': komandirovkaDney,
  };

  factory Tabel.fromMap(Map<String, dynamic> map) => Tabel(
    id: map['id'],
    sotrudnikId: map['sotrudnikId'] as int? ?? 0,
    periodMesyac: map['periodMesyac']?.toString() ?? '',
    rabochihDney: map['rabochihDney'] as int? ?? 0,
    faktDney: map['faktDney'] as int? ?? 0,
    faktChasov: map['faktChasov'] as int? ?? 0,
    otpuskDney: map['otpuskDney'] as int? ?? 0,
    bolnichnyhDney: map['bolnichnyhDney'] as int? ?? 0,
    progulDney: map['progulDney'] as int? ?? 0,
    komandirovkaDney: map['komandirovkaDney'] as int? ?? 0,
  );

  factory Tabel.empty() => Tabel(id: 0);

  Tabel copyWith({
    int? id,
    int? sotrudnikId,
    String? periodMesyac,
    int? rabochihDney,
    int? faktDney,
    int? faktChasov,
    int? otpuskDney,
    int? bolnichnyhDney,
    int? progulDney,
    int? komandirovkaDney,
  }) => Tabel(
    id: id ?? this.id,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    periodMesyac: periodMesyac ?? this.periodMesyac,
    rabochihDney: rabochihDney ?? this.rabochihDney,
    faktDney: faktDney ?? this.faktDney,
    faktChasov: faktChasov ?? this.faktChasov,
    otpuskDney: otpuskDney ?? this.otpuskDney,
    bolnichnyhDney: bolnichnyhDney ?? this.bolnichnyhDney,
    progulDney: progulDney ?? this.progulDney,
    komandirovkaDney: komandirovkaDney ?? this.komandirovkaDney,
  );
}

// ==================== НАЛОГОВЫЕ ВЫЧЕТЫ ====================
class NalogovyeVychety {
  int? id;
  int sotrudnikId;
  int kodVycheta; // 126, 127, 128 и т.д.
  String nazvanie; // Описание вычета
  double summaVycheta; // Сумма вычета
  String dateNachala; // Дата начала применения
  String dateOkonchaniya; // Дата окончания
  String osnovanie; // Документ-основание

  NalogovyeVychety({
    this.id,
    this.sotrudnikId = 0,
    this.kodVycheta = 0,
    this.nazvanie = '',
    this.summaVycheta = 0.0,
    this.dateNachala = '',
    this.dateOkonchaniya = '',
    this.osnovanie = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'sotrudnikId': sotrudnikId,
    'kodVycheta': kodVycheta,
    'nazvanie': nazvanie,
    'summaVycheta': summaVycheta,
    'dateNachala': dateNachala,
    'dateOkonchaniya': dateOkonchaniya,
    'osnovanie': osnovanie,
  };

  factory NalogovyeVychety.fromMap(Map<String, dynamic> map) =>
      NalogovyeVychety(
        id: map['id'],
        sotrudnikId: map['sotrudnikId'] as int? ?? 0,
        kodVycheta: map['kodVycheta'] as int? ?? 0,
        nazvanie: map['nazvanie']?.toString() ?? '',
        summaVycheta: (map['summaVycheta'] as num?)?.toDouble() ?? 0.0,
        dateNachala: map['dateNachala']?.toString() ?? '',
        dateOkonchaniya: map['dateOkonchaniya']?.toString() ?? '',
        osnovanie: map['osnovanie']?.toString() ?? '',
      );

  factory NalogovyeVychety.empty() => NalogovyeVychety(id: 0);

  NalogovyeVychety copyWith({
    int? id,
    int? sotrudnikId,
    int? kodVycheta,
    String? nazvanie,
    double? summaVycheta,
    String? dateNachala,
    String? dateOkonchaniya,
    String? osnovanie,
  }) => NalogovyeVychety(
    id: id ?? this.id,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    kodVycheta: kodVycheta ?? this.kodVycheta,
    nazvanie: nazvanie ?? this.nazvanie,
    summaVycheta: summaVycheta ?? this.summaVycheta,
    dateNachala: dateNachala ?? this.dateNachala,
    dateOkonchaniya: dateOkonchaniya ?? this.dateOkonchaniya,
    osnovanie: osnovanie ?? this.osnovanie,
  );
}

// ==================== АВАНСЫ ====================
class Avans {
  int? id;
  int sotrudnikId;
  String periodMesyac; // Расчётный месяц (MM.yyyy)
  String dateVyplaty; // Дата фактической выплаты аванса
  double summaAvansa; // Сумма аванса
  double procentOtOklada; // Процент от оклада (например, 40.0 = 40%)
  String statusVyplaty; // 'nacisleno' | 'vyplaceno' | 'otmeneno'
  String sposobVyplaty; // 'bank' | 'kassa'
  String platezhDocument; // Номер платёжного документа
  String primechanie;

  Avans({
    this.id,
    this.sotrudnikId = 0,
    this.periodMesyac = '',
    this.dateVyplaty = '',
    this.summaAvansa = 0.0,
    this.procentOtOklada = 0.0,
    this.statusVyplaty = '',
    this.sposobVyplaty = '',
    this.platezhDocument = '',
    this.primechanie = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'sotrudnikId': sotrudnikId,
    'periodMesyac': periodMesyac,
    'dateVyplaty': dateVyplaty,
    'summaAvansa': summaAvansa,
    'procentOtOklada': procentOtOklada,
    'statusVyplaty': statusVyplaty,
    'sposobVyplaty': sposobVyplaty,
    'platezhDocument': platezhDocument,
    'primechanie': primechanie,
  };

  factory Avans.fromMap(Map<String, dynamic> map) => Avans(
    id: map['id'],
    sotrudnikId: map['sotrudnikId'] as int? ?? 0,
    periodMesyac: map['periodMesyac']?.toString() ?? '',
    dateVyplaty: map['dateVyplaty']?.toString() ?? '',
    summaAvansa: (map['summaAvansa'] as num?)?.toDouble() ?? 0.0,
    procentOtOklada: (map['procentOtOklada'] as num?)?.toDouble() ?? 0.0,
    statusVyplaty: map['statusVyplaty']?.toString() ?? '',
    sposobVyplaty: map['sposobVyplaty']?.toString() ?? '',
    platezhDocument: map['platezhDocument']?.toString() ?? '',
    primechanie: map['primechanie']?.toString() ?? '',
  );

  factory Avans.empty() => Avans(id: 0);

  Avans copyWith({
    int? id,
    int? sotrudnikId,
    String? periodMesyac,
    String? dateVyplaty,
    double? summaAvansa,
    double? procentOtOklada,
    String? statusVyplaty,
    String? sposobVyplaty,
    String? platezhDocument,
    String? primechanie,
  }) => Avans(
    id: id ?? this.id,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    periodMesyac: periodMesyac ?? this.periodMesyac,
    dateVyplaty: dateVyplaty ?? this.dateVyplaty,
    summaAvansa: summaAvansa ?? this.summaAvansa,
    procentOtOklada: procentOtOklada ?? this.procentOtOklada,
    statusVyplaty: statusVyplaty ?? this.statusVyplaty,
    sposobVyplaty: sposobVyplaty ?? this.sposobVyplaty,
    platezhDocument: platezhDocument ?? this.platezhDocument,
    primechanie: primechanie ?? this.primechanie,
  );
}

// ==================== ОТПУСКА (ПРИКАЗЫ) ====================
class Otpusk {
  int? id;
  int sotrudnikId;
  String vidOtpuska; // 'ezhegodnyy' | 'uchebniy' | 'dekretnyy' | 'bez_oplaty'
  String dateNachala; // Дата начала отпуска
  String dateOkonchaniya; // Дата окончания отпуска
  int kolichestvoDney; // Количество календарных дней
  String nomerPrikaza; // Номер приказа на отпуск
  String datePrikaza; // Дата приказа
  double sredniyZarabotok; // Средний дневной заработок
  double summaOtpusknyh; // Итоговая сумма отпускных
  String
  dateVyplatyOtpusknyh; // Дата выплаты отпускных (не позднее чем за 3 дня)
  String statusVyplaty; // 'nacisleno' | 'vyplaceno'

  Otpusk({
    this.id,
    this.sotrudnikId = 0,
    this.vidOtpuska = '',
    this.dateNachala = '',
    this.dateOkonchaniya = '',
    this.kolichestvoDney = 0,
    this.nomerPrikaza = '',
    this.datePrikaza = '',
    this.sredniyZarabotok = 0.0,
    this.summaOtpusknyh = 0.0,
    this.dateVyplatyOtpusknyh = '',
    this.statusVyplaty = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'sotrudnikId': sotrudnikId,
    'vidOtpuska': vidOtpuska,
    'dateNachala': dateNachala,
    'dateOkonchaniya': dateOkonchaniya,
    'kolichestvoDney': kolichestvoDney,
    'nomerPrikaza': nomerPrikaza,
    'datePrikaza': datePrikaza,
    'sredniyZarabotok': sredniyZarabotok,
    'summaOtpusknyh': summaOtpusknyh,
    'dateVyplatyOtpusknyh': dateVyplatyOtpusknyh,
    'statusVyplaty': statusVyplaty,
  };

  factory Otpusk.fromMap(Map<String, dynamic> map) => Otpusk(
    id: map['id'],
    sotrudnikId: map['sotrudnikId'] as int? ?? 0,
    vidOtpuska: map['vidOtpuska']?.toString() ?? '',
    dateNachala: map['dateNachala']?.toString() ?? '',
    dateOkonchaniya: map['dateOkonchaniya']?.toString() ?? '',
    kolichestvoDney: map['kolichestvoDney'] as int? ?? 0,
    nomerPrikaza: map['nomerPrikaza']?.toString() ?? '',
    datePrikaza: map['datePrikaza']?.toString() ?? '',
    sredniyZarabotok: (map['sredniyZarabotok'] as num?)?.toDouble() ?? 0.0,
    summaOtpusknyh: (map['summaOtpusknyh'] as num?)?.toDouble() ?? 0.0,
    dateVyplatyOtpusknyh: map['dateVyplatyOtpusknyh']?.toString() ?? '',
    statusVyplaty: map['statusVyplaty']?.toString() ?? '',
  );

  factory Otpusk.empty() => Otpusk(id: 0);

  Otpusk copyWith({
    int? id,
    int? sotrudnikId,
    String? vidOtpuska,
    String? dateNachala,
    String? dateOkonchaniya,
    int? kolichestvoDney,
    String? nomerPrikaza,
    String? datePrikaza,
    double? sredniyZarabotok,
    double? summaOtpusknyh,
    String? dateVyplatyOtpusknyh,
    String? statusVyplaty,
  }) => Otpusk(
    id: id ?? this.id,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    vidOtpuska: vidOtpuska ?? this.vidOtpuska,
    dateNachala: dateNachala ?? this.dateNachala,
    dateOkonchaniya: dateOkonchaniya ?? this.dateOkonchaniya,
    kolichestvoDney: kolichestvoDney ?? this.kolichestvoDney,
    nomerPrikaza: nomerPrikaza ?? this.nomerPrikaza,
    datePrikaza: datePrikaza ?? this.datePrikaza,
    sredniyZarabotok: sredniyZarabotok ?? this.sredniyZarabotok,
    summaOtpusknyh: summaOtpusknyh ?? this.summaOtpusknyh,
    dateVyplatyOtpusknyh: dateVyplatyOtpusknyh ?? this.dateVyplatyOtpusknyh,
    statusVyplaty: statusVyplaty ?? this.statusVyplaty,
  );
}

// ==================== РАСЧЁТ ОТПУСКНЫХ (ДЕТАЛИЗАЦИЯ) ====================
class RaschetOtpusknyh {
  int? id;
  int otpuskId; // FK -> Otpusk
  int sotrudnikId;
  // Расчётный период (12 месяцев до отпуска)
  String periodNachala; // Начало расчётного периода
  String periodOkonchaniya; // Конец расчётного периода
  double summaNachisleniy; // Сумма начислений за расчётный период
  double fakticheskieDni; // Фактически отработанные дни в расчётном периоде
  // Формула: summaNachisleniy / fakticheskieDni = sredniyDnevnoy
  double sredniyDnevnoyZarab; // Средний дневной заработок
  int dniOtpuska; // Количество дней отпуска
  double itogoOtpusknyh; // Итого: sredniyDnevnoyZarab * dniOtpuska
  // Исключаемые периоды
  double isklyuchaemyeDni; // Дни болезни/отпуска без содержания в расч. периоде
  double isklyuchaemyeSummy; // Суммы за исключаемые периоды

  RaschetOtpusknyh({
    this.id,
    this.otpuskId = 0,
    this.sotrudnikId = 0,
    this.periodNachala = '',
    this.periodOkonchaniya = '',
    this.summaNachisleniy = 0.0,
    this.fakticheskieDni = 0.0,
    this.sredniyDnevnoyZarab = 0.0,
    this.dniOtpuska = 0,
    this.itogoOtpusknyh = 0.0,
    this.isklyuchaemyeDni = 0.0,
    this.isklyuchaemyeSummy = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'otpuskId': otpuskId,
    'sotrudnikId': sotrudnikId,
    'periodNachala': periodNachala,
    'periodOkonchaniya': periodOkonchaniya,
    'summaNachisleniy': summaNachisleniy,
    'fakticheskieDni': fakticheskieDni,
    'sredniyDnevnoyZarab': sredniyDnevnoyZarab,
    'dniOtpuska': dniOtpuska,
    'itogoOtpusknyh': itogoOtpusknyh,
    'isklyuchaemyeDni': isklyuchaemyeDni,
    'isklyuchaemyeSummy': isklyuchaemyeSummy,
  };

  factory RaschetOtpusknyh.fromMap(Map<String, dynamic> map) =>
      RaschetOtpusknyh(
        id: map['id'],
        otpuskId: map['otpuskId'] as int? ?? 0,
        sotrudnikId: map['sotrudnikId'] as int? ?? 0,
        periodNachala: map['periodNachala']?.toString() ?? '',
        periodOkonchaniya: map['periodOkonchaniya']?.toString() ?? '',
        summaNachisleniy: (map['summaNachisleniy'] as num?)?.toDouble() ?? 0.0,
        fakticheskieDni: (map['fakticheskieDni'] as num?)?.toDouble() ?? 0.0,
        sredniyDnevnoyZarab:
            (map['sredniyDnevnoyZarab'] as num?)?.toDouble() ?? 0.0,
        dniOtpuska: map['dniOtpuska'] as int? ?? 0,
        itogoOtpusknyh: (map['itogoOtpusknyh'] as num?)?.toDouble() ?? 0.0,
        isklyuchaemyeDni: (map['isklyuchaemyeDni'] as num?)?.toDouble() ?? 0.0,
        isklyuchaemyeSummy:
            (map['isklyuchaemyeSummy'] as num?)?.toDouble() ?? 0.0,
      );

  factory RaschetOtpusknyh.empty() => RaschetOtpusknyh(id: 0);

  RaschetOtpusknyh copyWith({
    int? id,
    int? otpuskId,
    int? sotrudnikId,
    String? periodNachala,
    String? periodOkonchaniya,
    double? summaNachisleniy,
    double? fakticheskieDni,
    double? sredniyDnevnoyZarab,
    int? dniOtpuska,
    double? itogoOtpusknyh,
    double? isklyuchaemyeDni,
    double? isklyuchaemyeSummy,
  }) => RaschetOtpusknyh(
    id: id ?? this.id,
    otpuskId: otpuskId ?? this.otpuskId,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    periodNachala: periodNachala ?? this.periodNachala,
    periodOkonchaniya: periodOkonchaniya ?? this.periodOkonchaniya,
    summaNachisleniy: summaNachisleniy ?? this.summaNachisleniy,
    fakticheskieDni: fakticheskieDni ?? this.fakticheskieDni,
    sredniyDnevnoyZarab: sredniyDnevnoyZarab ?? this.sredniyDnevnoyZarab,
    dniOtpuska: dniOtpuska ?? this.dniOtpuska,
    itogoOtpusknyh: itogoOtpusknyh ?? this.itogoOtpusknyh,
    isklyuchaemyeDni: isklyuchaemyeDni ?? this.isklyuchaemyeDni,
    isklyuchaemyeSummy: isklyuchaemyeSummy ?? this.isklyuchaemyeSummy,
  );
}

// ==================== ПЛАТЁЖНАЯ ВЕДОМОСТЬ (ЗАГОЛОВОК) ====================
class PlatezhVedomost {
  int? id;
  int organizaciyaId;
  int podrazdelenieId; // 0 = по всей организации
  String periodMesyac; // Расчётный месяц (MM.yyyy)
  String vidVyplaty; // 'avans' | 'zarplata' | 'otpusknye' | 'prochee'
  String dateVyplaty; // Дата выплаты
  double itogoPoPerechen; // Итого по ведомости
  String sposobVyplaty; // 'bank' | 'kassa'
  String nomerVedomosti; // Номер документа
  String
  statusVedomosti; // 'chernovik' | 'utverzdena' | 'vyplacena' | 'zakryta'
  String utverdilFio; // Кто утвердил
  String dateUtverzhdeniya; // Дата утверждения
  String primechanie;

  PlatezhVedomost({
    this.id,
    this.organizaciyaId = 0,
    this.podrazdelenieId = 0,
    this.periodMesyac = '',
    this.vidVyplaty = '',
    this.dateVyplaty = '',
    this.itogoPoPerechen = 0.0,
    this.sposobVyplaty = '',
    this.nomerVedomosti = '',
    this.statusVedomosti = '',
    this.utverdilFio = '',
    this.dateUtverzhdeniya = '',
    this.primechanie = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'organizaciyaId': organizaciyaId,
    'podrazdelenieId': podrazdelenieId,
    'periodMesyac': periodMesyac,
    'vidVyplaty': vidVyplaty,
    'dateVyplaty': dateVyplaty,
    'itogoPoPerechen': itogoPoPerechen,
    'sposobVyplaty': sposobVyplaty,
    'nomerVedomosti': nomerVedomosti,
    'statusVedomosti': statusVedomosti,
    'utverdilFio': utverdilFio,
    'dateUtverzhdeniya': dateUtverzhdeniya,
    'primechanie': primechanie,
  };

  factory PlatezhVedomost.fromMap(Map<String, dynamic> map) => PlatezhVedomost(
    id: map['id'],
    organizaciyaId: map['organizaciyaId'] as int? ?? 0,
    podrazdelenieId: map['podrazdelenieId'] as int? ?? 0,
    periodMesyac: map['periodMesyac']?.toString() ?? '',
    vidVyplaty: map['vidVyplaty']?.toString() ?? '',
    dateVyplaty: map['dateVyplaty']?.toString() ?? '',
    itogoPoPerechen: (map['itogoPoPerechen'] as num?)?.toDouble() ?? 0.0,
    sposobVyplaty: map['sposobVyplaty']?.toString() ?? '',
    nomerVedomosti: map['nomerVedomosti']?.toString() ?? '',
    statusVedomosti: map['statusVedomosti']?.toString() ?? '',
    utverdilFio: map['utverdilFio']?.toString() ?? '',
    dateUtverzhdeniya: map['dateUtverzhdeniya']?.toString() ?? '',
    primechanie: map['primechanie']?.toString() ?? '',
  );

  factory PlatezhVedomost.empty() => PlatezhVedomost(id: 0);

  PlatezhVedomost copyWith({
    int? id,
    int? organizaciyaId,
    int? podrazdelenieId,
    String? periodMesyac,
    String? vidVyplaty,
    String? dateVyplaty,
    double? itogoPoPerechen,
    String? sposobVyplaty,
    String? nomerVedomosti,
    String? statusVedomosti,
    String? utverdilFio,
    String? dateUtverzhdeniya,
    String? primechanie,
  }) => PlatezhVedomost(
    id: id ?? this.id,
    organizaciyaId: organizaciyaId ?? this.organizaciyaId,
    podrazdelenieId: podrazdelenieId ?? this.podrazdelenieId,
    periodMesyac: periodMesyac ?? this.periodMesyac,
    vidVyplaty: vidVyplaty ?? this.vidVyplaty,
    dateVyplaty: dateVyplaty ?? this.dateVyplaty,
    itogoPoPerechen: itogoPoPerechen ?? this.itogoPoPerechen,
    sposobVyplaty: sposobVyplaty ?? this.sposobVyplaty,
    nomerVedomosti: nomerVedomosti ?? this.nomerVedomosti,
    statusVedomosti: statusVedomosti ?? this.statusVedomosti,
    utverdilFio: utverdilFio ?? this.utverdilFio,
    dateUtverzhdeniya: dateUtverzhdeniya ?? this.dateUtverzhdeniya,
    primechanie: primechanie ?? this.primechanie,
  );
}

// ==================== СТРОКИ ПЛАТЁЖНОЙ ВЕДОМОСТИ ====================
class PlatezhVedomostStroka {
  int? id;
  int vedomostId; // FK -> PlatezhVedomost
  int sotrudnikId; // FK -> Sotrudniki
  int nomerStroki; // Порядковый номер в ведомости
  double summaNachislena; // Начислено
  double summaUderzhano; // Удержано
  double summaKVyplate; // К выплате
  double summaAvansa; // Ранее выплаченный аванс
  double summaFaktVyplacena; // Фактически выплачено
  String dateVyplaty; // Дата фактической выплаты строки
  String podpis; // Отметка о подписи / получении
  String statusStroki; // 'ozhidaet' | 'vyplacena' | 'otkaz'

  PlatezhVedomostStroka({
    this.id,
    this.vedomostId = 0,
    this.sotrudnikId = 0,
    this.nomerStroki = 0,
    this.summaNachislena = 0.0,
    this.summaUderzhano = 0.0,
    this.summaKVyplate = 0.0,
    this.summaAvansa = 0.0,
    this.summaFaktVyplacena = 0.0,
    this.dateVyplaty = '',
    this.podpis = '',
    this.statusStroki = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'vedomostId': vedomostId,
    'sotrudnikId': sotrudnikId,
    'nomerStroki': nomerStroki,
    'summaNachislena': summaNachislena,
    'summaUderzhano': summaUderzhano,
    'summaKVyplate': summaKVyplate,
    'summaAvansa': summaAvansa,
    'summaFaktVyplacena': summaFaktVyplacena,
    'dateVyplaty': dateVyplaty,
    'podpis': podpis,
    'statusStroki': statusStroki,
  };

  factory PlatezhVedomostStroka.fromMap(Map<String, dynamic> map) =>
      PlatezhVedomostStroka(
        id: map['id'],
        vedomostId: map['vedomostId'] as int? ?? 0,
        sotrudnikId: map['sotrudnikId'] as int? ?? 0,
        nomerStroki: map['nomerStroki'] as int? ?? 0,
        summaNachislena: (map['summaNachislena'] as num?)?.toDouble() ?? 0.0,
        summaUderzhano: (map['summaUderzhano'] as num?)?.toDouble() ?? 0.0,
        summaKVyplate: (map['summaKVyplate'] as num?)?.toDouble() ?? 0.0,
        summaAvansa: (map['summaAvansa'] as num?)?.toDouble() ?? 0.0,
        summaFaktVyplacena:
            (map['summaFaktVyplacena'] as num?)?.toDouble() ?? 0.0,
        dateVyplaty: map['dateVyplaty']?.toString() ?? '',
        podpis: map['podpis']?.toString() ?? '',
        statusStroki: map['statusStroki']?.toString() ?? '',
      );

  factory PlatezhVedomostStroka.empty() => PlatezhVedomostStroka(id: 0);

  PlatezhVedomostStroka copyWith({
    int? id,
    int? vedomostId,
    int? sotrudnikId,
    int? nomerStroki,
    double? summaNachislena,
    double? summaUderzhano,
    double? summaKVyplate,
    double? summaAvansa,
    double? summaFaktVyplacena,
    String? dateVyplaty,
    String? podpis,
    String? statusStroki,
  }) => PlatezhVedomostStroka(
    id: id ?? this.id,
    vedomostId: vedomostId ?? this.vedomostId,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    nomerStroki: nomerStroki ?? this.nomerStroki,
    summaNachislena: summaNachislena ?? this.summaNachislena,
    summaUderzhano: summaUderzhano ?? this.summaUderzhano,
    summaKVyplate: summaKVyplate ?? this.summaKVyplate,
    summaAvansa: summaAvansa ?? this.summaAvansa,
    summaFaktVyplacena: summaFaktVyplacena ?? this.summaFaktVyplacena,
    dateVyplaty: dateVyplaty ?? this.dateVyplaty,
    podpis: podpis ?? this.podpis,
    statusStroki: statusStroki ?? this.statusStroki,
  );
}

// ==================== СВОДНЫЙ АРХИВ ПО МЕСЯЦАМ ====================
// Главная "бухгалтерская книга": одна запись = один сотрудник + один месяц
class ZarplataMesyac {
  int? id;
  int sotrudnikId;
  int god; // Год (например, 2025)
  int mesyac; // Месяц (1–12)
  String periodLabel; // Читаемый лейбл, например "Март 2025"

  // --- НАЧИСЛЕНИЯ ---
  double oklad;
  double premiya;
  double nadbavki;
  double otpusknye;
  double bolnichnye;
  double materialPomosh;
  double inyeNachisleniya;
  double itogoNachisleno;

  // --- УДЕРЖАНИЯ ---
  double ndfl;
  double pfr;
  double foms;
  double fss;
  double alimenty;
  double inyeUderzhaniya;
  double itogoUderzhano;

  // --- ВЫПЛАТЫ ---
  double summaAvansa; // Аванс выплачен
  double summaZarplaty; // Зарплата выплачена (окончательный расчёт)
  double summaOtpusknyh; // Отпускные выплачены
  double itogoVyplaceno; // Всего выплачено за месяц
  double kVyplate; // К выплате (начислено − удержано)
  double dolg; // Остаток долга (если не доплатили)

  // --- СТАТУС ---
  String statusMesyaca; // 'otkryt' | 'zakryt' | 'skorrektirovan'
  String dateZakrytiya; // Дата закрытия месяца

  ZarplataMesyac({
    this.id,
    this.sotrudnikId = 0,
    this.god = 0,
    this.mesyac = 0,
    this.periodLabel = '',
    this.oklad = 0.0,
    this.premiya = 0.0,
    this.nadbavki = 0.0,
    this.otpusknye = 0.0,
    this.bolnichnye = 0.0,
    this.materialPomosh = 0.0,
    this.inyeNachisleniya = 0.0,
    this.itogoNachisleno = 0.0,
    this.ndfl = 0.0,
    this.pfr = 0.0,
    this.foms = 0.0,
    this.fss = 0.0,
    this.alimenty = 0.0,
    this.inyeUderzhaniya = 0.0,
    this.itogoUderzhano = 0.0,
    this.summaAvansa = 0.0,
    this.summaZarplaty = 0.0,
    this.summaOtpusknyh = 0.0,
    this.itogoVyplaceno = 0.0,
    this.kVyplate = 0.0,
    this.dolg = 0.0,
    this.statusMesyaca = '',
    this.dateZakrytiya = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'sotrudnikId': sotrudnikId,
    'god': god,
    'mesyac': mesyac,
    'periodLabel': periodLabel,
    'oklad': oklad,
    'premiya': premiya,
    'nadbavki': nadbavki,
    'otpusknye': otpusknye,
    'bolnichnye': bolnichnye,
    'materialPomosh': materialPomosh,
    'inyeNachisleniya': inyeNachisleniya,
    'itogoNachisleno': itogoNachisleno,
    'ndfl': ndfl,
    'pfr': pfr,
    'foms': foms,
    'fss': fss,
    'alimenty': alimenty,
    'inyeUderzhaniya': inyeUderzhaniya,
    'itogoUderzhano': itogoUderzhano,
    'summaAvansa': summaAvansa,
    'summaZarplaty': summaZarplaty,
    'summaOtpusknyh': summaOtpusknyh,
    'itogoVyplaceno': itogoVyplaceno,
    'kVyplate': kVyplate,
    'dolg': dolg,
    'statusMesyaca': statusMesyaca,
    'dateZakrytiya': dateZakrytiya,
  };

  factory ZarplataMesyac.fromMap(Map<String, dynamic> map) => ZarplataMesyac(
    id: map['id'],
    sotrudnikId: map['sotrudnikId'] as int? ?? 0,
    god: map['god'] as int? ?? 0,
    mesyac: map['mesyac'] as int? ?? 0,
    periodLabel: map['periodLabel']?.toString() ?? '',
    oklad: (map['oklad'] as num?)?.toDouble() ?? 0.0,
    premiya: (map['premiya'] as num?)?.toDouble() ?? 0.0,
    nadbavki: (map['nadbavki'] as num?)?.toDouble() ?? 0.0,
    otpusknye: (map['otpusknye'] as num?)?.toDouble() ?? 0.0,
    bolnichnye: (map['bolnichnye'] as num?)?.toDouble() ?? 0.0,
    materialPomosh: (map['materialPomosh'] as num?)?.toDouble() ?? 0.0,
    inyeNachisleniya: (map['inyeNachisleniya'] as num?)?.toDouble() ?? 0.0,
    itogoNachisleno: (map['itogoNachisleno'] as num?)?.toDouble() ?? 0.0,
    ndfl: (map['ndfl'] as num?)?.toDouble() ?? 0.0,
    pfr: (map['pfr'] as num?)?.toDouble() ?? 0.0,
    foms: (map['foms'] as num?)?.toDouble() ?? 0.0,
    fss: (map['fss'] as num?)?.toDouble() ?? 0.0,
    alimenty: (map['alimenty'] as num?)?.toDouble() ?? 0.0,
    inyeUderzhaniya: (map['inyeUderzhaniya'] as num?)?.toDouble() ?? 0.0,
    itogoUderzhano: (map['itogoUderzhano'] as num?)?.toDouble() ?? 0.0,
    summaAvansa: (map['summаAvansa'] as num?)?.toDouble() ?? 0.0,
    summaZarplaty: (map['summaZarplaty'] as num?)?.toDouble() ?? 0.0,
    summaOtpusknyh: (map['summaOtpusknyh'] as num?)?.toDouble() ?? 0.0,
    itogoVyplaceno: (map['itogoVyplaceno'] as num?)?.toDouble() ?? 0.0,
    kVyplate: (map['kVyplate'] as num?)?.toDouble() ?? 0.0,
    dolg: (map['dolg'] as num?)?.toDouble() ?? 0.0,
    statusMesyaca: map['statusMesyaca']?.toString() ?? '',
    dateZakrytiya: map['dateZakrytiya']?.toString() ?? '',
  );

  factory ZarplataMesyac.empty() => ZarplataMesyac(id: 0);

  ZarplataMesyac copyWith({
    int? id,
    int? sotrudnikId,
    int? god,
    int? mesyac,
    String? periodLabel,
    double? oklad,
    double? premiya,
    double? nadbavki,
    double? otpusknye,
    double? bolnichnye,
    double? materialPomosh,
    double? inyeNachisleniya,
    double? itogoNachisleno,
    double? ndfl,
    double? pfr,
    double? foms,
    double? fss,
    double? alimenty,
    double? inyeUderzhaniya,
    double? itogoUderzhano,
    double? summaAvansa,
    double? summaZarplaty,
    double? summaOtpusknyh,
    double? itogoVyplaceno,
    double? kVyplate,
    double? dolg,
    String? statusMesyaca,
    String? dateZakrytiya,
  }) => ZarplataMesyac(
    id: id ?? this.id,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    god: god ?? this.god,
    mesyac: mesyac ?? this.mesyac,
    periodLabel: periodLabel ?? this.periodLabel,
    oklad: oklad ?? this.oklad,
    premiya: premiya ?? this.premiya,
    nadbavki: nadbavki ?? this.nadbavki,
    otpusknye: otpusknye ?? this.otpusknye,
    bolnichnye: bolnichnye ?? this.bolnichnye,
    materialPomosh: materialPomosh ?? this.materialPomosh,
    inyeNachisleniya: inyeNachisleniya ?? this.inyeNachisleniya,
    itogoNachisleno: itogoNachisleno ?? this.itogoNachisleno,
    ndfl: ndfl ?? this.ndfl,
    pfr: pfr ?? this.pfr,
    foms: foms ?? this.foms,
    fss: fss ?? this.fss,
    alimenty: alimenty ?? this.alimenty,
    inyeUderzhaniya: inyeUderzhaniya ?? this.inyeUderzhaniya,
    itogoUderzhano: itogoUderzhano ?? this.itogoUderzhano,
    summaAvansa: summaAvansa ?? this.summaAvansa,
    summaZarplaty: summaZarplaty ?? this.summaZarplaty,
    summaOtpusknyh: summaOtpusknyh ?? this.summaOtpusknyh,
    itogoVyplaceno: itogoVyplaceno ?? this.itogoVyplaceno,
    kVyplate: kVyplate ?? this.kVyplate,
    dolg: dolg ?? this.dolg,
    statusMesyaca: statusMesyaca ?? this.statusMesyaca,
    dateZakrytiya: dateZakrytiya ?? this.dateZakrytiya,
  );
}

// ==================== СВОДНЫЙ АРХИВ ПО ГОДАМ ====================
// Агрегат по году: одна запись = один сотрудник + один год (для справок 2-НДФЛ и т.д.)
class ZarplataGod {
  int? id;
  int sotrudnikId;
  int god;

  // Годовые итоги начислений
  double itogoNachislenoZaGod;
  double itogoOkladZaGod;
  double itogoPremiyZaGod;
  double itogoOtpusknykhZaGod;
  double itogoBolnichnyhZaGod;

  // Годовые итоги удержаний
  double itogoNdflZaGod;
  double itogoPfrZaGod;
  double itogoFomsZaGod;
  double itogoFssZaGod;
  double itogoUderzhanoZaGod;

  // Годовые итоги выплат
  double itogoVyplachenoZaGod;
  double itogoAvansovZaGod;

  // Для 2-НДФЛ / справок
  double nalogBaza; // Налоговая база (начислено − вычеты)
  double primenenyeVychety; // Применённые вычеты за год
  double ndflIschisl; // НДФЛ исчисленный
  double ndflUderzhanyy; // НДФЛ удержанный
  double ndflPerechislennyy; // НДФЛ перечисленный в бюджет

  ZarplataGod({
    this.id,
    this.sotrudnikId = 0,
    this.god = 0,
    this.itogoNachislenoZaGod = 0.0,
    this.itogoOkladZaGod = 0.0,
    this.itogoPremiyZaGod = 0.0,
    this.itogoOtpusknykhZaGod = 0.0,
    this.itogoBolnichnyhZaGod = 0.0,
    this.itogoNdflZaGod = 0.0,
    this.itogoPfrZaGod = 0.0,
    this.itogoFomsZaGod = 0.0,
    this.itogoFssZaGod = 0.0,
    this.itogoUderzhanoZaGod = 0.0,
    this.itogoVyplachenoZaGod = 0.0,
    this.itogoAvansovZaGod = 0.0,
    this.nalogBaza = 0.0,
    this.primenenyeVychety = 0.0,
    this.ndflIschisl = 0.0,
    this.ndflUderzhanyy = 0.0,
    this.ndflPerechislennyy = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'sotrudnikId': sotrudnikId,
    'god': god,
    'itogoNachislenoZaGod': itogoNachislenoZaGod,
    'itogoOkladZaGod': itogoOkladZaGod,
    'itogoPremiyZaGod': itogoPremiyZaGod,
    'itogoOtpusknykhZaGod': itogoOtpusknykhZaGod,
    'itogoBolnichnyhZaGod': itogoBolnichnyhZaGod,
    'itogoNdflZaGod': itogoNdflZaGod,
    'itogoPfrZaGod': itogoPfrZaGod,
    'itogoFomsZaGod': itogoFomsZaGod,
    'itogoFssZaGod': itogoFssZaGod,
    'itogoUderzhanoZaGod': itogoUderzhanoZaGod,
    'itogoVyplachenoZaGod': itogoVyplachenoZaGod,
    'itogoAvansovZaGod': itogoAvansovZaGod,
    'nalogBaza': nalogBaza,
    'primenenyeVychety': primenenyeVychety,
    'ndflIschisl': ndflIschisl,
    'ndflUderzhanyy': ndflUderzhanyy,
    'ndflPerechislennyy': ndflPerechislennyy,
  };

  factory ZarplataGod.fromMap(Map<String, dynamic> map) => ZarplataGod(
    id: map['id'],
    sotrudnikId: map['sotrudnikId'] as int? ?? 0,
    god: map['god'] as int? ?? 0,
    itogoNachislenoZaGod:
        (map['itogoNachislenoZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoOkladZaGod: (map['itogoOkladZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoPremiyZaGod: (map['itogoPremiyZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoOtpusknykhZaGod:
        (map['itogoOtpusknykhZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoBolnichnyhZaGod:
        (map['itogoBolnichnyhZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoNdflZaGod: (map['itogoNdflZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoPfrZaGod: (map['itogoPfrZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoFomsZaGod: (map['itogoFomsZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoFssZaGod: (map['itogoFssZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoUderzhanoZaGod:
        (map['itogoUderzhanoZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoVyplachenoZaGod:
        (map['itogoVyplachenoZaGod'] as num?)?.toDouble() ?? 0.0,
    itogoAvansovZaGod: (map['itogoAvansovZaGod'] as num?)?.toDouble() ?? 0.0,
    nalogBaza: (map['nalogBaza'] as num?)?.toDouble() ?? 0.0,
    primenenyeVychety: (map['primenenyeVychety'] as num?)?.toDouble() ?? 0.0,
    ndflIschisl: (map['ndflIschisl'] as num?)?.toDouble() ?? 0.0,
    ndflUderzhanyy: (map['ndflUderzhanyy'] as num?)?.toDouble() ?? 0.0,
    ndflPerechislennyy: (map['ndflPerechislennyy'] as num?)?.toDouble() ?? 0.0,
  );

  factory ZarplataGod.empty() => ZarplataGod(id: 0);

  ZarplataGod copyWith({
    int? id,
    int? sotrudnikId,
    int? god,
    double? itogoNachislenoZaGod,
    double? itogoOkladZaGod,
    double? itogoPremiyZaGod,
    double? itogoOtpusknykhZaGod,
    double? itogoBolnichnyhZaGod,
    double? itogoNdflZaGod,
    double? itogoPfrZaGod,
    double? itogoFomsZaGod,
    double? itogoFssZaGod,
    double? itogoUderzhanoZaGod,
    double? itogoVyplachenoZaGod,
    double? itogoAvansovZaGod,
    double? nalogBaza,
    double? primenenyeVychety,
    double? ndflIschisl,
    double? ndflUderzhanyy,
    double? ndflPerechislennyy,
  }) => ZarplataGod(
    id: id ?? this.id,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    god: god ?? this.god,
    itogoNachislenoZaGod: itogoNachislenoZaGod ?? this.itogoNachislenoZaGod,
    itogoOkladZaGod: itogoOkladZaGod ?? this.itogoOkladZaGod,
    itogoPremiyZaGod: itogoPremiyZaGod ?? this.itogoPremiyZaGod,
    itogoOtpusknykhZaGod: itogoOtpusknykhZaGod ?? this.itogoOtpusknykhZaGod,
    itogoBolnichnyhZaGod: itogoBolnichnyhZaGod ?? this.itogoBolnichnyhZaGod,
    itogoNdflZaGod: itogoNdflZaGod ?? this.itogoNdflZaGod,
    itogoPfrZaGod: itogoPfrZaGod ?? this.itogoPfrZaGod,
    itogoFomsZaGod: itogoFomsZaGod ?? this.itogoFomsZaGod,
    itogoFssZaGod: itogoFssZaGod ?? this.itogoFssZaGod,
    itogoUderzhanoZaGod: itogoUderzhanoZaGod ?? this.itogoUderzhanoZaGod,
    itogoVyplachenoZaGod: itogoVyplachenoZaGod ?? this.itogoVyplachenoZaGod,
    itogoAvansovZaGod: itogoAvansovZaGod ?? this.itogoAvansovZaGod,
    nalogBaza: nalogBaza ?? this.nalogBaza,
    primenenyeVychety: primenenyeVychety ?? this.primenenyeVychety,
    ndflIschisl: ndflIschisl ?? this.ndflIschisl,
    ndflUderzhanyy: ndflUderzhanyy ?? this.ndflUderzhanyy,
    ndflPerechislennyy: ndflPerechislennyy ?? this.ndflPerechislennyy,
  );
}

// ==================== РАСЧЁТНЫЙ ЛИСТОК ====================
// Формируется из ZarplataMesyac — хранит снапшот для печати/выдачи сотруднику
class RaschetnyListok {
  int? id;
  int sotrudnikId;
  int zarplataMesyacId; // FK -> ZarplataMesyac (источник данных)
  int god;
  int mesyac;
  String periodLabel; // "Март 2025"
  String dateFomirovaniya; // Дата формирования листка

  // Данные сотрудника на момент формирования (снапшот)
  String sotrudnikFio;
  String dolzhnost;
  String podrazdelenie;
  double tarifnayaStavka; // Оклад/тарифная ставка

  // Начислено
  double oklad;
  double premiya;
  double nadbavki;
  double otpusknye;
  double bolnichnye;
  double materialPomosh;
  double inyeNachisleniya;
  double itogoNachisleno;

  // Удержано
  double ndfl;
  double pfr;
  double foms;
  double fss;
  double alimenty;
  double inyeUderzhaniya;
  double itogoUderzhano;

  // Выплачено / к выплате
  double avansVyplachenRanee;
  double kVyplate;
  double faktVyplaceno;
  double dolg; // Долг организации перед сотрудником или наоборот

  // Служебное
  bool vydanSotrudniku; // Листок выдан сотруднику
  String dateVydachi;

  RaschetnyListok({
    this.id,
    this.sotrudnikId = 0,
    this.zarplataMesyacId = 0,
    this.god = 0,
    this.mesyac = 0,
    this.periodLabel = '',
    this.dateFomirovaniya = '',
    this.sotrudnikFio = '',
    this.dolzhnost = '',
    this.podrazdelenie = '',
    this.tarifnayaStavka = 0.0,
    this.oklad = 0.0,
    this.premiya = 0.0,
    this.nadbavki = 0.0,
    this.otpusknye = 0.0,
    this.bolnichnye = 0.0,
    this.materialPomosh = 0.0,
    this.inyeNachisleniya = 0.0,
    this.itogoNachisleno = 0.0,
    this.ndfl = 0.0,
    this.pfr = 0.0,
    this.foms = 0.0,
    this.fss = 0.0,
    this.alimenty = 0.0,
    this.inyeUderzhaniya = 0.0,
    this.itogoUderzhano = 0.0,
    this.avansVyplachenRanee = 0.0,
    this.kVyplate = 0.0,
    this.faktVyplaceno = 0.0,
    this.dolg = 0.0,
    this.vydanSotrudniku = false,
    this.dateVydachi = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id ?? 0,
    'sotrudnikId': sotrudnikId,
    'zarplataMesyacId': zarplataMesyacId,
    'god': god,
    'mesyac': mesyac,
    'periodLabel': periodLabel,
    'dateFomirovaniya': dateFomirovaniya,
    'sotrudnikFio': sotrudnikFio,
    'dolzhnost': dolzhnost,
    'podrazdelenie': podrazdelenie,
    'tarifnayaStavka': tarifnayaStavka,
    'oklad': oklad,
    'premiya': premiya,
    'nadbavki': nadbavki,
    'otpusknye': otpusknye,
    'bolnichnye': bolnichnye,
    'materialPomosh': materialPomosh,
    'inyeNachisleniya': inyeNachisleniya,
    'itogoNachisleno': itogoNachisleno,
    'ndfl': ndfl,
    'pfr': pfr,
    'foms': foms,
    'fss': fss,
    'alimenty': alimenty,
    'inyeUderzhaniya': inyeUderzhaniya,
    'itogoUderzhano': itogoUderzhano,
    'avansVyplachenRanee': avansVyplachenRanee,
    'kVyplate': kVyplate,
    'faktVyplaceno': faktVyplaceno,
    'dolg': dolg,
    'vydanSotrudniku': vydanSotrudniku ? 1 : 0,
    'dateVydachi': dateVydachi,
  };

  factory RaschetnyListok.fromMap(Map<String, dynamic> map) => RaschetnyListok(
    id: map['id'],
    sotrudnikId: map['sotrudnikId'] as int? ?? 0,
    zarplataMesyacId: map['zarplataMesyacId'] as int? ?? 0,
    god: map['god'] as int? ?? 0,
    mesyac: map['mesyac'] as int? ?? 0,
    periodLabel: map['periodLabel']?.toString() ?? '',
    dateFomirovaniya: map['dateFomirovaniya']?.toString() ?? '',
    sotrudnikFio: map['sotrudnikFio']?.toString() ?? '',
    dolzhnost: map['dolzhnost']?.toString() ?? '',
    podrazdelenie: map['podrazdelenie']?.toString() ?? '',
    tarifnayaStavka: (map['tarifnayaStavka'] as num?)?.toDouble() ?? 0.0,
    oklad: (map['oklad'] as num?)?.toDouble() ?? 0.0,
    premiya: (map['premiya'] as num?)?.toDouble() ?? 0.0,
    nadbavki: (map['nadbavki'] as num?)?.toDouble() ?? 0.0,
    otpusknye: (map['otpusknye'] as num?)?.toDouble() ?? 0.0,
    bolnichnye: (map['bolnichnye'] as num?)?.toDouble() ?? 0.0,
    materialPomosh: (map['materialPomosh'] as num?)?.toDouble() ?? 0.0,
    inyeNachisleniya: (map['inyeNachisleniya'] as num?)?.toDouble() ?? 0.0,
    itogoNachisleno: (map['itogoNachisleno'] as num?)?.toDouble() ?? 0.0,
    ndfl: (map['ndfl'] as num?)?.toDouble() ?? 0.0,
    pfr: (map['pfr'] as num?)?.toDouble() ?? 0.0,
    foms: (map['foms'] as num?)?.toDouble() ?? 0.0,
    fss: (map['fss'] as num?)?.toDouble() ?? 0.0,
    alimenty: (map['alimenty'] as num?)?.toDouble() ?? 0.0,
    inyeUderzhaniya: (map['inyeUderzhaniya'] as num?)?.toDouble() ?? 0.0,
    itogoUderzhano: (map['itogoUderzhano'] as num?)?.toDouble() ?? 0.0,
    avansVyplachenRanee:
        (map['avansVyplachenRanee'] as num?)?.toDouble() ?? 0.0,
    kVyplate: (map['kVyplate'] as num?)?.toDouble() ?? 0.0,
    faktVyplaceno: (map['faktVyplaceno'] as num?)?.toDouble() ?? 0.0,
    dolg: (map['dolg'] as num?)?.toDouble() ?? 0.0,
    vydanSotrudniku: (map['vydanSotrudniku'] as int? ?? 0) == 1,
    dateVydachi: map['dateVydachi']?.toString() ?? '',
  );

  factory RaschetnyListok.empty() => RaschetnyListok(id: 0);

  RaschetnyListok copyWith({
    int? id,
    int? sotrudnikId,
    int? zarplataMesyacId,
    int? god,
    int? mesyac,
    String? periodLabel,
    String? dateFomirovaniya,
    String? sotrudnikFio,
    String? dolzhnost,
    String? podrazdelenie,
    double? tarifnayaStavka,
    double? oklad,
    double? premiya,
    double? nadbavki,
    double? otpusknye,
    double? bolnichnye,
    double? materialPomosh,
    double? inyeNachisleniya,
    double? itogoNachisleno,
    double? ndfl,
    double? pfr,
    double? foms,
    double? fss,
    double? alimenty,
    double? inyeUderzhaniya,
    double? itogoUderzhano,
    double? avansVyplachenRanee,
    double? kVyplate,
    double? faktVyplaceno,
    double? dolg,
    bool? vydanSotrudniku,
    String? dateVydachi,
  }) => RaschetnyListok(
    id: id ?? this.id,
    sotrudnikId: sotrudnikId ?? this.sotrudnikId,
    zarplataMesyacId: zarplataMesyacId ?? this.zarplataMesyacId,
    god: god ?? this.god,
    mesyac: mesyac ?? this.mesyac,
    periodLabel: periodLabel ?? this.periodLabel,
    dateFomirovaniya: dateFomirovaniya ?? this.dateFomirovaniya,
    sotrudnikFio: sotrudnikFio ?? this.sotrudnikFio,
    dolzhnost: dolzhnost ?? this.dolzhnost,
    podrazdelenie: podrazdelenie ?? this.podrazdelenie,
    tarifnayaStavka: tarifnayaStavka ?? this.tarifnayaStavka,
    oklad: oklad ?? this.oklad,
    premiya: premiya ?? this.premiya,
    nadbavki: nadbavki ?? this.nadbavki,
    otpusknye: otpusknye ?? this.otpusknye,
    bolnichnye: bolnichnye ?? this.bolnichnye,
    materialPomosh: materialPomosh ?? this.materialPomosh,
    inyeNachisleniya: inyeNachisleniya ?? this.inyeNachisleniya,
    itogoNachisleno: itogoNachisleno ?? this.itogoNachisleno,
    ndfl: ndfl ?? this.ndfl,
    pfr: pfr ?? this.pfr,
    foms: foms ?? this.foms,
    fss: fss ?? this.fss,
    alimenty: alimenty ?? this.alimenty,
    inyeUderzhaniya: inyeUderzhaniya ?? this.inyeUderzhaniya,
    itogoUderzhano: itogoUderzhano ?? this.itogoUderzhano,
    avansVyplachenRanee: avansVyplachenRanee ?? this.avansVyplachenRanee,
    kVyplate: kVyplate ?? this.kVyplate,
    faktVyplaceno: faktVyplaceno ?? this.faktVyplaceno,
    dolg: dolg ?? this.dolg,
    vydanSotrudniku: vydanSotrudniku ?? this.vydanSotrudniku,
    dateVydachi: dateVydachi ?? this.dateVydachi,
  );
}
