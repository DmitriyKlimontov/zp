// lib/services/documents/doc_service.dart

import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'doc_models.dart';
import 'doc_repository.dart';
import 'pdf_generator.dart';
import 'docx_generator.dart';

class DocService {
  final DocRepository _repo;
  final PdfGenerator _pdf;
  final DocxGenerator _docx;

  DocService({DocRepository? repo, PdfGenerator? pdf, DocxGenerator? docx})
    : _repo = repo ?? DocRepository(),
      _pdf = pdf ?? PdfGenerator(),
      _docx = docx ?? DocxGenerator();

  // ── Данные из БД ─────────────────────────────────────────────

  Future<TrudovoyDogovorData?> loadTrudovoyDogovorData({
    required int sotrudnikId,
    required int organizaciyaId,
    String? nomerDogovora,
  }) {
    dev.log(
      '[DocService] Загрузка данных. sotrudnikId=$sotrudnikId, '
      'orgId=$organizaciyaId',
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
    DocFormat format,
  ) async {
    dev.log('[DocService] Генерация в формате: ${format.name}', name: 'DocGen');
    switch (format) {
      case DocFormat.pdf:
        return _pdf.generateTrudovoyDogovor(data);
      case DocFormat.docx:
        return _docx.generateTrudovoyDogovor(data);
    }
  }

  // ── Открытие ─────────────────────────────────────────────────

  Future<void> openDocument(DocGenerationResult result) async {
    if (!result.success || result.filePath.isEmpty) {
      dev.log('[DocService] openDocument: файл недоступен', name: 'DocGen');
      return;
    }
    dev.log('[DocService] Открытие файла: ${result.filePath}', name: 'DocGen');

    if (result.filePath.endsWith('.pdf')) {
      try {
        final bytes = await compute(_loadFileBytes, result.filePath);
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: _basename(result.filePath),
        );
        dev.log('[DocService] PDF открыт в просмотрщике', name: 'DocGen');
      } catch (e) {
        dev.log(
          '[DocService] Ошибка открытия PDF: $e',
          name: 'DocGen',
          error: e,
        );
        rethrow;
      }
    } else {
      final openResult = await OpenFilex.open(result.filePath);
      dev.log(
        '[DocService] OpenFilex результат: '
        '${openResult.type} — ${openResult.message}',
        name: 'DocGen',
      );
    }
  }

  Future<void> shareDocument(DocGenerationResult result) async {
    if (!result.success || result.filePath.isEmpty) return;
    dev.log('[DocService] Поделиться: ${result.filePath}', name: 'DocGen');
    await Share.shareXFiles(
      [XFile(result.filePath)],
      subject: 'Трудовой договор',
      text: 'Трудовой договор сотрудника',
    );
  }

  // ── Утилиты ───────────────────────────────────────────────────

  static Future<Uint8List> _loadFileBytes(String path) async {
    return await File(path).readAsBytes();
  }

  String _basename(String path) => path.split('/').last.split('\\').last;
}
