import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikiitemgetfromlist.dart';

class AvansItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const AvansItem({super.key, this.item});
  @override
  State<AvansItem> createState() => _AvansItemState();
}

class _AvansItemState extends State<AvansItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  // ── Контроллеры ──────────────────────────────────────────────
  late final TextEditingController _periodMesyac;
  late final TextEditingController _dateVyplaty;
  late final TextEditingController _summaAvansa;
  late final TextEditingController _procentOtOklada;
  late final TextEditingController _platezhDocument;
  late final TextEditingController _primechanie;
  late final TextEditingController _sotrudnikFio;

  // ── Маски ────────────────────────────────────────────────────
  // Пользователь вводит только цифры: MMYYYY → отображается MM.YYYY
  final _periodMask = MaskTextInputFormatter(
    mask: '##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Пользователь вводит только цифры: DDMMYYYY → отображается DD.MM.YYYY
  final _dateMask = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // ── Данные сотрудника ────────────────────────────────────────
  int _sotrudnikId = 0;
  double _okladMin = 0.0; // минимальный оклад из таблицы dolzhnosti

  // ── Флаги пересчёта ──────────────────────────────────────────
  bool _updatingFromProcent = false; // guard против бесконечного цикла
  bool _updatingFromSumma = false;

  // ── Статус / способ ─────────────────────────────────────────
  String _statusVyplaty = 'nacisleno';
  String _sposobVyplaty = 'bank';

  bool get _isEdit => widget.item != null;

  // ─────────────────────────────────────────────────────────────
  // initState
  // ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final d = widget.item;

    // Период: в БД хранится как «MM.YYYY», маска вставит разделитель сама
    _periodMesyac = TextEditingController(
      text: d?['periodMesyac']?.toString() ?? '',
    );
    // Синхронизируем позицию маски с уже сохранённым значением
    if (_periodMesyac.text.isNotEmpty) {
      _periodMask.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: _periodMesyac.text.replaceAll('.', '')),
      );
    }

    // Дата: в БД «dd.MM.yyyy»
    _dateVyplaty = TextEditingController(
      text: d?['dateVyplaty']?.toString() ?? '',
    );
    if (_dateVyplaty.text.isNotEmpty) {
      _dateMask.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: _dateVyplaty.text.replaceAll('.', '')),
      );
    }

    _summaAvansa = TextEditingController(
      text: d?['summaAvansa']?.toString() ?? '',
    );
    _procentOtOklada = TextEditingController(
      text: d?['procentOtOklada']?.toString() ?? '',
    );
    _platezhDocument = TextEditingController(
      text: d?['platezhDocument']?.toString() ?? '',
    );
    _primechanie = TextEditingController(
      text: d?['primechanie']?.toString() ?? '',
    );
    _sotrudnikFio = TextEditingController(text: d?['fio']?.toString() ?? '');

    _sotrudnikId = d?['sotrudnikId'] as int? ?? 0;
    _statusVyplaty = d?['statusVyplaty']?.toString() ?? 'nacisleno';
    _sposobVyplaty = d?['sposobVyplaty']?.toString() ?? 'bank';

    // Слушатели для взаимного пересчёта суммы и процента
    _summaAvansa.addListener(_onSummaChanged);
    _procentOtOklada.addListener(_onProcentChanged);

    // Если редактируем и сотрудник уже выбран — загружаем оклад
    if (_sotrudnikId > 0) {
      _loadOkladBySotrudnikId(_sotrudnikId);
    }
  }

  @override
  void dispose() {
    _summaAvansa.removeListener(_onSummaChanged);
    _procentOtOklada.removeListener(_onProcentChanged);
    for (final c in [
      _periodMesyac,
      _dateVyplaty,
      _summaAvansa,
      _procentOtOklada,
      _platezhDocument,
      _primechanie,
      _sotrudnikFio,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Загрузка оклада сотрудника из БД
  // ─────────────────────────────────────────────────────────────
  Future<void> _loadOkladBySotrudnikId(int sotrudnikId) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT d.okladMin
      FROM sotrudniki s
      LEFT JOIN dolzhnosti d ON d.id = s.dolzhnostId
      WHERE s.id = ?
      LIMIT 1
    ''',
      [sotrudnikId],
    );

    if (rows.isNotEmpty && mounted) {
      setState(() {
        _okladMin = (rows.first['okladMin'] as num?)?.toDouble() ?? 0.0;
      });
      // Если процент уже введён — пересчитаем сумму
      _recalcSummaFromProcent();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Пересчёт: пользователь изменил ПРОЦЕНТ → обновляем СУММУ
  // ─────────────────────────────────────────────────────────────
  void _onProcentChanged() {
    if (_updatingFromSumma) return; // защита от петли
    _updatingFromProcent = true;
    _recalcSummaFromProcent();
    _updatingFromProcent = false;
  }

  void _recalcSummaFromProcent() {
    if (_okladMin <= 0) return;
    final procent = double.tryParse(
      _procentOtOklada.text.trim().replaceAll(',', '.'),
    );
    if (procent == null) return;
    final summa = (_okladMin * procent / 100).roundToDouble();
    final summaStr = summa.toStringAsFixed(0);
    if (_summaAvansa.text != summaStr) {
      _updatingFromProcent = true;
      _summaAvansa.text = summaStr;
      _updatingFromProcent = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Пересчёт: пользователь изменил СУММУ → обновляем ПРОЦЕНТ
  // ─────────────────────────────────────────────────────────────
  void _onSummaChanged() {
    if (_updatingFromProcent) return; // защита от петли
    _updatingFromSumma = true;
    _recalcProcentFromSumma();
    _updatingFromSumma = false;
  }

  void _recalcProcentFromSumma() {
    if (_okladMin <= 0) return;
    final summa = double.tryParse(
      _summaAvansa.text.trim().replaceAll(',', '.'),
    );
    if (summa == null) return;
    final procent = (summa / _okladMin * 100);
    // Показываем с 2 знаками, убираем лишние нули
    final procentStr = procent % 1 == 0
        ? procent.toStringAsFixed(0)
        : procent.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
    if (_procentOtOklada.text != procentStr) {
      _updatingFromSumma = true;
      _procentOtOklada.text = procentStr;
      _updatingFromSumma = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Выбор сотрудника
  // ─────────────────────────────────────────────────────────────
  Future<void> _pickSotrudnik() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SotrudnikiItemGetFromList()),
    );
    if (result != null) {
      setState(() {
        _sotrudnikId = result['id'] as int;
        _sotrudnikFio.text =
            '${result['familiya']} ${result['name']} ${result['otchestvo']}';
        _okladMin = 0.0; // сбросим пока не загрузится оклад
      });
      await _loadOkladBySotrudnikId(_sotrudnikId);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Валидация и форматирование периода перед сохранением
  // ─────────────────────────────────────────────────────────────
  // Пользователь вводит: «032026» → маска показывает «03.2026»
  // В БД сохраняем: «03.2026»
  String _normalizePeriod(String raw) {
    // raw уже содержит точку от маски: «03.2026» или «3.2026»
    return raw.trim();
  }

  // ─────────────────────────────────────────────────────────────
  // Валидация и форматирование даты перед сохранением
  // ─────────────────────────────────────────────────────────────
  // Пользователь вводит: «25042026» → маска: «25.04.2026»
  // В БД сохраняем: «25.04.2026»
  String _normalizeDate(String raw) {
    return raw.trim();
  }

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return null; // необязательное
    try {
      DateFormat('dd.MM.yyyy').parseStrict(value.trim());
      return null;
    } catch (_) {
      return 'Введите дату в формате ДД.ММ.ГГГГ';
    }
  }

  String? _validatePeriod(String? value) {
    if (value == null || value.trim().isEmpty) return 'Обязательное поле';
    final parts = value.trim().split('.');
    if (parts.length != 2) return 'Формат: ММ.ГГГГ';
    final month = int.tryParse(parts[0]) ?? 0;
    final year = int.tryParse(parts[1]) ?? 0;
    if (month < 1 || month > 12) return 'Месяц от 01 до 12';
    if (year < 2000 || year > 2100) return 'Год от 2000 до 2100';
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // Сохранение
  // ─────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'sotrudnikId': _sotrudnikId,
      'periodMesyac': _normalizePeriod(_periodMesyac.text),
      'dateVyplaty': _normalizeDate(_dateVyplaty.text),
      'summaAvansa': double.tryParse(_summaAvansa.text.trim()) ?? 0.0,
      'procentOtOklada': double.tryParse(_procentOtOklada.text.trim()) ?? 0.0,
      'statusVyplaty': _statusVyplaty,
      'sposobVyplaty': _sposobVyplaty,
      'platezhDocument': _platezhDocument.text.trim(),
      'primechanie': _primechanie.text.trim(),
    };

    if (_isEdit) {
      await _db.update('avans', data, widget.item!['id'] as int);
    } else {
      await _db.insert('avans', data);
    }

    if (mounted) {
      showSnack(context, _isEdit ? 'Изменения сохранены' : 'Аванс добавлен');
      Navigator.pop(context);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Подсказка об окладе рядом с суммой
    final okladHint = _okladMin > 0
        ? 'Оклад (мин.): ${_okladMin.toStringAsFixed(0)} ₽'
        : 'Выберите сотрудника для расчёта';

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: Text(_isEdit ? 'Редактировать аванс' : 'Новый аванс'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Сохранить'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Сотрудник ──────────────────────────────────────
            buildSectionHeader(context, 'Сотрудник'),
            buildTextField(
              context: context,
              controller: _sotrudnikFio,
              label: 'Сотрудник',
              readOnly: true,
              onTap: _pickSotrudnik,
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
              validator: (_) =>
                  _sotrudnikId == 0 ? 'Выберите сотрудника' : null,
            ),

            // ── Период ─────────────────────────────────────────
            buildSectionHeader(context, 'Период и дата'),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _periodMesyac,
                inputFormatters: [_periodMask],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Период (ММ.ГГГГ)',
                  hintText: 'ММГГГГ',
                  helperText: 'Вводите только цифры, например: 032026',
                  border: OutlineInputBorder(),
                ),
                validator: _validatePeriod,
              ),
            ),

            // ── Дата выплаты ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _dateVyplaty,
                inputFormatters: [_dateMask],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Дата выплаты',
                  hintText: 'ДДММГГГГ',
                  helperText: 'Вводите только цифры, например: 25042026',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                ),
                validator: _validateDate,
              ),
            ),

            // ── Сумма и процент ────────────────────────────────
            buildSectionHeader(context, 'Сумма'),

            // Подсказка об окладе
            if (_sotrudnikId > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: scheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      okladHint,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: scheme.primary),
                    ),
                  ],
                ),
              ),

            // Сумма аванса
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _summaAvansa,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Сумма аванса, ₽',
                  border: const OutlineInputBorder(),
                  helperText: _okladMin > 0
                      ? 'Введите сумму — процент рассчитается автоматически'
                      : null,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
              ),
            ),

            // Процент от оклада
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _procentOtOklada,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Процент от оклада, %',
                  border: const OutlineInputBorder(),
                  helperText: _okladMin > 0
                      ? 'Введите % — сумма рассчитается автоматически'
                      : null,
                ),
              ),
            ),

            // ── Статус ─────────────────────────────────────────
            buildSectionHeader(context, 'Статус'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'nacisleno', label: Text('Начислен')),
                ButtonSegment(value: 'vyplaceno', label: Text('Выплачен')),
                ButtonSegment(value: 'otmeneno', label: Text('Отменён')),
              ],
              selected: {_statusVyplaty},
              onSelectionChanged: (s) =>
                  setState(() => _statusVyplaty = s.first),
            ),

            // ── Способ выплаты ─────────────────────────────────
            buildSectionHeader(context, 'Способ выплаты'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'bank', label: Text('Банк')),
                ButtonSegment(value: 'kassa', label: Text('Касса')),
              ],
              selected: {_sposobVyplaty},
              onSelectionChanged: (s) =>
                  setState(() => _sposobVyplaty = s.first),
            ),

            // ── Документ и примечание ──────────────────────────
            buildSectionHeader(context, 'Документ и примечание'),
            buildTextField(
              context: context,
              controller: _platezhDocument,
              label: 'Номер платёжного документа',
            ),
            buildTextField(
              context: context,
              controller: _primechanie,
              label: 'Примечание',
              maxLines: 3,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
