// Утилита открытия и отправки сгенерированных файлов.
// Используется всеми генераторами документов — не зависит от типа документа.

import 'dart:developer' as dev;
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'generator_models.dart';

class DocumentOpener {
  const DocumentOpener._();

  /// Открывает файл системным приложением устройства.
  /// PDF — встроенный просмотрщик с кнопкой печати.
  /// Другие форматы — приложение по умолчанию.
  static Future<void> open(GeneratorResult result, {String? name}) async {
    if (!result.success || result.filePath.isEmpty) {
      dev.log('[DocumentOpener] open: файл недоступен', name: 'DocGen');
      return;
    }
    dev.log('[DocumentOpener] Открытие: ${result.filePath}', name: 'DocGen');
    final r = await OpenFilex.open(result.filePath);
    dev.log(
      '[DocumentOpener] Результат: ${r.type} — ${r.message}',
      name: 'DocGen',
    );
  }

  /// Диалог «Поделиться» — отправка по почте, мессенджерам и т.д.
  static Future<void> share(
    GeneratorResult result, {
    String subject = 'Документ',
    String text = '',
  }) async {
    if (!result.success || result.filePath.isEmpty) return;
    dev.log('[DocumentOpener] Поделиться: ${result.filePath}', name: 'DocGen');
    await Share.shareXFiles(
      [XFile(result.filePath)],
      subject: subject,
      text: text,
    );
  }
}
