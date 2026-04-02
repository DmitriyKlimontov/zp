// lib/services/documents/pdf_generator.dart
//
// Генератор PDF на базе syncfusion_flutter_pdf: ^33.1.46
// Шрифт Roboto-Regular.ttf встраивается в PDF как подмножество (subset),
// поэтому принтер не может его подменить своим шрифтом.

import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'doc_models.dart';

class PdfGenerator {
  // ── Кэш шрифтов ──────────────────────────────────────────────
  PdfFont? _fontNormal;
  PdfFont? _fontBold;
  PdfFont? _fontSmall;
  PdfFont? _fontTiny;

  /// Загружает Roboto из assets и создаёт шрифты разных размеров.
  /// PdfTrueTypeFont с subsetEmbedding: true встраивает только
  /// использованные глифы — принтер не может подменить шрифт.
  Future<void> _loadFonts() async {
    if (_fontNormal != null) return;
    try {
      // Загружаем Regular
      final ByteData dataReg = await rootBundle.load(
        'assets/fonts/Roboto-Regular.ttf',
      );
      final Uint8List bytesReg = dataReg.buffer.asUint8List();

      // Загружаем Bold (скачайте и добавьте этот файл в ассеты!)
      final ByteData dataBold = await rootBundle.load(
        'assets/fonts/Roboto-Bold.ttf',
      );
      final Uint8List bytesBold = dataBold.buffer.asUint8List();

      // Создаем объекты без программной модификации стиля
      _fontNormal = PdfTrueTypeFont(bytesReg, 10);
      _fontSmall = PdfTrueTypeFont(bytesReg, 9);
      _fontTiny = PdfTrueTypeFont(bytesReg, 8);

      // Для жирного используем файл Bold
      _fontBold = PdfTrueTypeFont(bytesBold, 10);
    } catch (e) {
      dev.log('[PdfGenerator] Ошибка загрузки шрифтов: $e');
      rethrow;
    }
  }

  // ── Главный метод ─────────────────────────────────────────────

  Future<DocGenerationResult> generateTrudovoyDogovor(
    TrudovoyDogovorData data,
  ) async {
    dev.log(
      '[PdfGenerator] Начало генерации. Сотрудник: ${data.sotFio}',
      name: 'DocGen',
    );
    try {
      await _loadFonts();

      final PdfDocument document = PdfDocument();
      // Параметры страницы A4
      document.pageSettings.size = PdfPageSize.a4;
      document.pageSettings.margins
        ..left = 25
        ..right = 20
        ..top = 20
        ..bottom = 20;

      // Все страницы генерируются через _ContentWriter
      final writer = _ContentWriter(
        document: document,
        data: data,
        normal: _fontNormal!,
        bold: _fontBold!,
        small: _fontSmall!,
        tiny: _fontTiny!,
      );
      writer.write();

      // Сохраняем
      final List<int> bytes = await document.save();
      document.dispose();

      final file = await _tempFile(
        'trudovoy_dogovor_${data.sotFamiliya}_'
        '${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);

      dev.log(
        '[PdfGenerator] PDF сохранён: ${file.path} '
        '(${bytes.length} байт)',
        name: 'DocGen',
      );
      return DocGenerationResult(success: true, filePath: file.path);
    } catch (e, stack) {
      dev.log(
        '[PdfGenerator] ОШИБКА: $e',
        name: 'DocGen',
        error: e,
        stackTrace: stack,
      );
      return DocGenerationResult(
        success: false,
        filePath: '',
        error: e.toString(),
      );
    }
  }

  Future<File> _tempFile(String filename) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/$filename');
  }
}

// ─────────────────────────────────────────────────────────────────
// Вспомогательный класс: пишет весь контент на страницы документа
// ─────────────────────────────────────────────────────────────────

class _ContentWriter {
  final PdfDocument document;
  final TrudovoyDogovorData data;
  final PdfFont normal;
  final PdfFont bold;
  final PdfFont small;
  final PdfFont tiny;

