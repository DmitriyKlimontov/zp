import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/organizacii/organizaciiitemgetfromlist.dart';
import 'package:zp/pages/spravochniki/podrazdelenia/podrazdeleniaitemgetfromlist.dart';
import 'package:zp/widgets/item_action_bar.dart';

class PlatvedomostItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const PlatvedomostItem({super.key, this.item});
  @override
  State<PlatvedomostItem> createState() => _PlatvedomostItemState();
}

class _PlatvedomostItemState extends State<PlatvedomostItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  late final TextEditingController _periodMesyac;
  late final TextEditingController _dateVyplaty;
  late final TextEditingController _itogoPoPerechen;
  late final TextEditingController _nomerVedomosti;
  late final TextEditingController _utverdilFio;
  late final TextEditingController _dateUtverzhdeniya;
  late final TextEditingController _primechanie;
  late final TextEditingController _orgNazvanie;
  late final TextEditingController _podrazNazvanie;

  final _maskPeriod = MaskTextInputFormatter(
    mask: '##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskDate1 = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskDate2 = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  int _organizaciyaId = 0;
  int _podrazdelenieId = 0;
  String _vidVyplaty = 'zarplata';
  String _sposobVyplaty = 'bank';
  String _statusVedomosti = 'chernovik';

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
    _itogoPoPerechen = TextEditingController(
      text: d?['itogoPoPerechen']?.toString() ?? '',
    );
    _nomerVedomosti = TextEditingController(
      text: d?['nomerVedomosti']?.toString() ?? '',
    );
    _utverdilFio = TextEditingController(
      text: d?['utverdilFio']?.toString() ?? '',
    );
    _dateUtverzhdeniya = TextEditingController(
      text: d?['dateUtverzhdeniya']?.toString() ?? '',
    );
    _primechanie = TextEditingController(
      text: d?['primechanie']?.toString() ?? '',
    );
    _orgNazvanie = TextEditingController(
      text: d?['orgNazvanie']?.toString() ?? '',
    );
    _podrazNazvanie = TextEditingController(
      text: d?['podrazNazvanie']?.toString() ?? '',
    );
    _organizaciyaId = d?['organizaciyaId'] as int? ?? 0;
    _podrazdelenieId = d?['podrazdelenieId'] as int? ?? 0;
    _vidVyplaty = d?['vidVyplaty']?.toString() ?? 'zarplata';
    _sposobVyplaty = d?['sposobVyplaty']?.toString() ?? 'bank';
    _statusVedomosti = d?['statusVedomosti']?.toString() ?? 'chernovik';
    _syncMask(_maskPeriod, _periodMesyac.text);
    _syncMask(_maskDate1, _dateVyplaty.text);
    _syncMask(_maskDate2, _dateUtverzhdeniya.text);
  }

  @override
  void dispose() {
    for (final c in [
      _periodMesyac,
      _dateVyplaty,
      _itogoPoPerechen,
      _nomerVedomosti,
      _utverdilFio,
      _dateUtverzhdeniya,
      _primechanie,
      _orgNazvanie,
      _podrazNazvanie,
    ])
      c.dispose();
    super.dispose();
  }

  Widget _dateField(
    TextEditingController ctrl,
    MaskTextInputFormatter mask,
    String label,
  ) => Padding(
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
      validator: _validateDate,
    ),
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'organizaciyaId': _organizaciyaId,
      'podrazdelenieId': _podrazdelenieId,
      'periodMesyac': _periodMesyac.text.trim(),
      'vidVyplaty': _vidVyplaty,
      'dateVyplaty': _dateVyplaty.text.trim(),
      'itogoPoPerechen': double.tryParse(_itogoPoPerechen.text.trim()) ?? 0.0,
      'sposobVyplaty': _sposobVyplaty,
      'nomerVedomosti': _nomerVedomosti.text.trim(),
      'statusVedomosti': _statusVedomosti,
      'utverdilFio': _utverdilFio.text.trim(),
      'dateUtverzhdeniya': _dateUtverzhdeniya.text.trim(),
      'primechanie': _primechanie.text.trim(),
    };
    if (_isEdit) {
      await _db.update('platezhVedomost', data, widget.item!['id'] as int);
    } else {
      await _db.insert('platezhVedomost', data);
    }
    if (mounted) {
      showSnack(context, _isEdit ? 'Изменения сохранены' : 'Ведомость создана');
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
        title: Text(_isEdit ? 'Редактировать ведомость' : 'Новая ведомость'),
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
            buildSectionHeader(context, 'Организация и подразделение'),
            buildTextField(
              context: context,
              controller: _orgNazvanie,
              label: 'Организация',
              readOnly: true,
              onTap: () async {
                final r = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrganizaciiItemGetFromList(),
                  ),
                );
                if (r != null)
                  setState(() {
                    _organizaciyaId = r['id'] as int;
                    _orgNazvanie.text = r['nazvanie']?.toString() ?? '';
                  });
              },
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
              validator: (_) =>
                  _organizaciyaId == 0 ? 'Выберите организацию' : null,
            ),
            buildTextField(
              context: context,
              controller: _podrazNazvanie,
              label: 'Подразделение',
              readOnly: true,
              onTap: () async {
                final r = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PodrazdeleniaItemGetFromList(),
                  ),
                );
                if (r != null)
                  setState(() {
                    _podrazdelenieId = r['id'] as int;
                    _podrazNazvanie.text = r['nazvanie']?.toString() ?? '';
                  });
              },
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
            ),

            buildSectionHeader(context, 'Реквизиты ведомости'),
            buildTextField(
              context: context,
              controller: _nomerVedomosti,
              label: 'Номер ведомости',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _periodMesyac,
                inputFormatters: [_maskPeriod],
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
            _dateField(_dateVyplaty, _maskDate1, 'Дата выплаты'),
            buildTextField(
              context: context,
              controller: _itogoPoPerechen,
              label: 'Итого по ведомости, ₽',
              keyboardType: TextInputType.number,
            ),

            buildSectionHeader(context, 'Вид выплаты'),
            DropdownButtonFormField<String>(
              value: _vidVyplaty,
              decoration: const InputDecoration(
                labelText: 'Вид выплаты',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'zarplata', child: Text('Зарплата')),
                DropdownMenuItem(value: 'avans', child: Text('Аванс')),
                DropdownMenuItem(value: 'otpusknye', child: Text('Отпускные')),
                DropdownMenuItem(value: 'prochee', child: Text('Прочее')),
              ],
              onChanged: (v) => setState(() => _vidVyplaty = v!),
            ),
            const SizedBox(height: 16),

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

            buildSectionHeader(context, 'Утверждение'),
            buildTextField(
              context: context,
              controller: _utverdilFio,
              label: 'Кто утвердил (ФИО)',
            ),
            _dateField(_dateUtverzhdeniya, _maskDate2, 'Дата утверждения'),

            buildSectionHeader(context, 'Статус'),
            DropdownButtonFormField<String>(
              value: _statusVedomosti,
              decoration: const InputDecoration(
                labelText: 'Статус',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'chernovik', child: Text('Черновик')),
                DropdownMenuItem(
                  value: 'utverzdena',
                  child: Text('Утверждена'),
                ),
                DropdownMenuItem(value: 'vyplacena', child: Text('Выплачена')),
                DropdownMenuItem(value: 'zakryta', child: Text('Закрыта')),
              ],
              onChanged: (v) => setState(() => _statusVedomosti = v!),
            ),
            const SizedBox(height: 16),
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
