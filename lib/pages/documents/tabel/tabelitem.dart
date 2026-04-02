import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikiitemgetfromlist.dart';

class TabelItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const TabelItem({super.key, this.item});
  @override
  State<TabelItem> createState() => _TabelItemState();
}

class _TabelItemState extends State<TabelItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  late final TextEditingController _periodMesyac;
  late final TextEditingController _rabochihDney;
  late final TextEditingController _faktDney;
  late final TextEditingController _faktChasov;
  late final TextEditingController _otpuskDney;
  late final TextEditingController _bolnichnyhDney;
  late final TextEditingController _progulDney;
  late final TextEditingController _komandirovkaDney;
  late final TextEditingController _sotrudnikFio;

  int _sotrudnikId = 0;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _periodMesyac = TextEditingController(
      text: d?['periodMesyac']?.toString() ?? '',
    );
    _rabochihDney = TextEditingController(
      text: d?['rabochihDney']?.toString() ?? '0',
    );
    _faktDney = TextEditingController(text: d?['faktDney']?.toString() ?? '0');
    _faktChasov = TextEditingController(
      text: d?['faktChasov']?.toString() ?? '0',
    );
    _otpuskDney = TextEditingController(
      text: d?['otpuskDney']?.toString() ?? '0',
    );
    _bolnichnyhDney = TextEditingController(
      text: d?['bolnichnyhDney']?.toString() ?? '0',
    );
    _progulDney = TextEditingController(
      text: d?['progulDney']?.toString() ?? '0',
    );
    _komandirovkaDney = TextEditingController(
      text: d?['komandirovkaDney']?.toString() ?? '0',
    );
    _sotrudnikFio = TextEditingController(text: d?['fio']?.toString() ?? '');
    _sotrudnikId = d?['sotrudnikId'] as int? ?? 0;
  }

  @override
  void dispose() {
    for (final c in [
      _periodMesyac,
      _rabochihDney,
      _faktDney,
      _faktChasov,
      _otpuskDney,
      _bolnichnyhDney,
      _progulDney,
      _komandirovkaDney,
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'sotrudnikId': _sotrudnikId,
      'periodMesyac': _periodMesyac.text.trim(),
      'rabochihDney': int.tryParse(_rabochihDney.text.trim()) ?? 0,
      'faktDney': int.tryParse(_faktDney.text.trim()) ?? 0,
      'faktChasov': int.tryParse(_faktChasov.text.trim()) ?? 0,
      'otpuskDney': int.tryParse(_otpuskDney.text.trim()) ?? 0,
      'bolnichnyhDney': int.tryParse(_bolnichnyhDney.text.trim()) ?? 0,
      'progulDney': int.tryParse(_progulDney.text.trim()) ?? 0,
      'komandirovkaDney': int.tryParse(_komandirovkaDney.text.trim()) ?? 0,
    };
    try {
      if (_isEdit) {
        await _db.update('tabel', data, widget.item!['id'] as int);
      } else {
        await _db.insert('tabel', data);
      }
      if (mounted) {
        showSnack(
          context,
          _isEdit ? 'Изменения сохранены' : 'Запись добавлена',
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted)
        showSnack(
          context,
          'Запись для этого сотрудника за данный период уже существует',
          isError: true,
        );
    }
    setState(() => _isSaving = false);
  }

  Widget _intField(TextEditingController ctrl, String label) => buildTextField(
    context: context,
    controller: ctrl,
    label: label,
    keyboardType: TextInputType.number,
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: Text(_isEdit ? 'Редактировать табель' : 'Новая запись табеля'),
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

            buildSectionHeader(context, 'Период'),
            buildTextField(
              context: context,
              controller: _periodMesyac,
              label: 'Период (ММ.ГГГГ)',
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),

            buildSectionHeader(context, 'Рабочее время'),
            _intField(_rabochihDney, 'Рабочих дней по норме'),
            _intField(_faktDney, 'Фактически отработано дней'),
            _intField(_faktChasov, 'Фактически отработано часов'),

            buildSectionHeader(context, 'Отсутствия'),
            _intField(_otpuskDney, 'Дней в отпуске'),
            _intField(_bolnichnyhDney, 'Дней на больничном'),
            _intField(_progulDney, 'Прогулы (дней)'),
            _intField(_komandirovkaDney, 'Командировка (дней)'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