  String _clean(String text) {
    if (text.isEmpty) return '';
    return text
        .replaceAll('\u00A0', ' ') // Неразрывный пробел -> обычный
        .replaceAll('\u2013', '-') // Длинное тире -> обычное
        .replaceAll('\u2014', '-')
        .replaceAll('№', 'N') // Символ номера -> N
        .trim();
  }

  // Текущая позиция по Y
  double _y = 0;
  late PdfPage _page;
  late PdfGraphics _g;

  // Ширина рабочей области (A4 = 595 - 25 - 20 = 550)
  static const double _w = 550;
  static const double _lineH = 14; // межстрочный интервал

  _ContentWriter({
    required this.document,
    required this.data,
    required this.normal,
    required this.bold,
    required this.small,
    required this.tiny,
  });

  void _drawRequisitesTable() {
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 2);
    grid.columns[0].width = 275;
    grid.columns[1].width = 275;

    final PdfGridCellStyle headerStyle = PdfGridCellStyle();
    headerStyle.font = bold;
    headerStyle.cellPadding = PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    headerStyle.borders.all = PdfPen(PdfColor(0, 0, 0), width: 0.5);

    final PdfGridCellStyle dataStyle = PdfGridCellStyle();
    dataStyle.font = small;
    dataStyle.cellPadding = PdfPaddings(left: 5, right: 5, top: 5, bottom: 5);
    dataStyle.borders.all = PdfPen(PdfColor(0, 0, 0), width: 0.5);

    // Строка заголовков
    final PdfGridRow headerRow = grid.rows.add();
    headerRow.cells[0].value = 'РАБОТОДАТЕЛЬ';
    headerRow.cells[1].value = 'РАБОТНИК';
    headerRow.cells[0].style = headerStyle;
    headerRow.cells[1].style = headerStyle;

    // Строка данных
    final PdfGridRow dataRow = grid.rows.add();
    dataRow.cells[0].value = _clean(
      '${data.orgNazvanie}\n'
      'ИНН: ${data.orgInn}  КПП: ${data.orgKpp}\n'
      'Адрес: ${data.orgYuridicheskiyAdres}\n'
      '${data.orgBankName}\n'
      'р/с: ${data.orgBankRS}\n'
      'БИК: ${data.orgBankBIK}',
    );

    dataRow.cells[1].value = _clean(
      'ФИО: ${data.sotFio}\n'
      'Паспорт: ${data.sotPasportSeria} ${data.sotPasportNomer}\n'
      'Выдан: ${data.sotPasportVidan}\n'
      'Адрес: ${data.sotAdresRegistr}\n'
      'ИНН: ${data.sotInn}  СНИЛС: ${data.sotSnils}\n'
      'р/с: ${data.sotBankRS}',
    );

    dataRow.cells[0].style = dataStyle;
    dataRow.cells[1].style = dataStyle;

    final PdfLayoutResult result = grid.draw(
      page: _page,
      bounds: Rect.fromLTWH(0, _y, _w, 0),
    )!;

