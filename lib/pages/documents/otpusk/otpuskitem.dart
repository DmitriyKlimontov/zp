import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikiitemgetfromlist.dart';
import 'package:zp/widgets/item_action_bar.dart';

class OtpuskItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const OtpuskItem({super.key, this.item});
  @override
  State<OtpuskItem> createState() => _OtpuskItemState();
}

class _OtpuskItemState extends State<OtpuskItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  late final TextEditingController _dateNachala;
  late final TextEditingController _dateOkonchaniya;
  late final TextEditingController _kolichestvoDney;
  late final TextEditingController _nomerPrikaza;
  late final TextEditingController _datePrikaza;
  late final TextEditingController _sredniyZarabotok;
  late final TextEditingController _summaOtpusknyh;
  late final TextEditingController _dateVyplatyOtpusknyh;
  late final TextEditingController _sotrudnikFio;

  // Маски дат
  final _maskD1 = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskD2 = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskD3 = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskD4 = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  int _sotrudnikId = 0;
  String _vidOtpuska = 'ezhegodnyy';
  String _statusVyplaty = 'nacisleno';

  bool get _isEdit => widget.item != null;

  void _syncMask(MaskTextInputFormatter m, String v) {
    if (v.isEmpty) return;
    m.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: v.replaceAll('.', '')),
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

  String? _validateRequiredDate(String? v) {
    if (v == null || v.trim().isEmpty) return 'Обязательное поле';
    return _validateDate(v);
  }

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _dateNachala = TextEditingController(
      text: d?['dateNachala']?.toString() ?? '',
    );
    _dateOkonchaniya = TextEditingController(
      text: d?['dateOkonchaniya']?.toString() ?? '',
    );
    _kolichestvoDney = TextEditingController(
      text: d?['kolichestvoDney']?.toString() ?? '',
    );
    _nomerPrikaza = TextEditingController(
      text: d?['nomerPrikaza']?.toString() ?? '',
    );
    _datePrikaza = TextEditingController(
      text: d?['datePrikaza']?.toString() ?? '',
    );
    _sredniyZarabotok = TextEditingController(
      text: d?['sredniyZarabotok']?.toString() ?? '',
    );
    _summaOtpusknyh = TextEditingController(
      text: d?['summaOtpusknyh']?.toString() ?? '',
    );
    _dateVyplatyOtpusknyh = TextEditingController(
      text: d?['dateVyplatyOtpusknyh']?.toString() ?? '',
    );
    _sotrudnikFio = TextEditingController(text: d?['fio']?.toString() ?? '');
    _sotrudnikId = d?['sotrudnikId'] as int? ?? 0;
    _vidOtpuska = d?['vidOtpuska']?.toString() ?? 'ezhegodnyy';
    _statusVyplaty = d?['statusVyplaty']?.toString() ?? 'nacisleno';
    _syncMask(_maskD1, _dateNachala.text);
    _syncMask(_maskD2, _dateOkonchaniya.text);
    _syncMask(_maskD3, _datePrikaza.text);
    _syncMask(_maskD4, _dateVyplatyOtpusknyh.text);
  }

  @override
  void dispose() {
    for (final c in [
      _dateNachala,
      _dateOkonchaniya,
      _kolichestvoDney,
      _nomerPrikaza,
      _datePrikaza,
      _sredniyZarabotok,
      _summaOtpusknyh,
      _dateVyplatyOtpusknyh,
      _sotrudnikFio,
    ])
      c.dispose();
    super.dispose();
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
      });
    }
  }

  Widget _dateField(
    TextEditingController ctrl,
    MaskTextInputFormatter mask,
    String label, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        inputFormatters: [mask],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'ДДММГГГГ',
          helperText: 'Вводите только цифры',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        validator: required ? _validateRequiredDate : _validateDate,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'sotrudnikId': _sotrudnikId,
      'vidOtpuska': _vidOtpuska,
      'dateNachala': _dateNachala.text.trim(),
      'dateOkonchaniya': _dateOkonchaniya.text.trim(),
      'kolichestvoDney': int.tryParse(_kolichestvoDney.text.trim()) ?? 0,
      'nomerPrikaza': _nomerPrikaza.text.trim(),
      'datePrikaza': _datePrikaza.text.trim(),
      'sredniyZarabotok': double.tryParse(_sredniyZarabotok.text.trim()) ?? 0.0,
      'summaOtpusknyh': double.tryParse(_summaOtpusknyh.text.trim()) ?? 0.0,
      'dateVyplatyOtpusknyh': _dateVyplatyOtpusknyh.text.trim(),
      'statusVyplaty': _statusVyplaty,
    };
    if (_isEdit) {
      await _db.update('otpusk', data, widget.item!['id'] as int);
    } else {
      await _db.insert('otpusk', data);
    }
    if (mounted) {
      showSnack(context, _isEdit ? 'Изменения сохранены' : 'Отпуск добавлен');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: Text(_isEdit ? 'Редактировать отпуск' : 'Новый отпуск'),
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

            buildSectionHeader(context, 'Вид отпуска'),
            DropdownButtonFormField<String>(
              value: _vidOtpuska,
              decoration: const InputDecoration(
                labelText: 'Вид отпуска',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'ezhegodnyy', child: Text('Ежегодный')),
                DropdownMenuItem(value: 'uchebniy', child: Text('Учебный')),
                DropdownMenuItem(value: 'dekretnyy', child: Text('Декретный')),
                DropdownMenuItem(
                  value: 'bez_oplaty',
                  child: Text('Без оплаты'),
                ),
              ],
              onChanged: (v) => setState(() => _vidOtpuska = v!),
            ),
            const SizedBox(height: 16),

            buildSectionHeader(context, 'Период отпуска'),
            _dateField(_dateNachala, _maskD1, 'Дата начала', required: true),
            _dateField(_dateOkonchaniya, _maskD2, 'Дата окончания'),
            buildTextField(
              context: context,
              controller: _kolichestvoDney,
              label: 'Количество календарных дней',
              keyboardType: TextInputType.number,
            ),

            buildSectionHeader(context, 'Приказ'),
            buildTextField(
              context: context,
              controller: _nomerPrikaza,
              label: 'Номер приказа',
            ),
            _dateField(_datePrikaza, _maskD3, 'Дата приказа'),

            buildSectionHeader(context, 'Расчёт и выплата'),
            buildTextField(
              context: context,
              controller: _sredniyZarabotok,
              label: 'Средний дневной заработок, ₽',
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              context: context,
              controller: _summaOtpusknyh,
              label: 'Сумма отпускных, ₽',
              keyboardType: TextInputType.number,
            ),
            _dateField(
              _dateVyplatyOtpusknyh,
              _maskD4,
              'Дата выплаты отпускных',
            ),

            buildSectionHeader(context, 'Статус'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'nacisleno', label: Text('Начислено')),
                ButtonSegment(value: 'vyplaceno', label: Text('Выплачено')),
              ],
              selected: {_statusVyplaty},
              onSelectionChanged: (s) =>
                  setState(() => _statusVyplaty = s.first),
            ),
          ],
        ),
      ),
    );
  }
}
