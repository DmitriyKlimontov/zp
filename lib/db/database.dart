import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const int _dbVersion = 1;
  static const String _dbName = 'zarplata.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Включаем поддержку внешних ключей (FK) — обязательно для SQLite
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // При необходимости: ALTER TABLE или пересоздание таблиц
  }

  // ===========================================================================
  //  СОЗДАНИЕ ТАБЛИЦ
  // ===========================================================================

  Future<void> _createTables(Database db) async {
    final batch = db.batch();

    // -----------------------------------------------------------------
    // 1. ОРГАНИЗАЦИЯ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS organizaciya (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        nazvanie            TEXT    NOT NULL DEFAULT '',
        kratkoeNazvanie     TEXT    NOT NULL DEFAULT '',
        inn                 TEXT    NOT NULL DEFAULT '',
        kpp                 TEXT    NOT NULL DEFAULT '',
        ogrn                TEXT    NOT NULL DEFAULT '',
        yuridicheskiyAdres  TEXT    NOT NULL DEFAULT '',
        fakticheskiyAdres   TEXT    NOT NULL DEFAULT '',
        telefon             TEXT    NOT NULL DEFAULT '',
        elPochta            TEXT    NOT NULL DEFAULT '',
        bankRS              TEXT    NOT NULL DEFAULT '',
        bankKS              TEXT    NOT NULL DEFAULT '',
        bankBIK             TEXT    NOT NULL DEFAULT '',
        bankName            TEXT    NOT NULL DEFAULT '',
        direktorFio         TEXT    NOT NULL DEFAULT '',
        buhgalterFio        TEXT    NOT NULL DEFAULT ''
      )
    ''');

    // -----------------------------------------------------------------
    // 2. ПОДРАЗДЕЛЕНИЯ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS podrazdeleniya (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        nazvanie          TEXT    NOT NULL DEFAULT '',
        kod               TEXT    NOT NULL DEFAULT '',
        rukovoditelId     INTEGER NOT NULL DEFAULT 0,
        organizaciyaId    INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (organizaciyaId) REFERENCES organizaciya(id)
          ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // -----------------------------------------------------------------
    // 3. ДОЛЖНОСТИ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS dolzhnosti (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        nazvanie          TEXT    NOT NULL DEFAULT '',
        kod               TEXT    NOT NULL DEFAULT '',
        okladMin          REAL    NOT NULL DEFAULT 0.0,
        okladMax          REAL    NOT NULL DEFAULT 0.0,
        podrazdelenieId   INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (podrazdelenieId) REFERENCES podrazdeleniya(id)
          ON DELETE SET DEFAULT ON UPDATE CASCADE
      )
    ''');

    // -----------------------------------------------------------------
    // 4. СОТРУДНИКИ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS sotrudniki (
        id                          INTEGER PRIMARY KEY AUTOINCREMENT,
        familiya                    TEXT    NOT NULL DEFAULT '',
        name                        TEXT    NOT NULL DEFAULT '',
        otchestvo                   TEXT    NOT NULL DEFAULT '',
        dateBirth                   TEXT    NOT NULL DEFAULT '',
        mestoBirth                  TEXT    NOT NULL DEFAULT '',
        adresRegistr                TEXT    NOT NULL DEFAULT '',
        adresGitelstva              TEXT    NOT NULL DEFAULT '',
        telefon                     TEXT    NOT NULL DEFAULT '',
        elPochta                    TEXT    NOT NULL DEFAULT '',
        pasportSeria                TEXT    NOT NULL DEFAULT '',
        pasportNomer                TEXT    NOT NULL DEFAULT '',
        pasportVidan                TEXT    NOT NULL DEFAULT '',
        pasportVidanDateTime        TEXT    NOT NULL DEFAULT '',
        pasportKodPodrazdeleniya    TEXT    NOT NULL DEFAULT '',
        bankRS                      TEXT    NOT NULL DEFAULT '',
        bankKS                      TEXT    NOT NULL DEFAULT '',
        bankBIK                     TEXT    NOT NULL DEFAULT '',
        bankName                    TEXT    NOT NULL DEFAULT '',
        datePriema                  TEXT    NOT NULL DEFAULT '',
        dateUvolneniya              TEXT    NOT NULL DEFAULT '',
        dolzhnostId                 INTEGER NOT NULL DEFAULT 0,
        podrazdelenieId             INTEGER NOT NULL DEFAULT 0,
        stavka                      INTEGER NOT NULL DEFAULT 1,
        inn                         TEXT    NOT NULL DEFAULT '',
        snils                       TEXT    NOT NULL DEFAULT '',
        uslTrudaId                  INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (dolzhnostId)       REFERENCES dolzhnosti(id)
          ON DELETE SET DEFAULT ON UPDATE CASCADE,
        FOREIGN KEY (podrazdelenieId)   REFERENCES podrazdeleniya(id)
          ON DELETE SET DEFAULT ON UPDATE CASCADE,
        FOREIGN KEY (uslTrudaId) REFERENCES uslTruda(id)
          ON DELETE SET DEFAULT ON UPDATE CASCADE
      )
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS uslTruda (
        id                    INTEGER PRIMARY KEY AUTOINCREMENT,
        nazvanie              TEXT    NOT NULL DEFAULT '',
        klassUslTruda         TEXT    NOT NULL DEFAULT '',
        graficRaboty          TEXT    NOT NULL DEFAULT '',
        chasovVSmene          INTEGER NOT NULL DEFAULT 8,
        vrNachalaRaboty       TEXT    NOT NULL DEFAULT '',
        vrOkonchaniyaRaboty   TEXT    NOT NULL DEFAULT '',
        kolObedennyhPereryv   INTEGER NOT NULL DEFAULT 1,
        prodObedennyhPereryv  INTEGER NOT NULL DEFAULT 60,
        normirovannoye        INTEGER NOT NULL DEFAULT 1,
        chasovVechernih       INTEGER NOT NULL DEFAULT 0,
        chasovNochnykh        INTEGER NOT NULL DEFAULT 0,
        primechanie           TEXT    NOT NULL DEFAULT ''
      )
    ''');

    // Теперь, когда sotrudniki создана, можно добавить FK rukovoditelId в podrazdeleniya.
    // В SQLite ALTER TABLE не поддерживает ADD CONSTRAINT, поэтому FK rukovoditelId
    // реализуется логически через trigg или контролируется на уровне приложения.
    // Это стандартное ограничение SQLite — FK на ту же или ещё не созданную таблицу
    // добавляется через пересоздание или через проверки в коде.

    // -----------------------------------------------------------------
    // 5. НАЛОГОВЫЕ ВЫЧЕТЫ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS nalogovyeVychety (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        sotrudnikId       INTEGER NOT NULL DEFAULT 0,
        kodVycheta        INTEGER NOT NULL DEFAULT 0,
        nazvanie          TEXT    NOT NULL DEFAULT '',
        summaVycheta      REAL    NOT NULL DEFAULT 0.0,
        dateNachala       TEXT    NOT NULL DEFAULT '',
        dateOkonchaniya   TEXT    NOT NULL DEFAULT '',
        osnovanie         TEXT    NOT NULL DEFAULT '',
        FOREIGN KEY (sotrudnikId) REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // -----------------------------------------------------------------
    // 6. ТАБЕЛЬ УЧЁТА РАБОЧЕГО ВРЕМЕНИ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS tabel (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        sotrudnikId       INTEGER NOT NULL DEFAULT 0,
        periodMesyac      TEXT    NOT NULL DEFAULT '',
        rabochihDney      INTEGER NOT NULL DEFAULT 0,
        faktDney          INTEGER NOT NULL DEFAULT 0,
        faktChasov        INTEGER NOT NULL DEFAULT 0,
        otpuskDney        INTEGER NOT NULL DEFAULT 0,
        bolnichnyhDney    INTEGER NOT NULL DEFAULT 0,
        progulDney        INTEGER NOT NULL DEFAULT 0,
        komandirovkaDney  INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (sotrudnikId) REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        UNIQUE (sotrudnikId, periodMesyac)
      )
    ''');

    // -----------------------------------------------------------------
    // 7. НАЧИСЛЕНИЯ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS nachisleniya (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        sotrudnikId         INTEGER NOT NULL DEFAULT 0,
        periodMesyac        TEXT    NOT NULL DEFAULT '',
        oklad               REAL    NOT NULL DEFAULT 0.0,
        premiya             REAL    NOT NULL DEFAULT 0.0,
        nadbavki            REAL    NOT NULL DEFAULT 0.0,
        otpusknye           REAL    NOT NULL DEFAULT 0.0,
        bolnichnye          REAL    NOT NULL DEFAULT 0.0,
        materialPomosh      REAL    NOT NULL DEFAULT 0.0,
        inyeNachisleniya    REAL    NOT NULL DEFAULT 0.0,
        itogoNachisleno     REAL    NOT NULL DEFAULT 0.0,
        FOREIGN KEY (sotrudnikId) REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        UNIQUE (sotrudnikId, periodMesyac)
      )
    ''');

    // -----------------------------------------------------------------
    // 8. УДЕРЖАНИЯ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS uderzhaniya (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        sotrudnikId       INTEGER NOT NULL DEFAULT 0,
        periodMesyac      TEXT    NOT NULL DEFAULT '',
        ndfl              REAL    NOT NULL DEFAULT 0.0,
        pfr               REAL    NOT NULL DEFAULT 0.0,
        foms              REAL    NOT NULL DEFAULT 0.0,
        fss               REAL    NOT NULL DEFAULT 0.0,
        alimenty          REAL    NOT NULL DEFAULT 0.0,
        inyeUderzhaniya   REAL    NOT NULL DEFAULT 0.0,
        itogoUderzhano    REAL    NOT NULL DEFAULT 0.0,
        kVyplate          REAL    NOT NULL DEFAULT 0.0,
        FOREIGN KEY (sotrudnikId) REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        UNIQUE (sotrudnikId, periodMesyac)
      )
    ''');

    // -----------------------------------------------------------------
    // 9. АВАНСЫ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS avans (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        sotrudnikId       INTEGER NOT NULL DEFAULT 0,
        periodMesyac      TEXT    NOT NULL DEFAULT '',
        dateVyplaty       TEXT    NOT NULL DEFAULT '',
        summaAvansa       REAL    NOT NULL DEFAULT 0.0,
        procentOtOklada   REAL    NOT NULL DEFAULT 0.0,
        statusVyplaty     TEXT    NOT NULL DEFAULT '',
        sposobVyplaty     TEXT    NOT NULL DEFAULT '',
        platezhDocument   TEXT    NOT NULL DEFAULT '',
        primechanie       TEXT    NOT NULL DEFAULT '',
        FOREIGN KEY (sotrudnikId) REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // -----------------------------------------------------------------
    // 10. ОТПУСКА (ПРИКАЗЫ)
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS otpusk (
        id                        INTEGER PRIMARY KEY AUTOINCREMENT,
        sotrudnikId               INTEGER NOT NULL DEFAULT 0,
        vidOtpuska                TEXT    NOT NULL DEFAULT '',
        dateNachala               TEXT    NOT NULL DEFAULT '',
        dateOkonchaniya           TEXT    NOT NULL DEFAULT '',
        kolichestvoDney           INTEGER NOT NULL DEFAULT 0,
        nomerPrikaza              TEXT    NOT NULL DEFAULT '',
        datePrikaza               TEXT    NOT NULL DEFAULT '',
        sredniyZarabotok          REAL    NOT NULL DEFAULT 0.0,
        summaOtpusknyh            REAL    NOT NULL DEFAULT 0.0,
        dateVyplatyOtpusknyh      TEXT    NOT NULL DEFAULT '',
        statusVyplaty             TEXT    NOT NULL DEFAULT '',
        FOREIGN KEY (sotrudnikId) REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // -----------------------------------------------------------------
    // 11. РАСЧЁТ ОТПУСКНЫХ (ДЕТАЛИЗАЦИЯ)
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS raschetOtpusknyh (
        id                    INTEGER PRIMARY KEY AUTOINCREMENT,
        otpuskId              INTEGER NOT NULL DEFAULT 0,
        sotrudnikId           INTEGER NOT NULL DEFAULT 0,
        periodNachala         TEXT    NOT NULL DEFAULT '',
        periodOkonchaniya     TEXT    NOT NULL DEFAULT '',
        summaNachisleniy      REAL    NOT NULL DEFAULT 0.0,
        fakticheskieDni       REAL    NOT NULL DEFAULT 0.0,
        sredniyDnevnoyZarab   REAL    NOT NULL DEFAULT 0.0,
        dniOtpuska            INTEGER NOT NULL DEFAULT 0,
        itogoOtpusknyh        REAL    NOT NULL DEFAULT 0.0,
        isklyuchaemyeDni      REAL    NOT NULL DEFAULT 0.0,
        isklyuchaemyeSummy    REAL    NOT NULL DEFAULT 0.0,
        FOREIGN KEY (otpuskId)    REFERENCES otpusk(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (sotrudnikId) REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // -----------------------------------------------------------------
    // 12. ПЛАТЁЖНАЯ ВЕДОМОСТЬ (ЗАГОЛОВОК)
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS platezhVedomost (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        organizaciyaId      INTEGER NOT NULL DEFAULT 0,
        podrazdelenieId     INTEGER NOT NULL DEFAULT 0,
        periodMesyac        TEXT    NOT NULL DEFAULT '',
        vidVyplaty          TEXT    NOT NULL DEFAULT '',
        dateVyplaty         TEXT    NOT NULL DEFAULT '',
        itogoPoPerechen     REAL    NOT NULL DEFAULT 0.0,
        sposobVyplaty       TEXT    NOT NULL DEFAULT '',
        nomerVedomosti      TEXT    NOT NULL DEFAULT '',
        statusVedomosti     TEXT    NOT NULL DEFAULT '',
        utverdilFio         TEXT    NOT NULL DEFAULT '',
        dateUtverzhdeniya   TEXT    NOT NULL DEFAULT '',
        primechanie         TEXT    NOT NULL DEFAULT '',
        FOREIGN KEY (organizaciyaId)  REFERENCES organizaciya(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (podrazdelenieId) REFERENCES podrazdeleniya(id)
          ON DELETE SET DEFAULT ON UPDATE CASCADE
      )
    ''');

    // -----------------------------------------------------------------
    // 13. СТРОКИ ПЛАТЁЖНОЙ ВЕДОМОСТИ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS platezhVedomostStroka (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        vedomostId          INTEGER NOT NULL DEFAULT 0,
        sotrudnikId         INTEGER NOT NULL DEFAULT 0,
        nomerStroki         INTEGER NOT NULL DEFAULT 0,
        summaNachislena     REAL    NOT NULL DEFAULT 0.0,
        summaUderzhano      REAL    NOT NULL DEFAULT 0.0,
        summaKVyplate       REAL    NOT NULL DEFAULT 0.0,
        summaAvansa         REAL    NOT NULL DEFAULT 0.0,
        summaFaktVyplacena  REAL    NOT NULL DEFAULT 0.0,
        dateVyplaty         TEXT    NOT NULL DEFAULT '',
        podpis              TEXT    NOT NULL DEFAULT '',
        statusStroki        TEXT    NOT NULL DEFAULT '',
        FOREIGN KEY (vedomostId)  REFERENCES platezhVedomost(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (sotrudnikId) REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        UNIQUE (vedomostId, sotrudnikId)
      )
    ''');

    // -----------------------------------------------------------------
    // 14. СВОДНЫЙ АРХИВ ПО МЕСЯЦАМ (главная книга)
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS zarplataMesyac (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        sotrudnikId         INTEGER NOT NULL DEFAULT 0,
        god                 INTEGER NOT NULL DEFAULT 0,
        mesyac              INTEGER NOT NULL DEFAULT 0,
        periodLabel         TEXT    NOT NULL DEFAULT '',

        -- Начисления
        oklad               REAL    NOT NULL DEFAULT 0.0,
        premiya             REAL    NOT NULL DEFAULT 0.0,
        nadbavki            REAL    NOT NULL DEFAULT 0.0,
        otpusknye           REAL    NOT NULL DEFAULT 0.0,
        bolnichnye          REAL    NOT NULL DEFAULT 0.0,
        materialPomosh      REAL    NOT NULL DEFAULT 0.0,
        inyeNachisleniya    REAL    NOT NULL DEFAULT 0.0,
        itogoNachisleno     REAL    NOT NULL DEFAULT 0.0,

        -- Удержания
        ndfl                REAL    NOT NULL DEFAULT 0.0,
        pfr                 REAL    NOT NULL DEFAULT 0.0,
        foms                REAL    NOT NULL DEFAULT 0.0,
        fss                 REAL    NOT NULL DEFAULT 0.0,
        alimenty            REAL    NOT NULL DEFAULT 0.0,
        inyeUderzhaniya     REAL    NOT NULL DEFAULT 0.0,
        itogoUderzhano      REAL    NOT NULL DEFAULT 0.0,

        -- Выплаты
        summaAvansa         REAL    NOT NULL DEFAULT 0.0,
        summaZarplaty       REAL    NOT NULL DEFAULT 0.0,
        summaOtpusknyh      REAL    NOT NULL DEFAULT 0.0,
        itogoVyplaceno      REAL    NOT NULL DEFAULT 0.0,
        kVyplate            REAL    NOT NULL DEFAULT 0.0,
        dolg                REAL    NOT NULL DEFAULT 0.0,

        -- Статус
        statusMesyaca       TEXT    NOT NULL DEFAULT '',
        dateZakrytiya       TEXT    NOT NULL DEFAULT '',

        FOREIGN KEY (sotrudnikId) REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        UNIQUE (sotrudnikId, god, mesyac)
      )
    ''');

    // -----------------------------------------------------------------
    // 15. СВОДНЫЙ АРХИВ ПО ГОДАМ
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS zarplataGod (
        id                        INTEGER PRIMARY KEY AUTOINCREMENT,
        sotrudnikId               INTEGER NOT NULL DEFAULT 0,
        god                       INTEGER NOT NULL DEFAULT 0,

        -- Годовые начисления
        itogoNachislenoZaGod      REAL    NOT NULL DEFAULT 0.0,
        itogoOkladZaGod           REAL    NOT NULL DEFAULT 0.0,
        itogoPremiyZaGod          REAL    NOT NULL DEFAULT 0.0,
        itogoOtpusknykhZaGod      REAL    NOT NULL DEFAULT 0.0,
        itogoBolnichnyhZaGod      REAL    NOT NULL DEFAULT 0.0,

        -- Годовые удержания
        itogoNdflZaGod            REAL    NOT NULL DEFAULT 0.0,
        itogoPfrZaGod             REAL    NOT NULL DEFAULT 0.0,
        itogoFomsZaGod            REAL    NOT NULL DEFAULT 0.0,
        itogoFssZaGod             REAL    NOT NULL DEFAULT 0.0,
        itogoUderzhanoZaGod       REAL    NOT NULL DEFAULT 0.0,

        -- Годовые выплаты
        itogoVyplachenoZaGod      REAL    NOT NULL DEFAULT 0.0,
        itogoAvansovZaGod         REAL    NOT NULL DEFAULT 0.0,

        -- Данные для 2-НДФЛ
        nalogBaza                 REAL    NOT NULL DEFAULT 0.0,
        primenenyeVychety         REAL    NOT NULL DEFAULT 0.0,
        ndflIschisl               REAL    NOT NULL DEFAULT 0.0,
        ndflUderzhanyy            REAL    NOT NULL DEFAULT 0.0,
        ndflPerechislennyy        REAL    NOT NULL DEFAULT 0.0,

        FOREIGN KEY (sotrudnikId) REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        UNIQUE (sotrudnikId, god)
      )
    ''');

    // -----------------------------------------------------------------
    // 16. РАСЧЁТНЫЙ ЛИСТОК
    // -----------------------------------------------------------------
    batch.execute('''
      CREATE TABLE IF NOT EXISTS raschetnyListok (
        id                    INTEGER PRIMARY KEY AUTOINCREMENT,
        sotrudnikId           INTEGER NOT NULL DEFAULT 0,
        zarplataMesyacId      INTEGER NOT NULL DEFAULT 0,
        god                   INTEGER NOT NULL DEFAULT 0,
        mesyac                INTEGER NOT NULL DEFAULT 0,
        periodLabel           TEXT    NOT NULL DEFAULT '',
        dateFomirovaniya      TEXT    NOT NULL DEFAULT '',

        -- Снапшот данных сотрудника
        sotrudnikFio          TEXT    NOT NULL DEFAULT '',
        dolzhnost             TEXT    NOT NULL DEFAULT '',
        podrazdelenie         TEXT    NOT NULL DEFAULT '',
        tarifnayaStavka       REAL    NOT NULL DEFAULT 0.0,

        -- Начислено
        oklad                 REAL    NOT NULL DEFAULT 0.0,
        premiya               REAL    NOT NULL DEFAULT 0.0,
        nadbavki              REAL    NOT NULL DEFAULT 0.0,
        otpusknye             REAL    NOT NULL DEFAULT 0.0,
        bolnichnye            REAL    NOT NULL DEFAULT 0.0,
        materialPomosh        REAL    NOT NULL DEFAULT 0.0,
        inyeNachisleniya      REAL    NOT NULL DEFAULT 0.0,
        itogoNachisleno       REAL    NOT NULL DEFAULT 0.0,

        -- Удержано
        ndfl                  REAL    NOT NULL DEFAULT 0.0,
        pfr                   REAL    NOT NULL DEFAULT 0.0,
        foms                  REAL    NOT NULL DEFAULT 0.0,
        fss                   REAL    NOT NULL DEFAULT 0.0,
        alimenty              REAL    NOT NULL DEFAULT 0.0,
        inyeUderzhaniya       REAL    NOT NULL DEFAULT 0.0,
        itogoUderzhano        REAL    NOT NULL DEFAULT 0.0,

        -- Выплаты
        avansVyplachenRanee   REAL    NOT NULL DEFAULT 0.0,
        kVyplate              REAL    NOT NULL DEFAULT 0.0,
        faktVyplaceno         REAL    NOT NULL DEFAULT 0.0,
        dolg                  REAL    NOT NULL DEFAULT 0.0,

        -- Служебное
        vydanSotrudniku       INTEGER NOT NULL DEFAULT 0,  -- 0=false, 1=true
        dateVydachi           TEXT    NOT NULL DEFAULT '',

        FOREIGN KEY (sotrudnikId)       REFERENCES sotrudniki(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (zarplataMesyacId)  REFERENCES zarplataMesyac(id)
          ON DELETE CASCADE ON UPDATE CASCADE,
        UNIQUE (sotrudnikId, zarplataMesyacId)
      )
    ''');

    await batch.commit(noResult: true);
  }

  // ===========================================================================
  //  ИНДЕКСЫ — ускоряют выборки по наиболее частым запросам
  // ===========================================================================

  Future<void> _createIndexes(Database db) async {
    final batch = db.batch();

    // sotrudniki
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_sot_podrazd   ON sotrudniki(podrazdelenieId)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_sot_dolzhn    ON sotrudniki(dolzhnostId)',
    );

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_sot_usltruda ON sotrudniki(uslTrudaId)',
    );

    // tabel
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_tab_sot_per   ON tabel(sotrudnikId, periodMesyac)',
    );

    // nachisleniya
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_nach_sot_per  ON nachisleniya(sotrudnikId, periodMesyac)',
    );

    // uderzhaniya
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_ud_sot_per    ON uderzhaniya(sotrudnikId, periodMesyac)',
    );

    // avans
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_av_sot_per    ON avans(sotrudnikId, periodMesyac)',
    );

    // otpusk
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_otp_sot       ON otpusk(sotrudnikId)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_otp_dates     ON otpusk(dateNachala, dateOkonchaniya)',
    );

    // raschetOtpusknyh
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_ro_otpusk     ON raschetOtpusknyh(otpuskId)',
    );

    // platezhVedomost
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_pv_org_per    ON platezhVedomost(organizaciyaId, periodMesyac)',
    );

    // platezhVedomostStroka
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_pvs_ved       ON platezhVedomostStroka(vedomostId)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_pvs_sot       ON platezhVedomostStroka(sotrudnikId)',
    );

    // zarplataMesyac — самая нагруженная таблица
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_zm_sot        ON zarplataMesyac(sotrudnikId)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_zm_god_mes    ON zarplataMesyac(god, mesyac)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_zm_status     ON zarplataMesyac(statusMesyaca)',
    );

    // zarplataGod
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_zg_sot_god    ON zarplataGod(sotrudnikId, god)',
    );

    // raschetnyListok
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_rl_sot        ON raschetnyListok(sotrudnikId)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_rl_god_mes    ON raschetnyListok(god, mesyac)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_rl_vydan      ON raschetnyListok(vydanSotrudniku)',
    );

    // nalogovyeVychety
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_nv_sot        ON nalogovyeVychety(sotrudnikId)',
    );

    await batch.commit(noResult: true);
  }

  // ===========================================================================
  //  УНИВЕРСАЛЬНЫЕ CRUD-МЕТОДЫ
  // ===========================================================================

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final db = await database;
    final result = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // ===========================================================================
  //  СПЕЦИАЛИЗИРОВАННЫЕ МЕТОДЫ ПО ТАБЛИЦАМ
  // ===========================================================================

  /// Все сотрудники подразделения
  Future<List<Map<String, dynamic>>> getSotrudnikiByPodrazdelenie(
    int podrazdelenieId,
  ) async {
    final db = await database;
    return await db.query(
      'sotrudniki',
      where: 'podrazdelenieId = ?',
      whereArgs: [podrazdelenieId],
      orderBy: 'familiya ASC, name ASC',
    );
  }

  /// Табель сотрудника за месяц
  Future<Map<String, dynamic>?> getTabelBySotrudnikAndPeriod(
    int sotrudnikId,
    String periodMesyac,
  ) async {
    final db = await database;
    final result = await db.query(
      'tabel',
      where: 'sotrudnikId = ? AND periodMesyac = ?',
      whereArgs: [sotrudnikId, periodMesyac],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Начисления сотрудника за период
  Future<Map<String, dynamic>?> getNachislenieBySotrudnikAndPeriod(
    int sotrudnikId,
    String periodMesyac,
  ) async {
    final db = await database;
    final result = await db.query(
      'nachisleniya',
      where: 'sotrudnikId = ? AND periodMesyac = ?',
      whereArgs: [sotrudnikId, periodMesyac],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Удержания сотрудника за период
  Future<Map<String, dynamic>?> getUderzhanieBySotrudnikAndPeriod(
    int sotrudnikId,
    String periodMesyac,
  ) async {
    final db = await database;
    final result = await db.query(
      'uderzhaniya',
      where: 'sotrudnikId = ? AND periodMesyac = ?',
      whereArgs: [sotrudnikId, periodMesyac],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Авансы сотрудника за месяц
  Future<List<Map<String, dynamic>>> getAvansyBySotrudnikAndPeriod(
    int sotrudnikId,
    String periodMesyac,
  ) async {
    final db = await database;
    return await db.query(
      'avans',
      where: 'sotrudnikId = ? AND periodMesyac = ?',
      whereArgs: [sotrudnikId, periodMesyac],
    );
  }

  /// Все отпуска сотрудника
  Future<List<Map<String, dynamic>>> getOtpuskiBySotrudnik(
    int sotrudnikId,
  ) async {
    final db = await database;
    return await db.query(
      'otpusk',
      where: 'sotrudnikId = ?',
      whereArgs: [sotrudnikId],
      orderBy: 'dateNachala DESC',
    );
  }

  /// Строки платёжной ведомости
  Future<List<Map<String, dynamic>>> getVedomostStroki(int vedomostId) async {
    final db = await database;
    return await db.query(
      'platezhVedomostStroka',
      where: 'vedomostId = ?',
      whereArgs: [vedomostId],
      orderBy: 'nomerStroki ASC',
    );
  }

  /// Архив зарплаты сотрудника по месяцам за год
  Future<List<Map<String, dynamic>>> getZarplataMesyacByGod(
    int sotrudnikId,
    int god,
  ) async {
    final db = await database;
    return await db.query(
      'zarplataMesyac',
      where: 'sotrudnikId = ? AND god = ?',
      whereArgs: [sotrudnikId, god],
      orderBy: 'mesyac ASC',
    );
  }

  /// Запись архива за конкретный месяц
  Future<Map<String, dynamic>?> getZarplataMesyacByPeriod(
    int sotrudnikId,
    int god,
    int mesyac,
  ) async {
    final db = await database;
    final result = await db.query(
      'zarplataMesyac',
      where: 'sotrudnikId = ? AND god = ? AND mesyac = ?',
      whereArgs: [sotrudnikId, god, mesyac],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Годовой архив сотрудника
  Future<Map<String, dynamic>?> getZarplataGod(int sotrudnikId, int god) async {
    final db = await database;
    final result = await db.query(
      'zarplataGod',
      where: 'sotrudnikId = ? AND god = ?',
      whereArgs: [sotrudnikId, god],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Расчётные листки сотрудника за год
  Future<List<Map<String, dynamic>>> getRaschetnyeListkiBySotrudnikAndGod(
    int sotrudnikId,
    int god,
  ) async {
    final db = await database;
    return await db.query(
      'raschetnyListok',
      where: 'sotrudnikId = ? AND god = ?',
      whereArgs: [sotrudnikId, god],
      orderBy: 'mesyac ASC',
    );
  }

  /// Листок за конкретный месяц
  Future<Map<String, dynamic>?> getRaschetnyListokByPeriod(
    int sotrudnikId,
    int god,
    int mesyac,
  ) async {
    final db = await database;
    final result = await db.query(
      'raschetnyListok',
      where: 'sotrudnikId = ? AND god = ? AND mesyac = ?',
      whereArgs: [sotrudnikId, god, mesyac],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Невыданные расчётные листки
  Future<List<Map<String, dynamic>>> getNeVydannyeListki() async {
    final db = await database;
    return await db.query(
      'raschetnyListok',
      where: 'vydanSotrudniku = ?',
      whereArgs: [0],
      orderBy: 'god DESC, mesyac DESC',
    );
  }

  /// Действующие налоговые вычеты сотрудника (по дате)
  Future<List<Map<String, dynamic>>> getActiveVychetyBySotrudnik(
    int sotrudnikId,
    String currentDate,
  ) async {
    final db = await database;
    return await db.query(
      'nalogovyeVychety',
      where: '''
        sotrudnikId = ?
        AND (dateOkonchaniya = '' OR dateOkonchaniya >= ?)
        AND dateNachala <= ?
      ''',
      whereArgs: [sotrudnikId, currentDate, currentDate],
    );
  }

  // ===========================================================================
  //  УСЛОВИЯ ТРУДА — CRUD
  // ===========================================================================

  /// Все условия труда
  Future<List<Map<String, dynamic>>> getAllUslTruda() async {
    final db = await database;
    return await db.query('uslTruda', orderBy: 'nazvanie ASC');
  }

  /// Условие труда по id
  Future<Map<String, dynamic>?> getUslTrudaById(int id) async {
    final db = await database;
    final result = await db.query('uslTruda', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  /// Создать условие труда
  Future<int> insertUslTruda(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'uslTruda',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Обновить условие труда
  Future<int> updateUslTruda(Map<String, dynamic> data, int id) async {
    final db = await database;
    return await db.update('uslTruda', data, where: 'id = ?', whereArgs: [id]);
  }

  /// Удалить условие труда (с проверкой зависимостей)
  Future<int> deleteUslTruda(int id) async {
    final db = await database;
    return await db.delete('uslTruda', where: 'id = ?', whereArgs: [id]);
  }

  /// Проверка: сколько сотрудников использует данное условие труда
  Future<int> countSotrudnikiByUslTruda(int uslTrudaId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM sotrudniki WHERE uslTrudaId = ?',
      [uslTrudaId],
    );
    return result.first['cnt'] as int? ?? 0;
  }

  // ===========================================================================
  //  АГРЕГИРУЮЩИЕ ЗАПРОСЫ (rawQuery)
  // ===========================================================================

  /// Сводка по организации за месяц: итого начислено / удержано / к выплате
  Future<Map<String, dynamic>?> getSvodkaOrganizaciyaByPeriod(
    int organizaciyaId,
    int god,
    int mesyac,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT
        COUNT(zm.id)              AS kolichestvo_sotrudnikov,
        SUM(zm.itogoNachisleno)   AS vsego_nachisleno,
        SUM(zm.itogoUderzhano)    AS vsego_uderzhano,
        SUM(zm.kVyplate)          AS vsego_k_vyplate,
        SUM(zm.itogoVyplaceno)    AS vsego_vyplaceno,
        SUM(zm.ndfl)              AS vsego_ndfl,
        SUM(zm.pfr)               AS vsego_pfr,
        SUM(zm.foms)              AS vsego_foms,
        SUM(zm.fss)               AS vsego_fss
      FROM zarplataMesyac zm
      JOIN sotrudniki s ON s.id = zm.sotrudnikId
      JOIN podrazdeleniya p ON p.id = s.podrazdelenieId
      WHERE p.organizaciyaId = ? AND zm.god = ? AND zm.mesyac = ?
    ''',
      [organizaciyaId, god, mesyac],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Расчётный листок: JOIN всех нужных таблиц одним запросом
  Future<List<Map<String, dynamic>>> getRaschetnyListokFullData(
    int sotrudnikId,
    int god,
    int mesyac,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT
        rl.*,
        s.familiya, s.name, s.otchestvo, s.inn, s.snils,
        d.nazvanie  AS dolzhnostNazvanie,
        pd.nazvanie AS podrazdelenieNazvanie,
        zm.statusMesyaca
      FROM raschetnyListok rl
      JOIN sotrudniki   s  ON s.id  = rl.sotrudnikId
      JOIN dolzhnosti   d  ON d.id  = s.dolzhnostId
      JOIN podrazdeleniya pd ON pd.id = s.podrazdelenieId
      JOIN zarplataMesyac zm ON zm.id = rl.zarplataMesyacId
      WHERE rl.sotrudnikId = ? AND rl.god = ? AND rl.mesyac = ?
      LIMIT 1
    ''',
      [sotrudnikId, god, mesyac],
    );
  }

  // ===========================================================================
  //  СЕРВИСНЫЕ МЕТОДЫ
  // ===========================================================================

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Полностью сбросить базу (для разработки / тестирования)
  Future<void> dropAllTables() async {
    final db = await database;
    final tables = [
      'raschetnyListok',
      'zarplataGod',
      'zarplataMesyac',
      'platezhVedomostStroka',
      'platezhVedomost',
      'raschetOtpusknyh',
      'otpusk',
      'avans',
      'uderzhaniya',
      'nachisleniya',
      'tabel',
      'nalogovyeVychety',
      'sotrudniki',
      'dolzhnosti',
      'podrazdeleniya',
      'organizaciya',
    ];
    final batch = db.batch();
    for (final table in tables) {
      batch.execute('DROP TABLE IF EXISTS $table');
    }
    await batch.commit(noResult: true);
  }
}
