// Диалог модального окна генерации трудового договора.

import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zp/services/generators/generator_models.dart';
import 'package:zp/services/generators/trudovoy_dogovor/td_data.dart';
import 'package:zp/services/generators/trudovoy_dogovor/td_service.dart';
import 'package:zp/services/generators/document_opener.dart';

class TdGenerationDogovor extends StatefulWidget {
  final int sotrudnikId;
  const TdGenerationDogovor({super.key, required this.sotrudnikId});

  @override
  State<TdGenerationDogovor> createState() => _TdGenerationDialogState();
}

class _TdGenerationDialogState extends State<TdGenerationDogovor> {
  final _service = TdService();
  final _nomerCtrl = TextEditingController();
  final _ispSrokKolCtrl = TextEditingController(text: '3');

  List<Map<String, dynamic>> _organizacii = [];
  int? _selectedOrgId;
  bool _estIspSrok = false;
  IspSrokUnit _ispSrokUnit = IspSrokUnit.mesyacy;
  bool _isLoading = false;
  bool _isGenerating = false;

  GeneratorResult? _result;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadOrganizacii();
  }

  @override
  void dispose() {
    _nomerCtrl.dispose();
    _ispSrokKolCtrl.dispose();
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
          : null;

      dev.log('[TdGenerationDialog] Загружаю данные...', name: 'DocGen');
      final data = await _service.loadData(
        sotrudnikId: widget.sotrudnikId,
        organizaciyaId: _selectedOrgId!,
        nomerDogovora: nomer,
        estIspSrok: _estIspSrok,
        ispSrokKolichestvo: int.tryParse(_ispSrokKolCtrl.text.trim()) ?? 3,
        ispSrokUnit: _ispSrokUnit,
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

      dev.log('[TdGenerationDialog] Генерирую PDF...', name: 'DocGen');
      final result = await _service.generatePdf(data);
      setState(() {
        _result = result;
        _isGenerating = false;
        _errorText = result.success ? null : result.error;
      });

      if (result.success && mounted) {
        await DocumentOpener.open(
          result,
          name: 'Трудовой договор ${data.sotFioShort}',
        );
      }
    } catch (e, stack) {
      dev.log(
        '[TdGenerationDialog] ИСКЛЮЧЕНИЕ: $e',
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

  String _previewIspSrok() {
    if (!_estIspSrok) return 'Работник принимается без испытательного срока.';
    final n = int.tryParse(_ispSrokKolCtrl.text.trim()) ?? 0;
    return 'Работнику устанавливается испытательный срок: '
        '${_ispSrokUnit.labelFor(n)}.';
  }

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

            // Организация
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
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: _organizacii.map((o) {
                  // Краткое наименование предпочтительнее; fallback → полное
                  final display =
                      (o['kratkoeNazvanie']?.toString().trim().isNotEmpty ==
                                  true
                              ? o['kratkoeNazvanie']
                              : o['nazvanie'])
                          ?.toString() ??
                      '—';
                  return DropdownMenuItem<int>(
                    value: o['id'] as int,
                    child: Text(
                      display,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() {
                  _selectedOrgId = v;
                  _errorText = null;
                }),
              ),
            ],

            const SizedBox(height: 16),

            // Номер договора
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

            const SizedBox(height: 16),

            // Испытательный срок
            _label(context, 'Испытательный срок'),
            const SizedBox(height: 8),
            DropdownButtonFormField<bool>(
              value: _estIspSrok,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: false,
                  child: Text('Без испытательного срока'),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text('С испытательным сроком'),
                ),
              ],
              onChanged: (v) => setState(() {
                _estIspSrok = v!;
                _errorText = null;
              }),
            ),

            if (_estIspSrok) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: TextFormField(
                      controller: _ispSrokKolCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Кол-во',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<IspSrokUnit>(
                      value: _ispSrokUnit,
                      decoration: const InputDecoration(
                        labelText: 'Единица',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: IspSrokUnit.values
                          .map(
                            (u) => DropdownMenuItem(
                              value: u,
                              child: Text(u.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _ispSrokUnit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _infoCard(scheme, text, _previewIspSrok()),
            ],

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
                      onPressed: () => DocumentOpener.open(_result!),
                      icon: const Icon(Icons.open_in_new_outlined),
                      label: const Text('Открыть'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => DocumentOpener.share(
                        _result!,
                        subject: 'Трудовой договор',
                        text: 'Трудовой договор сотрудника',
                      ),
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
