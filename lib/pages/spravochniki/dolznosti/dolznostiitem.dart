import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/podrazdelenia/podrazdeleniaitemgetfromlist.dart';
import 'package:zp/core/widgets/item_action_bar.dart';

class DolznostiItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const DolznostiItem({super.key, this.item});
  @override
  State<DolznostiItem> createState() => _DolznostiItemState();
}

class _DolznostiItemState extends State<DolznostiItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  late final TextEditingController _nazvanie;
  late final TextEditingController _kod;
  late final TextEditingController _oklad;
  late final TextEditingController _chasovayaStavka;
  late final TextEditingController _podrazNazvanie;

  int _podrazdelenieId = 0;
  bool _isOklad = true; // true = оклад, false = часовая ставка

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _nazvanie = TextEditingController(text: d?['nazvanie']?.toString() ?? '');
    _kod = TextEditingController(text: d?['kod']?.toString() ?? '');
    _oklad = TextEditingController(text: d?['oklad']?.toString() ?? '');
    _chasovayaStavka = TextEditingController(
      text: d?['chasovayaStavka']?.toString() ?? '',
    );
    _podrazNazvanie = TextEditingController(
      text: d?['podrazNazvanie']?.toString() ?? '',
    );
    _podrazdelenieId = d?['podrazdelenieId'] as int? ?? 0;

    _isOklad = (d?['isOklad'] as int? ?? 1) == 1;
  }

  @override
  void dispose() {
    for (final c in [
      _nazvanie,
      _kod,
      _oklad,
      _chasovayaStavka,
      _podrazNazvanie,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPodrazdelenie() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const PodrazdeleniaItemGetFromList()),
    );
    if (result != null) {
      setState(() {
        _podrazdelenieId = result['id'] as int;
        _podrazNazvanie.text = result['nazvanie']?.toString() ?? '';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final okladVal = _isOklad
        ? double.tryParse(_oklad.text.trim()) ?? 0.0
        : 0.0;
    final chasovayaVal = !_isOklad
        ? double.tryParse(_chasovayaStavka.text.trim()) ?? 0.0
        : 0.0;

    final data = {
      'nazvanie': _nazvanie.text.trim(),
      'kod': _kod.text.trim(),
      'oklad': okladVal,
      'chasovayaStavka': chasovayaVal,
      'isOklad': _isOklad ? 1 : 0,
      'podrazdelenieId': _podrazdelenieId,
    };

    if (_isEdit) {
      await _db.update('dolzhnosti', data, widget.item!['id'] as int);
    } else {
      await _db.insert('dolzhnosti', data);
    }

    if (mounted) {
      showSnack(
        context,
        _isEdit ? 'Изменения сохранены' : 'Должность добавлена',
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: Text(_isEdit ? 'Редактировать должность' : 'Новая должность'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            // ── Основные данные ─────────────────────────────────
            buildSectionHeader(context, 'Основные данные'),
            buildTextField(
              context: context,
              controller: _nazvanie,
              label: 'Наименование должности',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _kod,
              label: 'Код должности',
            ),

            // ── Подразделение ───────────────────────────────────
            buildSectionHeader(context, 'Подразделение'),
            buildTextField(
              context: context,
              controller: _podrazNazvanie,
              label: 'Подразделение',
              readOnly: true,
              onTap: _pickPodrazdelenie,
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
              validator: (_) =>
                  _podrazdelenieId == 0 ? 'Выберите подразделение' : null,
            ),

            // ── Тип оплаты ──────────────────────────────────────
            buildSectionHeader(context, 'Тип оплаты труда'),

            // Пояснение: оклад и часовая ставка — взаимоисключающие
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 14, color: scheme.outline),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Оклад — фиксированная месячная сумма. '
                      'Часовая ставка умножается на фактически '
                      'отработанные часы. Выбрать можно только '
                      'один вид оплаты.',
                      style: text.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  ),
                ],
              ),
            ),

            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('Оклад'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.access_time_outlined),
                  label: Text('Часовая ставка'),
                ),
              ],
              selected: {_isOklad},
              onSelectionChanged: (s) => setState(() => _isOklad = s.first),
            ),
            const SizedBox(height: 16),

            // Показываем только активное поле
            if (_isOklad)
              buildTextField(
                context: context,
                controller: _oklad,
                label: 'Оклад, ₽/мес',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Введите оклад';
                  }
                  if (double.tryParse(v.trim()) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              )
            else
              buildTextField(
                context: context,
                controller: _chasovayaStavka,
                label: 'Часовая ставка, ₽/час',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Введите часовую ставку';
                  }
                  if (double.tryParse(v.trim()) == null) {
                    return 'Введите корректное число';
                  }
                  return null;
                },
              ),

            // Пояснение под активным полем
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _isOklad
                    ? 'Оклад делится на норму часов '
                          'расчётного месяца — часовая ставка будет меняться '
                          'каждый месяц.'
                    : 'Часовая ставка фиксирована и умножается на '
                          'фактически отработанные часы. '
                          'Норма часов месяца не влияет на ставку.',
                style: text.bodySmall?.copyWith(color: scheme.outline),
              ),
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
