import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikiitemgetfromlist.dart';
import 'package:zp/core/widgets/item_action_bar.dart';

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

  late final TextEditingController _periodMesyac;
  late final TextEditingController _dateVyplaty;
  late final TextEditingController _summaAvansa;
  late final TextEditingController _procentOtOklada;
  late final TextEditingController _platezhDocument;
  late final TextEditingController _primechanie;
  late final TextEditingController _sotrudnikFio;

  final _periodMask = MaskTextInputFormatter(
    mask: '##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _dateMask = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  int _sotrudnikId = 0;
  double _okladMin = 0.0;
  String _statusVyplaty = 'nacisleno';
  String _sposobVyplaty = 'bank';

  bool _updatingFromProcent = false;
  bool _updatingFromSumma = false;

  bool get _isEdit => widget.item != null;

  void _syncMask(MaskTextInputFormatter mask, String value) {
    if (value.isEmpty) return;
    mask.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: value.replaceAll('.', '')),
    );
  }

  String? _validateDate(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    try {
      DateFormat('dd.MM.yyyy').parseStrict(v.trim());
      return null;
    } catch (_) {
      return 'Формат: ДД.ММ.ГГГГ';
    }
  }

  String? _validatePeriod(String? v) {
    if (v == null || v.trim().isEmpty) return 'Обязательное поле';
    final p = v.trim().split('.');
    if (p.length != 2) return 'Формат: ММ.ГГГГ';
    final m = int.tryParse(p[0]) ?? 0;
    final y = int.tryParse(p[1]) ?? 0;
    if (m < 1 || m > 12) return 'Месяц от 01 до 12';
    if (y < 2000 || y > 2100) return 'Год от 2000 до 2100';
    return null;
  }

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _periodMesyac = TextEditingController(
      text: d?['periodMesyac']?.toString() ?? '',
    );
    _dateVyplaty = TextEditingController(
      text: d?['dateVyplaty']?.toString() ?? '',
    );
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
    _syncMask(_periodMask, _periodMesyac.text);
    _syncMask(_dateMask, _dateVyplaty.text);
    _summaAvansa.addListener(_onSummaChanged);
    _procentOtOklada.addListener(_onProcentChanged);
    if (_sotrudnikId > 0) _loadOkladBySotrudnikId(_sotrudnikId);
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
    ])
      c.dispose();
    super.dispose();
  }

  Future<void> _loadOkladBySotrudnikId(int id) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT d.oklad FROM sotrudniki s
      LEFT JOIN dolzhnosti d ON d.id = s.dolzhnostId
      WHERE s.id = ? LIMIT 1
    ''',
      [id],
    );
    if (rows.isNotEmpty && mounted) {
      setState(
        () => _okladMin = (rows.first['oklad'] as num?)?.toDouble() ?? 0.0,
      );
      _recalcSummaFromProcent();
    }
  }

  void _onProcentChanged() {
    if (_updatingFromSumma) return;
    _updatingFromProcent = true;
    _recalcSummaFromProcent();
    _updatingFromProcent = false;
  }

  void _recalcSummaFromProcent() {
    if (_okladMin <= 0) return;
    final p = double.tryParse(
      _procentOtOklada.text.trim().replaceAll(',', '.'),
    );
    if (p == null) return;
    final s = (_okladMin * p / 100).roundToDouble().toStringAsFixed(0);
    if (_summaAvansa.text != s) {
      _updatingFromProcent = true;
      _summaAvansa.text = s;
      _updatingFromProcent = false;
    }
  }

  void _onSummaChanged() {
    if (_updatingFromProcent) return;
    _updatingFromSumma = true;
    _recalcProcentFromSumma();
    _updatingFromSumma = false;
  }

  void _recalcProcentFromSumma() {
    if (_okladMin <= 0) return;
    final s = double.tryParse(_summaAvansa.text.trim().replaceAll(',', '.'));
    if (s == null) return;
    final p = (s / _okladMin * 100);
    final ps = p % 1 == 0
        ? p.toStringAsFixed(0)
        : p.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
    if (_procentOtOklada.text != ps) {
      _updatingFromSumma = true;
      _procentOtOklada.text = ps;
      _updatingFromSumma = false;
    }
  }

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
        _okladMin = 0.0;
      });
      await _loadOkladBySotrudnikId(_sotrudnikId);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'sotrudnikId': _sotrudnikId,
      'periodMesyac': _periodMesyac.text.trim(),
      'dateVyplaty': _dateVyplaty.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final okladHint = _okladMin > 0
        ? 'Оклад: ${_okladMin.toStringAsFixed(0)} ₽'
        : 'Выберите сотрудника для расчёта';

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: Text(_isEdit ? 'Редактировать аванс' : 'Новый аванс'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ItemActionBar(
        isSaving: _isSaving,
        onCancel: () => Navigator.pop(context),
        onSave: _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
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
                  helperText: 'Вводите только цифры',
                  border: OutlineInputBorder(),
                ),
                validator: _validatePeriod,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _dateVyplaty,
                inputFormatters: [_dateMask],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Дата выплаты',
                  hintText: 'ДДММГГГГ',
                  helperText: 'Вводите только цифры',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                ),
                validator: _validateDate,
              ),
            ),

            buildSectionHeader(context, 'Сумма'),
            if (_sotrudnikId > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: scheme.primary),
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
                      ? 'Введите сумму — % рассчитается автоматически'
                      : null,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
