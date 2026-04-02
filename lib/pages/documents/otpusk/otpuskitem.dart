import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikiitemgetfromlist.dart';

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

  int _sotrudnikId = 0;
  String _vidOtpuska = 'ezhegodnyy';
  String _statusVyplaty = 'nacisleno';

  bool get _isEdit => widget.item != null;

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

  Future<void> _pickDate(TextEditingController ctrl) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      ctrl.text =
          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
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
      });
    }
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
            buildTextField(
              context: context,
              controller: _dateNachala,
              label: 'Дата начала',
              readOnly: true,
              onTap: () => _pickDate(_dateNachala),
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _dateOkonchaniya,
              label: 'Дата окончания',
              readOnly: true,
              onTap: () => _pickDate(_dateOkonchaniya),
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
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
            buildTextField(
              context: context,
              controller: _datePrikaza,
              label: 'Дата приказа',
              readOnly: true,
              onTap: () => _pickDate(_datePrikaza),
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),

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
            buildTextField(
              context: context,
              controller: _dateVyplatyOtpusknyh,
              label: 'Дата выплаты отпускных',
              readOnly: true,
              onTap: () => _pickDate(_dateVyplatyOtpusknyh),
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
