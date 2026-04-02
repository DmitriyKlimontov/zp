// lib/pages/documents/doc_generation_dialog.dart

import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:zp/services/documents/doc_models.dart';
import 'package:zp/services/documents/doc_service.dart';

class DocGenerationDialog extends StatefulWidget {
  final int sotrudnikId;
  const DocGenerationDialog({super.key, required this.sotrudnikId});

  @override
  State<DocGenerationDialog> createState() => _DocGenerationDialogState();
}

class _DocGenerationDialogState extends State<DocGenerationDialog> {
  final _service = DocService();
  final _nomerCtrl = TextEditingController();

  List<Map<String, dynamic>> _organizacii = [];
  int? _selectedOrgId;
  bool _isLoading = false;
  bool _isGenerating = false;

  DocGenerationResult? _result;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadOrganizacii();
  }

  @override
  void dispose() {
    _nomerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOrganizacii() async {
    setState(() => _isLoading = true);
    try {
      final orgs = await _service.getOrganizacii();
      setState(() {
        _organizacii = orgs;
        if (orgs.length == 1) _selectedOrgId = orgs.first['id'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = e.toString();
      });
    }
  }

  Future<void> _generate() async {
    if (_selectedOrgId == null) {
      setState(() => _errorText = 'Выберите организацию');
      return;
    }
    setState(() {
      _isGenerating = true;
      _result = null;
      _errorText = null;
    });

    try {
      final nomer = _nomerCtrl.text.trim().isNotEmpty
          ? _nomerCtrl.text.trim()
          : '';

      dev.log('[DocGenDialog] Загружаю данные...', name: 'DocGen');
      final data = await _service.loadTrudovoyDogovorData(
        sotrudnikId: widget.sotrudnikId,
        organizaciyaId: _selectedOrgId!,
        nomerDogovora: nomer.isNotEmpty ? nomer : ' ',
      );

      if (data == null) {
        setState(() {
          _isGenerating = false;
          _errorText =
              'Не удалось загрузить данные сотрудника '
              'или организации из базы данных.';
        });
        return;
      }

      dev.log('[DocGenDialog] Генерирую PDF...', name: 'DocGen');
      final result = await _service.generateTrudovoyDogovor(data);
      setState(() {
        _result = result;
        _isGenerating = false;
        _errorText = result.success ? null : result.error;
      });

      if (result.success && mounted) {
        dev.log('[DocGenDialog] Открываю...', name: 'DocGen');
        await _service.openDocument(result);
      }
    } catch (e, stack) {
      dev.log(
        '[DocGenDialog] ИСКЛЮЧЕНИЕ: $e',
        name: 'DocGen',
        error: e,
        stackTrace: stack,
      );
      setState(() {
        _isGenerating = false;
        _errorText = e.toString();
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                Icon(Icons.picture_as_pdf_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Трудовой договор',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Text(
              'Генерация PDF',
              style: text.bodySmall?.copyWith(color: scheme.outline),
            ),
            const Divider(height: 20),

            // Выбор организации
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_organizacii.isEmpty)
              _warnCard(
                scheme,
                'Нет организаций в справочнике.\n'
                'Добавьте организацию и повторите.',
              )
            else ...[
              _label(context, 'Организация'),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _selectedOrgId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: _organizacii
                    .map(
                      (o) => DropdownMenuItem<int>(
                        value: o['id'] as int,
                        child: Text(
                          o['nazvanie']?.toString() ?? '—',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedOrgId = v;
                  _errorText = null;
                }),
              ),
            ],

            const SizedBox(height: 16),

            // Номер договора (необязательно)
            _label(context, 'Номер договора (необязательно)'),
            const SizedBox(height: 6),
            TextField(
              controller: _nomerCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Оставьте пустым, если не нужен',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка генерации
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_isGenerating || _isLoading || _organizacii.isEmpty)
                    ? null
                    : _generate,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  _isGenerating ? 'Генерация...' : 'Сгенерировать PDF',
                ),
              ),
            ),

            // Ошибка
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: scheme.onErrorContainer,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ошибка',
                          style: text.labelMedium?.copyWith(
                            color: scheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      _errorText!,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Подробности: консоль VSCode, фильтр DocGen',
                      style: text.labelSmall?.copyWith(
                        color: scheme.onErrorContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Кнопки после успешной генерации
            if (_result != null && _result!.success) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _service.openDocument(_result!),
                      icon: const Icon(Icons.open_in_new_outlined),
                      label: const Text('Открыть'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _service.shareDocument(_result!),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Поделиться'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _infoCard(
                scheme,
                text,
                'Файл во временной папке устройства. '
                'Удаляется системой автоматически.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext ctx, String label) => Text(
    label,
    style: Theme.of(
      ctx,
    ).textTheme.labelMedium?.copyWith(color: Theme.of(ctx).colorScheme.outline),
  );

  Widget _warnCard(ColorScheme s, String msg) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: s.errorContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(msg, style: TextStyle(color: s.onErrorContainer, fontSize: 13)),
  );

  Widget _infoCard(ColorScheme s, TextTheme t, String msg) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: s.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 14, color: s.outline),
        const SizedBox(width: 6),
        Expanded(
          child: Text(msg, style: t.labelSmall?.copyWith(color: s.outline)),
        ),
      ],
    ),
  );
}
