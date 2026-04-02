import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/organizacii/organizaciiitemgetfromlist.dart';
import 'package:zp/pages/spravochniki/podrazdelenia/podrazdeleniaitemgetfromlist.dart';

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

  int _organizaciyaId = 0;
  int _podrazdelenieId = 0;
  String _vidVyplaty = 'zarplata';
  String _sposobVyplaty = 'bank';
  String _statusVedomosti = 'chernovik';

  bool get _isEdit => widget.item != null;

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
              label: 'Подразделение (оставьте пустым для всей орг.)',
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
            buildTextField(
              context: context,
              controller: _periodMesyac,
              label: 'Период (ММ.ГГГГ)',
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _dateVyplaty,
              label: 'Дата выплаты',
              readOnly: true,
              onTap: () => _pickDate(_dateVyplaty),
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
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
            buildTextField(
              context: context,
              controller: _dateUtverzhdeniya,
              label: 'Дата утверждения',
              readOnly: true,
              onTap: () => _pickDate(_dateUtverzhdeniya),
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),

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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
