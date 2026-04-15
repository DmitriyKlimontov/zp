import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikiitemgetfromlist.dart';
import 'package:zp/core/widgets/item_action_bar.dart';

class NalogovievichetiItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const NalogovievichetiItem({super.key, this.item});
  @override
  State<NalogovievichetiItem> createState() => _NalogovievichetiItemState();
}

class _NalogovievichetiItemState extends State<NalogovievichetiItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  late final TextEditingController _kodVycheta;
  late final TextEditingController _nazvanie;
  late final TextEditingController _summaVycheta;
  late final TextEditingController _dateNachala;
  late final TextEditingController _dateOkonchaniya;
  late final TextEditingController _osnovanie;
  late final TextEditingController _sotrudnikFio;

  int _sotrudnikId = 0;

  final _dateMaskNachala = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _dateMaskOkonchaniya = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool get _isEdit => widget.item != null;

  void _syncMask(MaskTextInputFormatter mask, String value) {
    if (value.isNotEmpty) {
      mask.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: value.replaceAll('.', '')),
      );
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      DateFormat('dd.MM.yyyy').parseStrict(value.trim());
      return null;
    } catch (_) {
      return 'Формат: ДД.ММ.ГГГГ';
    }
  }

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _kodVycheta = TextEditingController(
      text: d?['kodVycheta']?.toString() ?? '',
    );
    _nazvanie = TextEditingController(text: d?['nazvanie']?.toString() ?? '');
    _summaVycheta = TextEditingController(
      text: d?['summaVycheta']?.toString() ?? '',
    );
    _dateNachala = TextEditingController(
      text: d?['dateNachala']?.toString() ?? '',
    );
    _dateOkonchaniya = TextEditingController(
      text: d?['dateOkonchaniya']?.toString() ?? '',
    );
    _osnovanie = TextEditingController(text: d?['osnovanie']?.toString() ?? '');
    _sotrudnikFio = TextEditingController(text: d?['fio']?.toString() ?? '');
    _sotrudnikId = d?['sotrudnikId'] as int? ?? 0;
    _syncMask(_dateMaskNachala, _dateNachala.text);
    _syncMask(_dateMaskOkonchaniya, _dateOkonchaniya.text);
  }

  @override
  void dispose() {
    for (final c in [
      _kodVycheta,
      _nazvanie,
      _summaVycheta,
      _dateNachala,
      _dateOkonchaniya,
      _osnovanie,
      _sotrudnikFio,
    ]) {
      c.dispose();
    }
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
      'kodVycheta': int.tryParse(_kodVycheta.text.trim()) ?? 0,
      'nazvanie': _nazvanie.text.trim(),
      'summaVycheta': double.tryParse(_summaVycheta.text.trim()) ?? 0.0,
      'dateNachala': _dateNachala.text.trim(),
      'dateOkonchaniya': _dateOkonchaniya.text.trim(),
      'osnovanie': _osnovanie.text.trim(),
    };
    if (_isEdit) {
      await _db.update('nalogovyeVychety', data, widget.item!['id'] as int);
    } else {
      await _db.insert('nalogovyeVychety', data);
    }
    if (mounted) {
      showSnack(context, _isEdit ? 'Изменения сохранены' : 'Вычет добавлен');
      Navigator.pop(context);
    }
  }

  Widget _dateField(
    TextEditingController ctrl,
    MaskTextInputFormatter mask,
    String label, {
    String? helperText,
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
          helperText: helperText ?? 'Вводите только цифры, например: 01012024',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        validator: _validateDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: Text(_isEdit ? 'Редактировать вычет' : 'Новый вычет'),
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

            buildSectionHeader(context, 'Вычет'),
            buildTextField(
              context: context,
              controller: _kodVycheta,
              label: 'Код вычета (126, 127, 128...)',
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _nazvanie,
              label: 'Наименование вычета',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _summaVycheta,
              label: 'Сумма вычета, ₽',
              keyboardType: TextInputType.number,
            ),

            buildSectionHeader(context, 'Период применения'),
            _dateField(_dateNachala, _dateMaskNachala, 'Дата начала'),
            _dateField(
              _dateOkonchaniya,
              _dateMaskOkonchaniya,
              'Дата окончания',
              helperText: 'Оставьте пустым, если вычет бессрочный',
            ),

            buildSectionHeader(context, 'Основание'),
            buildTextField(
              context: context,
              controller: _osnovanie,
              label: 'Документ-основание',
              maxLines: 2,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ItemActionBar(
        isSaving: _isSaving,
        onCancel: () => Navigator.pop(context),
        onSave: _save,
      ),
    );
  }
}
