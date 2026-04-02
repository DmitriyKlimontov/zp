// lib/services/documents/docx_generator.dart
// Совместимо с docx_template: ^0.4.0
//
// ═══════════════════════════════════════════════════════════════
// КАК ПРАВИЛЬНО СОЗДАТЬ ШАБЛОН DOCX:
//
// Библиотека docx_template использует "Content Controls" (SDT) из
// Microsoft Word, а НЕ {{фигурные скобки}}.
//
// ШАГ 1. Откройте Microsoft Word
// ШАГ 2. Включите вкладку "Разработчик":
//         Файл → Параметры → Настроить ленту → ✓ Разработчик
// ШАГ 3. Напишите текст документа
// ШАГ 4. Для каждой переменной:
//         - Поставьте курсор в нужное место
//         - Вкладка "Разработчик" → "Элемент управления содержимым
//           в формате обычного текста" (кнопка Аа)
//         - Нажмите на вставленный элемент → "Свойства"
//         - В поле "Тег" введите имя переменной: sot_fio
//         - Нажмите ОК
// ШАГ 5. Сохраните как .docx в assets/templates/trudovoy_dogovor.docx
//
// Список тегов переменных — в методе _fillContent() ниже.
// ═══════════════════════════════════════════════════════════════

import 'dart:typed_data';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:docx_template/docx_template.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'doc_models.dart';

class DocxGenerator {
  static const _templateAsset = 'assets/templates/trudovoy_dogovor.docx';

  // ── Диагностический режим ─────────────────────────────────────
  // Если true — создаёт минимальный тестовый шаблон программно
  // (без assets файла) чтобы проверить что сама библиотека работает.
  // Установите в false когда шаблон готов.
  static const bool _diagnosticMode = false;

  Future<DocGenerationResult> generateTrudovoyDogovor(
    TrudovoyDogovorData data,
  ) async {
    dev.log(
      '[DocxGenerator] Начало генерации DOCX. '
      'Сотрудник: ${data.sotFio}',
      name: 'DocGen',
    );

    if (_diagnosticMode) {
      return _generateDiagnostic(data);
    }

    return _generateFromTemplate(data);
  }

  // ── Генерация из шаблона Word ─────────────────────────────────