    _y = result.bounds.bottom + 15;
    _page = result.page; // Важно, если таблица перенеслась на новую страницу
    _g = _page.graphics;
  }

  void write() {
    _newPage();

    // ── Заголовок ─────────────────────────────────────────────
    _centerText('ТРУДОВОЙ ДОГОВОР', bold);

    // Логика: если номера нет — просто пробел (сохраняем отступ).
    // Если есть — выводим через латинскую 'N', чтобы избежать проблем с символом '№'
    final String docNum = data.nomerDogovora.trim();
    _centerText(docNum.isNotEmpty ? 'N $docNum' : ' ', normal);
    _ln();

    // Город и дата
    final city = data.orgYuridicheskiyAdres.isNotEmpty
        ? data.orgYuridicheskiyAdres.split(',').first.trim()
        : '';
    _twoColumns(_clean(city), '«${_clean(data.dateSostavleniya)}»', small);
    _hline();
    _ln();

    // ── Преамбула ──────────────────────────────────────────────
    _paragraph(
      '${_clean(data.orgNazvanie)}, в лице ${_clean(data.orgDirektorFio)}, '
      'действующего на основании Устава, именуемое в дальнейшем '
      '«Работодатель», с одной стороны, и ${_clean(data.sotFio)}, '
      'именуемый в дальнейшем «Работник», с другой стороны, '
      'заключили настоящий трудовой договор о нижеследующем:',
      small,
    );
    _ln();

    // ── Разделы 1–5 ───────────────────────────────────────────
    _section('1. ПРЕДМЕТ ДОГОВОРА');
    _bullet('1.1. Должность: ${_clean(data.dolzhnostNazvanie)}');
    _bullet('1.2. Подразделение: ${_clean(data.podrazdelenie)}');
    _bullet('1.3. Место работы: ${_clean(data.orgFakticheskiyAdres)}');
    _bullet('1.4. Дата начала работы: ${_clean(data.sotDatePriema)}');

    _section('2. СРОК ДОГОВОРА');
    _bullet('2.1. Трудовой договор заключён на неопределённый срок.');
    _bullet('2.2. Испытательный срок устанавливается соглашением сторон.');

    _section('3. УСЛОВИЯ ТРУДА');
    _bullet('3.1. Условия труда: ${_clean(data.uslTrudaNazvanie)}');
    _bullet('3.2. Класс условий труда: ${_clean(data.uslKlassUslTruda)}');

    _section('4. РАБОЧЕЕ ВРЕМЯ И ВРЕМЯ ОТДЫХА');
    _bullet('4.1. Режим рабочего времени: ${_clean(data.normirovanieLabel)}');
    _bullet('4.2. График работы: ${_clean(data.uslGraficRaboty)}');
    _bullet('4.3. Продолжительность смены: ${data.uslChasovVSmene} ч.');
    _bullet(
      '4.4. Начало: ${data.uslVrNachalaRaboty}  Окончание: ${data.uslVrOkonchaniyaRaboty}',
    );
    _bullet('4.5. ${_clean(data.obedLabel)}');

    _section('5. ОПЛАТА ТРУДА');
    _bullet('5.1. Должностной оклад: ${data.okladMin.toStringAsFixed(0)} руб.');
    _bullet('5.2. Заработная плата выплачивается два раза в месяц.');

    // ── Раздел 6: РЕКВИЗИТЫ (Только таблица) ────────────────────
    _section('6. РЕКВИЗИТЫ СТОРОН');
    _drawRequisitesTable();

    // ── Подписи ───────────────────────────────────────────────
    _ln();
    _ln();
    _signatures();
  }

  // ── Вспомогательные методы рисования ─────────────────────────

  void _newPage() {
    _page = document.pages.add();
    _g = _page.graphics;
    _y = 0;
  }

  /// Проверяет что влезет ещё [need] пунктов, иначе новая страница
  void _checkSpace(double need) {
    if (_y + need > _page.getClientSize().height - 10) {
      _newPage();
    }
  }

  void _text(String text, PdfFont font, {double indent = 0}) {
    _checkSpace(_lineH + 2);
    _g.drawString(
      text,
      font,
      bounds: Rect.fromLTWH(indent, _y, _w - indent, _lineH * 3),
      format: PdfStringFormat(wordWrap: PdfWordWrapType.word, lineSpacing: 2),
    );
    // Вычисляем реальную высоту текста
    final measured = font.measureString(
      text,
      layoutArea: Size(_w - indent, double.infinity),
    );
    _y += measured.height + 3;
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

  void _paragraph(String text, PdfFont font) {
    _text(text, font);
  }

  void _section(String title) {
    _checkSpace(_lineH + 4);
    _y += 6;
    _text(title, bold);
    _y += 2;
  }

  void _bullet(String text) {
    _text(text, small, indent: 10);
  }

  void _signatures() {
    _checkSpace(60);
    const colW = 240.0;
    const col2X = 300.0;

    // Заголовки колонок
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

    // ФИО
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
    _y += _lineH + 24; // место для подписи

    // Линии подписи
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

    // Расшифровки
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

    // М.П.
    _g.drawString('М.П.', small, bounds: Rect.fromLTWH(0, _y, 40, _lineH));
  }
}
