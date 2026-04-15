import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:zp/services/generators/generator_models.dart';
import 'td_data.dart';

// Печатный ШАБЛОН Трудового договора

class TdPdfGenerator {
  PdfFont? _fontNormal;
  PdfFont? _fontBold;
  PdfFont? _fontSmall;
  PdfFont? _fontTiny;

  Future<void> _loadFonts() async {
    if (_fontNormal != null) return;
    dev.log('[TdPdfGenerator] Загрузка шрифта...', name: 'DocGen');
    try {
      final ByteData data = await rootBundle.load(
        'assets/fonts/Roboto-Regular.ttf',
      );
      final Uint8List bytes = data.buffer.asUint8List();
      _fontNormal = PdfTrueTypeFont(
        bytes,
        10,
        style: PdfFontStyle.regular,
        multiStyle: [],
        //subsetEmbedding: true,
      );
      _fontBold = PdfTrueTypeFont(
        bytes,
        10,
        style: PdfFontStyle.bold,
        multiStyle: [],
        //subsetEmbedding: true,
      );
      _fontSmall = PdfTrueTypeFont(
        bytes,
        9,
        style: PdfFontStyle.regular,
        multiStyle: [],
        //subsetEmbedding: true,
      );
      _fontTiny = PdfTrueTypeFont(
        bytes,
        8,
        style: PdfFontStyle.regular,
        multiStyle: [],
        //subsetEmbedding: true,
      );
      dev.log(
        '[TdPdfGenerator] Шрифт загружен: ${bytes.length} байт',
        name: 'DocGen',
      );
    } catch (e, stack) {
      dev.log(
        '[TdPdfGenerator] ОШИБКА загрузки шрифта: $e',
        name: 'DocGen',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<GeneratorResult> generate(TrudovoyDogovorData data) async {
    dev.log(
      '[TdPdfGenerator] Генерация. Сотрудник: ${data.sotFio}',
      name: 'DocGen',
    );
    try {
      await _loadFonts();

      final doc = PdfDocument();
      doc.pageSettings.size = PdfPageSize.a4;
      doc.pageSettings.margins
        ..left = 25
        ..right = 20
        ..top = 20
        ..bottom = 20;

      _TdContentWriter(
        document: doc,
        data: data,
        normal: _fontNormal!,
        bold: _fontBold!,
        small: _fontSmall!,
        tiny: _fontTiny!,
      ).write();

      final List<int> bytes = await doc.save();
      doc.dispose();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/trudovoy_dogovor_${data.sotFamiliya}_'
        '${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);

      dev.log(
        '[TdPdfGenerator] Сохранён: ${file.path} (${bytes.length} байт)',
        name: 'DocGen',
      );
      return GeneratorResult(success: true, filePath: file.path);
    } catch (e, stack) {
      dev.log(
        '[TdPdfGenerator] ОШИБКА: $e',
        name: 'DocGen',
        error: e,
        stackTrace: stack,
      );
      return GeneratorResult(success: false, filePath: '', error: e.toString());
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// ContentWriter — рисует содержимое документа
// ─────────────────────────────────────────────────────────────────

class _TdContentWriter {
  final PdfDocument document;
  final TrudovoyDogovorData data;
  final PdfFont normal;
  final PdfFont bold;
  final PdfFont small;
  final PdfFont tiny;

  double _y = 0;
  late PdfPage _page;
  late PdfGraphics _g;

  static const double _w = 550;
  static const double _lineH = 14;

  _TdContentWriter({
    required this.document,
    required this.data,
    required this.normal,
    required this.bold,
    required this.small,
    required this.tiny,
  });

  void write() {
    _newPage();

    _centerText('ТРУДОВОЙ ДОГОВОР', bold);
    if (data.nomerDogovora.isNotEmpty) {
      _centerText('№ ${data.nomerDogovora}', normal);
    }
    _ln();

    final city = data.orgYuridicheskiyAdres.isNotEmpty
        ? data.orgYuridicheskiyAdres.split(',').first.trim()
        : '';
    _twoColumns(city, '«${data.dateSostavleniya}»', small);
    _hline();
    _ln();

    _paragraph(
      '${data.orgNazvanie}, в лице ${data.orgDirektorFio}, '
      'действующего на основании Устава, именуемое в дальнейшем '
      '«Работодатель», с одной стороны, и ${data.sotFio}, '
      'именуемый в дальнейшем «Работник», с другой стороны, '
      'заключили настоящий трудовой договор о нижеследующем:',
      small,
    );
    _ln();

    _section('1. ПРЕДМЕТ ДОГОВОРА');
    _bullet('1.1. Должность: ${data.dolzhnostNazvanie}');
    _bullet('1.2. Подразделение: ${data.podrazdelenie}');
    _bullet('1.3. Место работы: ${data.orgFakticheskiyAdres}');
    _bullet('1.4. Дата начала работы: ${data.sotDatePriema}');

    _section('2. СРОК ДОГОВОРА');
    _bullet('2.1. Трудовой договор заключён на неопределённый срок.');
    _bullet('2.2. ${data.ispSrokLabel}');

    _section('3. УСЛОВИЯ ТРУДА');
    _bullet('3.1. Условия труда: ${data.uslTrudaNazvanie}');
    _bullet('3.2. Класс условий труда: ${data.uslKlassUslTruda}');

    _section('4. РАБОЧЕЕ ВРЕМЯ И ВРЕМЯ ОТДЫХА');
    _bullet('4.1. Режим рабочего времени: ${data.normirovanieLabel}');
    _bullet('4.2. График работы: ${data.uslGraficRaboty}');
    _bullet('4.3. Продолжительность смены: ${data.uslChasovVSmene} ч.');
    _bullet(
      '4.4. Начало: ${data.uslVrNachalaRaboty}  '
      'Окончание: ${data.uslVrOkonchaniyaRaboty}',
    );
    _bullet('4.5. ${data.obedLabel}');
    if (data.uslChasovVechernih > 0) {
      _bullet(
        '4.6. Вечерних часов: ${data.uslChasovVechernih} ч. (18:00–22:00)',
      );
    }
    if (data.uslChasovNochnykh > 0) {
      _bullet('4.7. Ночных часов: ${data.uslChasovNochnykh} ч. (22:00–06:00)');
    }

    _section('5. ОПЛАТА ТРУДА');
    _bullet('5.1. Форма оплаты труда: ${data.tipoplatyLabel}.');
    _bullet('5.2. ${data.oplatyLabel}');
    _bullet('5.3. Заработная плата выплачивается два раза в месяц.');

    _section('6. РЕКВИЗИТЫ СТОРОН');
    _text('РАБОТОДАТЕЛЬ:', bold);
    _bullet('${data.orgNazvanie}');
    _bullet('ИНН: ${data.orgInn}  КПП: ${data.orgKpp}  ОГРН: ${data.orgOgrn}');
    _bullet('Адрес: ${data.orgYuridicheskiyAdres}');
    _bullet('${data.orgBankName}');
    _bullet('р/с: ${data.orgBankRS}');
    _bullet('к/с: ${data.orgBankKS}  БИК: ${data.orgBankBIK}');
    _ln();

    _text('РАБОТНИК:', bold);
    _bullet('ФИО: ${data.sotFio}');
    _bullet(
      'Дата рождения: ${data.sotDateBirth}  Место: ${data.sotMestoBirth}',
    );
    _bullet(
      'Паспорт: ${data.sotPasportSeria} ${data.sotPasportNomer}, '
      'выдан: ${data.sotPasportVidan} ${data.sotPasportVidanDateTime}',
    );
    _bullet('Код подразделения: ${data.sotPasportKodPodrazdeleniya}');
    _bullet('Адрес: ${data.sotAdresRegistr}');
    _bullet('ИНН: ${data.sotInn}  СНИЛС: ${data.sotSnils}');
    _bullet('${data.sotBankName}');
    _bullet('р/с: ${data.sotBankRS}');
    _bullet('к/с: ${data.sotBankKS}  БИК: ${data.sotBankBIK}');

    _ln();
    _ln();
    _signatures();
  }

  void _newPage() {
    _page = document.pages.add();
    _g = _page.graphics;
    _y = 0;
  }

  void _checkSpace(double need) {
    if (_y + need > _page.getClientSize().height - 10) _newPage();
  }

  void _text(String text, PdfFont font, {double indent = 0}) {
    _checkSpace(_lineH + 2);
    _g.drawString(
      text,
      font,
      bounds: Rect.fromLTWH(indent, _y, _w - indent, _lineH * 4),
      format: PdfStringFormat(wordWrap: PdfWordWrapType.word, lineSpacing: 2),
    );
    final sz = font.measureString(
      text,
      layoutArea: Size(_w - indent, double.infinity),
    );
    _y += sz.height + 3;
  }

  void _centerText(String text, PdfFont font) {
    _checkSpace(_lineH + 2);
    _g.drawString(
      text,
      font,
      bounds: Rect.fromLTWH(0, _y, _w, _lineH),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    _y += _lineH + 2;
  }

  void _twoColumns(String left, String right, PdfFont font) {
    _checkSpace(_lineH);
    _g.drawString(left, font, bounds: Rect.fromLTWH(0, _y, _w * 0.6, _lineH));
    _g.drawString(
      right,
      font,
      bounds: Rect.fromLTWH(_w * 0.7, _y, _w * 0.3, _lineH),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    _y += _lineH + 2;
  }

  void _hline() {
    _g.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 0.5),
      Offset(0, _y),
      Offset(_w, _y),
    );
    _y += 4;
  }

  void _ln() {
    _y += 5;
  }

  void _paragraph(String text, PdfFont font) => _text(text, font);

  void _section(String title) {
    _checkSpace(_lineH + 4);
    _y += 6;
    _text(title, bold);
    _y += 2;
  }

  void _bullet(String text) => _text(text, small, indent: 10);

  void _signatures() {
    _checkSpace(60);
    const colW = 240.0;
    const col2X = 300.0;

    _g.drawString(
      'РАБОТОДАТЕЛЬ',
      bold,
      bounds: Rect.fromLTWH(0, _y, colW, _lineH),
    );
    _g.drawString(
      'РАБОТНИК',
      bold,
      bounds: Rect.fromLTWH(col2X, _y, colW, _lineH),
    );
    _y += _lineH + 2;

    _g.drawString(
      data.orgDirektorFio,
      small,
      bounds: Rect.fromLTWH(0, _y, colW, _lineH),
    );
    _g.drawString(
      data.sotFio,
      small,
      bounds: Rect.fromLTWH(col2X, _y, colW, _lineH),
    );
    _y += _lineH + 24;

    _g.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 0.5),
      Offset(0, _y),
      Offset(140, _y),
    );
    _g.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 0.5),
      Offset(col2X, _y),
      Offset(col2X + 140, _y),
    );
    _y += 4;

    _g.drawString(
      '/ ${data.orgDirektorFio}',
      tiny,
      bounds: Rect.fromLTWH(145, _y - 4, colW - 145, _lineH),
    );
    _g.drawString(
      '/ ${data.sotFioShort}',
      tiny,
      bounds: Rect.fromLTWH(col2X + 145, _y - 4, colW - 145, _lineH),
    );
    _y += _lineH;

    _g.drawString('М.П.', small, bounds: Rect.fromLTWH(0, _y, 40, _lineH));
  }
}