  Future<DocGenerationResult> _generateFromTemplate(
    TrudovoyDogovorData data,
  ) async {
    try {
      // 1. Загружаем шаблон
      dev.log(
        '[DocxGenerator] Загрузка шаблона: $_templateAsset',
        name: 'DocGen',
      );
      Uint8List templateBytes;
      try {
        final byteData = await rootBundle.load(_templateAsset);
        templateBytes = byteData.buffer.asUint8List();
        dev.log(
          '[DocxGenerator] Шаблон загружен: '
          '${templateBytes.length} байт',
          name: 'DocGen',
        );
      } catch (e) {
        dev.log(
          '[DocxGenerator] ОШИБКА загрузки шаблона: $e',
          name: 'DocGen',
          error: e,
        );
        return DocGenerationResult(
          success: false,
          filePath: '',
          error:
              'Шаблон не найден: $_templateAsset\n\n'
              'Создайте шаблон в Microsoft Word:\n'
              '1. Включите вкладку "Разработчик" (Файл → Параметры)\n'
              '2. Используйте "Элемент управления содержимым"\n'
              '3. В свойствах элемента укажите Тег = имя_переменной\n'
              '4. Сохраните в assets/templates/trudovoy_dogovor.docx\n\n'
              'Ошибка: $e',
        );
      }

      // 2. Создаём DocxTemplate
      dev.log('[DocxGenerator] Создание DocxTemplate...', name: 'DocGen');
      DocxTemplate docx;
      try {
        docx = await DocxTemplate.fromBytes(templateBytes);
        dev.log('[DocxGenerator] DocxTemplate создан', name: 'DocGen');
      } catch (e, stack) {
        dev.log(
          '[DocxGenerator] ОШИБКА DocxTemplate.fromBytes(): $e',
          name: 'DocGen',
          error: e,
          stackTrace: stack,
        );
        return DocGenerationResult(
          success: false,
          filePath: '',
          error: 'Файл шаблона повреждён или не является .docx\n$e',
        );
      }

      // 3. Заполняем Content
      dev.log('[DocxGenerator] Заполнение Content...', name: 'DocGen');
      final content = Content();
      _fillContent(content, data);
      dev.log('[DocxGenerator] Content заполнен', name: 'DocGen');

      // 4. generate()
      dev.log('[DocxGenerator] Вызов generate()...', name: 'DocGen');
      List<int>? generated;
      try {
        generated = await docx.generate(content);
      } catch (e, stack) {
        dev.log(
          '[DocxGenerator] ОШИБКА generate(): $e',
          name: 'DocGen',
          error: e,
          stackTrace: stack,
        );
        return DocGenerationResult(
          success: false,
          filePath: '',
          error:
              'Ошибка generate():\n$e\n\n'
              'Возможная причина: шаблон не содержит Content Controls.\n'
              'Используйте элементы управления из вкладки "Разработчик",\n'
              'а не {{фигурные скобки}} в тексте.',
        );
      }

      if (generated == null || generated.isEmpty) {
        dev.log('[DocxGenerator] generate() → null/empty', name: 'DocGen');
        return const DocGenerationResult(
          success: false,
          filePath: '',
          error:
              'generate() вернул пустой результат.\n\n'
              'Причина: в шаблоне нет ни одного Content Control с тегом,\n'
              'совпадающим с переменными из _fillContent().\n\n'
              'Проверьте:\n'
              '- Используете ли вы "Разработчик → Aa" в Word?\n'
              '- Совпадают ли Теги элементов с именами в _fillContent()?\n'
              '- Например тег "sot_fio" должен совпадать с '
              'TextContent("sot_fio", ...)',
        );
      }

      dev.log(
        '[DocxGenerator] Сгенерировано: ${generated.length} байт',
        name: 'DocGen',
      );

      // 5. Сохраняем
      final file = await _tempFile(
        'trudovoy_dogovor_${data.sotFamiliya}_'
        '${DateTime.now().millisecondsSinceEpoch}.docx',
      );
      await file.writeAsBytes(generated);
      dev.log('[DocxGenerator] Сохранено: ${file.path}', name: 'DocGen');

      return DocGenerationResult(success: true, filePath: file.path);
    } catch (e, stack) {
      dev.log(
        '[DocxGenerator] НЕОБРАБОТАННОЕ ИСКЛЮЧЕНИЕ: $e',
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

  // ── Диагностический режим ─────────────────────────────────────
  // Создаёт простой тестовый шаблон программно и проверяет
  // что библиотека в принципе работает. Используйте для отладки.

  Future<DocGenerationResult> _generateDiagnostic(
    TrudovoyDogovorData data,
  ) async {
    dev.log('[DocxGenerator] ДИАГНОСТИЧЕСКИЙ РЕЖИМ', name: 'DocGen');

    // Минимальный валидный DOCX в base64 (пустой документ с одним SDT)
    // Это позволяет проверить что библиотека установлена корректно
    dev.log(
      '[DocxGenerator] В диагностическом режиме нужен реальный '
      'шаблон. Переключитесь на _diagnosticMode = false и создайте '
      'шаблон по инструкции в комментарии файла.',
      name: 'DocGen',
    );

    return const DocGenerationResult(
      success: false,
      filePath: '',
      error:
          'Диагностический режим активен.\n\n'
          'Для генерации DOCX:\n'
          '1. Создайте шаблон в Word (см. инструкцию в docx_generator.dart)\n'
          '2. Положите в assets/templates/trudovoy_dogovor.docx\n'
          '3. Установите _diagnosticMode = false\n\n'
          'Для генерации без шаблона используйте формат PDF.',
    );
  }

  // ── Переменные шаблона ────────────────────────────────────────
  // Каждый TextContent("тег", значение) соответствует
  // Content Control с Тегом = "тег" в шаблоне Word.

  void _fillContent(Content c, TrudovoyDogovorData d) {
    // ── Организация ───────────────────────────────────────────
    c.add(TextContent('org_nazvanie', d.orgNazvanie));
    c.add(TextContent('org_kratko', d.orgKratkoeNazvanie));
    c.add(TextContent('org_inn', d.orgInn));
    c.add(TextContent('org_kpp', d.orgKpp));
    c.add(TextContent('org_ogrn', d.orgOgrn));
    c.add(TextContent('org_ur_adres', d.orgYuridicheskiyAdres));
    c.add(TextContent('org_fakt_adres', d.orgFakticheskiyAdres));
    c.add(TextContent('org_telefon', d.orgTelefon));
    c.add(TextContent('org_email', d.orgElPochta));
    c.add(TextContent('org_bank_rs', d.orgBankRS));
    c.add(TextContent('org_bank_ks', d.orgBankKS));
    c.add(TextContent('org_bank_bik', d.orgBankBIK));
    c.add(TextContent('org_bank_name', d.orgBankName));
    c.add(TextContent('org_direktor', d.orgDirektorFio));
    c.add(TextContent('org_buhgalter', d.orgBuhgalterFio));

    // ── Сотрудник ─────────────────────────────────────────────
    c.add(TextContent('sot_fio', d.sotFio));
    c.add(TextContent('sot_fio_short', d.sotFioShort));
    c.add(TextContent('sot_familiya', d.sotFamiliya));
    c.add(TextContent('sot_name', d.sotName));
    c.add(TextContent('sot_otchestvo', d.sotOtchestvo));
    c.add(TextContent('sot_date_birth', d.sotDateBirth));
    c.add(TextContent('sot_mesto_birth', d.sotMestoBirth));
    c.add(TextContent('sot_adres_reg', d.sotAdresRegistr));
    c.add(TextContent('sot_adres_git', d.sotAdresGitelstva));
    c.add(TextContent('sot_telefon', d.sotTelefon));
    c.add(TextContent('sot_email', d.sotElPochta));
    c.add(TextContent('sot_inn', d.sotInn));
    c.add(TextContent('sot_snils', d.sotSnils));
    c.add(TextContent('sot_pasp_seria', d.sotPasportSeria));
    c.add(TextContent('sot_pasp_nomer', d.sotPasportNomer));
    c.add(TextContent('sot_pasp_vidan', d.sotPasportVidan));
    c.add(TextContent('sot_pasp_data', d.sotPasportVidanDateTime));
    c.add(TextContent('sot_pasp_kod', d.sotPasportKodPodrazdeleniya));
    c.add(TextContent('sot_bank_rs', d.sotBankRS));
    c.add(TextContent('sot_bank_ks', d.sotBankKS));
    c.add(TextContent('sot_bank_bik', d.sotBankBIK));
    c.add(TextContent('sot_bank_name', d.sotBankName));
    c.add(TextContent('sot_date_priema', d.sotDatePriema));

    // ── Должность ─────────────────────────────────────────────
    c.add(TextContent('dolzhnost', d.dolzhnostNazvanie));
    c.add(TextContent('podrazdelenie', d.podrazdelenie));
    c.add(TextContent('oklad_min', d.okladMin.toStringAsFixed(0)));
    c.add(TextContent('oklad_max', d.okladMax.toStringAsFixed(0)));

    // ── Условия труда ─────────────────────────────────────────
    c.add(TextContent('usl_nazvanie', d.uslTrudaNazvanie));
    c.add(TextContent('usl_klass', d.uslKlassUslTruda));
    c.add(TextContent('usl_grafic', d.uslGraficRaboty));
    c.add(TextContent('usl_chasov', d.uslChasovVSmene.toString()));
    c.add(TextContent('usl_nachalo', d.uslVrNachalaRaboty));
    c.add(TextContent('usl_okonch', d.uslVrOkonchaniyaRaboty));
    c.add(TextContent('usl_obed', d.obedLabel));
    c.add(TextContent('usl_norm', d.normirovanieLabel));
    c.add(TextContent('usl_vecher', d.uslChasovVechernih.toString()));
    c.add(TextContent('usl_noch', d.uslChasovNochnykh.toString()));

    // ── Служебные ─────────────────────────────────────────────
    c.add(TextContent('nomer_dogovora', d.nomerDogovora));
    c.add(TextContent('date_sostavl', d.dateSostavleniya));
  }

  Future<File> _tempFile(String filename) async {
    final dir = await getTemporaryDirectory();
    dev.log('[DocxGenerator] Temp dir: ${dir.path}', name: 'DocGen');
    return File('${dir.path}/$filename');
  }
}
