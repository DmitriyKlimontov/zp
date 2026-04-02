// lib/services/documents/pdf_generator.dart

import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'doc_models.dart';

class PdfGenerator {
  // ── Кэш ByteData шрифтов ─────────────────────────────────────
  // ВАЖНО: pw.Font.ttf() принимает ByteData, НЕ Uint8List.
  // Конвертация через .buffer.asUint8List() ломает метрики шрифта
  // и вызывает «буквы в куче» при печати.
  pw.Font? _fontRegular;
  pw.Font? _fontBold;
  pw.Font? _fontItalic;

  Future<void> _loadFonts() async {
    if (_fontRegular != null) return;
    dev.log('[PdfGenerator] Загрузка шрифтов из assets...', name: 'DocGen');
    try {
      // rootBundle.load возвращает ByteData — именно его и передаём в ttf()
      final regular = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final bold = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      final italic = await rootBundle.load('assets/fonts/Roboto-Italic.ttf');

      _fontRegular = pw.Font.ttf(regular); // ByteData напрямую ✓
      _fontBold = pw.Font.ttf(bold);
      _fontItalic = pw.Font.ttf(italic);

      dev.log(
        '[PdfGenerator] Шрифты загружены: '
        'regular=${regular.lengthInBytes}b, '
        'bold=${bold.lengthInBytes}b, '
        'italic=${italic.lengthInBytes}b',
        name: 'DocGen',
      );
    } catch (e, stack) {
      dev.log(
        '[PdfGenerator] ОШИБКА загрузки шрифтов: $e\n'
        'Убедитесь что файлы Roboto-Regular/Bold/Italic.ttf '
        'находятся в assets/fonts/ и прописаны в pubspec.yaml',
        name: 'DocGen',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  // ── Генерация ─────────────────────────────────────────────────

  Future<DocGenerationResult> generateTrudovoyDogovor(
    TrudovoyDogovorData data,
  ) async {
    dev.log(
      '[PdfGenerator] Начало генерации. Сотрудник: ${data.sotFio}',
      name: 'DocGen',
    );
    try {
      await _loadFonts();

      // ThemeData применяет шрифт ко всему документу глобально
      final theme = pw.ThemeData.withFont(
        base: _fontRegular!,
        bold: _fontBold!,
        italic: _fontItalic!,
        boldItalic: _fontBold!, // fallback для bold+italic
      );

      final pdf = pw.Document(theme: theme);
      dev.log('[PdfGenerator] pw.Document создан', name: 'DocGen');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(
            horizontal: 25 * PdfPageFormat.mm,
            vertical: 20 * PdfPageFormat.mm,
          ),
          build: (ctx) => [
            _buildHeader(data),
            pw.SizedBox(height: 12),
            _buildParties(data),
            _buildSection('1. ПРЕДМЕТ ДОГОВОРА', _subjectItems(data)),
            _buildSection('2. СРОК ДОГОВОРА', _termItems(data)),
            _buildSection('3. УСЛОВИЯ ТРУДА', _workConditionItems(data)),
            _buildSection(
              '4. РАБОЧЕЕ ВРЕМЯ И ВРЕМЯ ОТДЫХА',
              _workTimeItems(data),
            ),
            _buildSection('5. ОПЛАТА ТРУДА', _salaryItems(data)),
            _buildSection('6. РЕКВИЗИТЫ СТОРОН', _requisitesItems(data)),
            pw.SizedBox(height: 20),
            _buildSignatures(data),
          ],
        ),
      );

      final file = await _tempFile(
        'trudovoy_dogovor_${data.sotFamiliya}_'
        '${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      dev.log(
        '[PdfGenerator] PDF сохранён: ${file.path} '
        '(${pdfBytes.length} байт)',
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

  // ── Блоки документа ──────────────────────────────────────────

  pw.Widget _buildHeader(TrudovoyDogovorData d) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'ТРУДОВОЙ ДОГОВОР',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        if (d.nomerDogovora.isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            '№ ${d.nomerDogovora}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Flexible(
              child: pw.Text(
                d.orgYuridicheskiyAdres.isNotEmpty
                    ? d.orgYuridicheskiyAdres.split(',').first
                    : '',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            pw.Text(
              '«${d.dateSostavleniya}»',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        pw.Divider(),
        pw.SizedBox(height: 4),
      ],
    );
  }

  pw.Widget _buildParties(TrudovoyDogovorData d) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.RichText(
          text: pw.TextSpan(
            style: const pw.TextStyle(fontSize: 9.5),
            children: [
              pw.TextSpan(
                text: '${d.orgNazvanie} ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9.5,
                ),
              ),
              pw.TextSpan(
                text:
                    'в лице ${d.orgDirektorFio}, действующего на '
                    'основании Устава, именуемое в дальнейшем '
                    '«Работодатель», с одной стороны, и ',
              ),
              pw.TextSpan(
                text: '${d.sotFio} ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9.5,
                ),
              ),
              pw.TextSpan(
                text:
                    'именуемый в дальнейшем «Работник», с другой '
                    'стороны, заключили настоящий трудовой договор:',
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 6),
      ],
    );
  }

  pw.Widget _buildSection(String title, List<pw.Widget> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 8),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        ...items,
      ],
    );
  }

  pw.Widget _item(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
  );

  List<pw.Widget> _subjectItems(TrudovoyDogovorData d) => [
    _item('1.1. Должность: ${d.dolzhnostNazvanie}'),
    _item('1.2. Подразделение: ${d.podrazdelenie}'),
    _item('1.3. Место работы: ${d.orgFakticheskiyAdres}'),
    _item('1.4. Дата начала: ${d.sotDatePriema}'),
  ];

  List<pw.Widget> _termItems(TrudovoyDogovorData d) => [
    _item('2.1. Договор заключён на неопределённый срок.'),
    _item('2.2. Испытательный срок устанавливается соглашением сторон.'),
  ];

  List<pw.Widget> _workConditionItems(TrudovoyDogovorData d) => [
    _item('3.1. Условия труда: ${d.uslTrudaNazvanie}'),
    _item('3.2. Класс условий труда: ${d.uslKlassUslTruda}'),
  ];

  List<pw.Widget> _workTimeItems(TrudovoyDogovorData d) => [
    _item('4.1. Режим: ${d.normirovanieLabel}'),
    _item('4.2. График: ${d.uslGraficRaboty}'),
    _item('4.3. Часов в смене: ${d.uslChasovVSmene} ч.'),
    _item(
      '4.4. Начало: ${d.uslVrNachalaRaboty}  '
      'Окончание: ${d.uslVrOkonchaniyaRaboty}',
    ),
    _item('4.5. ${d.obedLabel}'),
    if (d.uslChasovVechernih > 0)
      _item('4.6. Вечерних часов: ${d.uslChasovVechernih} ч.'),
    if (d.uslChasovNochnykh > 0)
      _item('4.7. Ночных часов: ${d.uslChasovNochnykh} ч.'),
  ];

  List<pw.Widget> _salaryItems(TrudovoyDogovorData d) => [
    _item('5.1. Оклад: ${d.okladMin.toStringAsFixed(0)} руб.'),
    if (d.okladMax > d.okladMin)
      _item(
        '5.2. Максимальный оклад: '
        '${d.okladMax.toStringAsFixed(0)} руб.',
      ),
    _item('5.3. Выплата — два раза в месяц.'),
  ];

  List<pw.Widget> _requisitesItems(TrudovoyDogovorData d) => [
    _item('РАБОТОДАТЕЛЬ: ${d.orgNazvanie}'),
    _item('  ИНН: ${d.orgInn}  КПП: ${d.orgKpp}  ОГРН: ${d.orgOgrn}'),
    _item('  ${d.orgYuridicheskiyAdres}'),
    _item('  ${d.orgBankName}'),
    _item(
      '  р/с: ${d.orgBankRS}  к/с: ${d.orgBankKS}  '
      'БИК: ${d.orgBankBIK}',
    ),
    pw.SizedBox(height: 4),
    _item('РАБОТНИК: ${d.sotFio}'),
    _item(
      '  Дата рождения: ${d.sotDateBirth}  '
      'Место: ${d.sotMestoBirth}',
    ),
    _item(
      '  Паспорт: ${d.sotPasportSeria} ${d.sotPasportNomer}, '
      'выдан: ${d.sotPasportVidan} ${d.sotPasportVidanDateTime}',
    ),
    _item('  Код подразделения: ${d.sotPasportKodPodrazdeleniya}'),
    _item('  Адрес: ${d.sotAdresRegistr}'),
    _item('  ИНН: ${d.sotInn}  СНИЛС: ${d.sotSnils}'),
    _item('  ${d.sotBankName}'),
    _item(
      '  р/с: ${d.sotBankRS}  к/с: ${d.sotBankKS}  '
      'БИК: ${d.sotBankBIK}',
    ),
  ];

  pw.Widget _buildSignatures(TrudovoyDogovorData d) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'РАБОТОДАТЕЛЬ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            ),
            pw.SizedBox(height: 2),
            pw.Text(d.orgDirektorFio, style: const pw.TextStyle(fontSize: 8.5)),
            pw.SizedBox(height: 28),
            pw.Text(
              '________________  /  ${d.orgDirektorFio}',
              style: const pw.TextStyle(fontSize: 8.5),
            ),
            pw.Text('М.П.', style: const pw.TextStyle(fontSize: 8.5)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'РАБОТНИК',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            ),
            pw.SizedBox(height: 2),
            pw.Text(d.sotFio, style: const pw.TextStyle(fontSize: 8.5)),
            pw.SizedBox(height: 28),
            pw.Text(
              '________________  /  ${d.sotFioShort}',
              style: const pw.TextStyle(fontSize: 8.5),
            ),
          ],
        ),
      ],
    );
  }

  Future<File> _tempFile(String filename) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/$filename');
  }
}
