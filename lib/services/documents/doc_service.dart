// lib/services/documents/doc_service.dart

import 'dart:developer' as dev;
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'doc_models.dart';
import 'doc_repository.dart';
import 'pdf_generator.dart';

class DocService {
  final DocRepository _repo;
  final PdfGenerator _pdf;

  DocService({DocRepository? repo, PdfGenerator? pdf})
    : _repo = repo ?? DocRepository(),
      _pdf = pdf ?? PdfGenerator();

  // ── Данные ────────────────────────────────────────────────────

  Future<TrudovoyDogovorData?> loadTrudovoyDogovorData({
    required int sotrudnikId,
    required int organizaciyaId,
    String? nomerDogovora,
  }) {
    dev.log(
      '[DocService] loadTrudovoyDogovorData '
      'sotrudnikId=$sotrudnikId orgId=$organizaciyaId',
      name: 'DocGen',
    );
    return _repo.loadTrudovoyDogovorData(
      sotrudnikId: sotrudnikId,
      organizaciyaId: organizaciyaId,
      nomerDogovora: nomerDogovora,
    );
  }

  Future<List<Map<String, dynamic>>> getOrganizacii() => _repo.getOrganizacii();

  // ── Генерация ─────────────────────────────────────────────────

  Future<DocGenerationResult> generateTrudovoyDogovor(
    TrudovoyDogovorData data,
  ) async {
    dev.log('[DocService] Генерация PDF', name: 'DocGen');
    return _pdf.generateTrudovoyDogovor(data);
  }

  // ── Открытие ─────────────────────────────────────────────────
  // Syncfusion генерирует нативный PDF.
  // open_filex открывает его системным PDF-просмотрщиком устройства
  // (Adobe Acrobat, встроенный просмотр Android, и т.д.).
  // Там уже есть кнопка печати — принтер получает PDF «как есть»,
  // без подмены шрифтов.

  Future<void> openDocument(DocGenerationResult result) async {
    if (!result.success || result.filePath.isEmpty) {
      dev.log('[DocService] openDocument: файл недоступен', name: 'DocGen');
      return;
    }
    dev.log('[DocService] Открытие: ${result.filePath}', name: 'DocGen');
    final r = await OpenFilex.open(result.filePath);
    dev.log('[DocService] OpenFilex: ${r.type} — ${r.message}', name: 'DocGen');
  }

  /// Отправка по почте / мессенджерам
  Future<void> shareDocument(DocGenerationResult result) async {
    if (!result.success || result.filePath.isEmpty) return;
    dev.log('[DocService] Поделиться: ${result.filePath}', name: 'DocGen');
    await Share.shareXFiles(
      [XFile(result.filePath)],
      subject: 'Трудовой договор',
      text: 'Трудовой договор сотрудника',
    );
  }
}
