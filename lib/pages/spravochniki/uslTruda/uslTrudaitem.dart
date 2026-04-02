import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';

class UslTrudaItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const UslTrudaItem({super.key, this.item});
  @override
  State<UslTrudaItem> createState() => _UslTrudaItemState();
}

class _UslTrudaItemState extends State<UslTrudaItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  late final TextEditingController _nazvanie;
  late final TextEditingController _graficRaboty;
  late final TextEditingController _chasovVSmene;
  late final TextEditingController _vrNachalaRaboty;
  late final TextEditingController _vrOkonchaniyaRaboty;
  late final TextEditingController _kolObedennyhPereryv;
  late final TextEditingController _prodObedennyhPereryv;
  late final TextEditingController _chasovVechernih;
  late final TextEditingController _chasovNochnykh;
  late final TextEditingController _primechanie;

  String _klassUslTruda = '2';
  bool _normirovannoye = true;
  bool _estObedPereryv = true; // вспомогательный флаг

  bool get _isEdit => widget.item != null;

  static const List<String> _klassyOptions = [
    '1',
    '2',
    '3.1',
    '3.2',
    '3.3',
    '3.4',
    '4',
  ];

  static const List<String> _klassyLabels = [
    '1 — Оптимальные',
    '2 — Допустимые',
    '3.1 — Вредные',
    '3.2 — Вредные',
    '3.3 — Вредные',
    '3.4 — Вредные',
    '4 — Опасные',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _nazvanie = TextEditingController(text: d?['nazvanie']?.toString() ?? '');
    _graficRaboty = TextEditingController(
      text: d?['graficRaboty']?.toString() ?? '',
    );
    _chasovVSmene = TextEditingController(
      text: d?['chasovVSmene']?.toString() ?? '8',
    );
    _vrNachalaRaboty = TextEditingController(
      text: d?['vrNachalaRaboty']?.toString() ?? '',
    );
    _vrOkonchaniyaRaboty = TextEditingController(
      text: d?['vrOkonchaniyaRaboty']?.toString() ?? '',
    );
    _kolObedennyhPereryv = TextEditingController(
      text: d?['kolObedennyhPereryv']?.toString() ?? '1',
    );
    _prodObedennyhPereryv = TextEditingController(
      text: d?['prodObedennyhPereryv']?.toString() ?? '60',
    );
    _chasovVechernih = TextEditingController(
      text: d?['chasovVechernih']?.toString() ?? '0',
    );
    _chasovNochnykh = TextEditingController(
      text: d?['chasovNochnykh']?.toString() ?? '0',
    );
    _primechanie = TextEditingController(
      text: d?['primechanie']?.toString() ?? '',
    );
    _klassUslTruda = d?['klassUslTruda']?.toString() ?? '2';
    _normirovannoye = (d?['normirovannoye'] as int? ?? 1) == 1;
    final kol = d?['kolObedennyhPereryv'] as int? ?? 1;
    _estObedPereryv = kol > 0;
    if (!_klassyOptions.contains(_klassUslTruda)) _klassUslTruda = '2';
  }

  @override
  void dispose() {
    for (final c in [
      _nazvanie,
      _graficRaboty,
      _chasovVSmene,
      _vrNachalaRaboty,
      _vrOkonchaniyaRaboty,
      _kolObedennyhPereryv,
      _prodObedennyhPereryv,
      _chasovVechernih,
      _chasovNochnykh,
      _primechanie,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final initial = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final kolPereryv = _estObedPereryv
        ? int.tryParse(_kolObedennyhPereryv.text.trim()) ?? 1
        : 0;
    final prodPereryv = _estObedPereryv
        ? int.tryParse(_prodObedennyhPereryv.text.trim()) ?? 60
        : 0;

    final data = {
      'nazvanie': _nazvanie.text.trim(),
      'klassUslTruda': _klassUslTruda,
      'graficRaboty': _graficRaboty.text.trim(),
      'chasovVSmene': int.tryParse(_chasovVSmene.text.trim()) ?? 8,
      'vrNachalaRaboty': _vrNachalaRaboty.text.trim(),
      'vrOkonchaniyaRaboty': _vrOkonchaniyaRaboty.text.trim(),
      'kolObedennyhPereryv': kolPereryv,
      'prodObedennyhPereryv': prodPereryv,
      'normirovannoye': _normirovannoye ? 1 : 0,
      'chasovVechernih': int.tryParse(_chasovVechernih.text.trim()) ?? 0,
      'chasovNochnykh': int.tryParse(_chasovNochnykh.text.trim()) ?? 0,
      'primechanie': _primechanie.text.trim(),
    };

    if (_isEdit) {
      await _db.updateUslTruda(data, widget.item!['id'] as int);
    } else {
      await _db.insertUslTruda(data);
    }

    if (mounted) {
      showSnack(
        context,
        _isEdit ? 'Изменения сохранены' : 'Условие труда добавлено',
      );
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
        title: Text(
          _isEdit ? 'Редактировать условие труда' : 'Новое условие труда',
        ),
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
            buildSectionHeader(context, 'Основные данные'),
            buildTextField(
              context: context,
              controller: _nazvanie,
              label: 'Наименование условия труда',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),

            buildSectionHeader(context, 'Класс условий труда'),
            DropdownButtonFormField<String>(
              value: _klassUslTruda,
              decoration: const InputDecoration(
                labelText: 'Класс условий труда',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                _klassyOptions.length,
                (i) => DropdownMenuItem(
                  value: _klassyOptions[i],
                  child: Text(_klassyLabels[i]),
                ),
              ),
              onChanged: (v) => setState(() => _klassUslTruda = v!),
            ),
            const SizedBox(height: 16),

            buildSectionHeader(context, 'График работы'),
            buildTextField(
              context: context,
              controller: _graficRaboty,
              label: 'График (например: 5-дневная рабочая неделя)',
              maxLines: 2,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),

            buildSectionHeader(context, 'Рабочее время'),
            buildTextField(
              context: context,
              controller: _chasovVSmene,
              label: 'Часов в смене',
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _vrNachalaRaboty,
              label: 'Время начала работы',
              readOnly: true,
              onTap: () => _pickTime(_vrNachalaRaboty),
              suffixIcon: const Icon(Icons.access_time_outlined, size: 18),
            ),
            buildTextField(
              context: context,
              controller: _vrOkonchaniyaRaboty,
              label: 'Время окончания работы',
              readOnly: true,
              onTap: () => _pickTime(_vrOkonchaniyaRaboty),
              suffixIcon: const Icon(Icons.access_time_outlined, size: 18),
            ),

            buildSectionHeader(context, 'Нормирование'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Нормируемое рабочее время'),
              subtitle: Text(
                _normirovannoye
                    ? 'Продолжительность рабочего дня чётко установлена'
                    : 'Ненормируемый рабочий день',
              ),
              value: _normirovannoye,
              onChanged: (v) => setState(() => _normirovannoye = v),
            ),

            buildSectionHeader(context, 'Обеденные перерывы'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Есть обеденный перерыв'),
              value: _estObedPereryv,
              onChanged: (v) => setState(() {
                _estObedPereryv = v;
                if (!v) {
                  _kolObedennyhPereryv.text = '0';
                  _prodObedennyhPereryv.text = '0';
                } else {
                  _kolObedennyhPereryv.text = '1';
                  _prodObedennyhPereryv.text = '60';
                }
              }),
            ),
            if (_estObedPereryv) ...[
              buildTextField(
                context: context,
                controller: _kolObedennyhPereryv,
                label: 'Количество перерывов',
                keyboardType: TextInputType.number,
              ),
              buildTextField(
                context: context,
                controller: _prodObedennyhPereryv,
                label: 'Суммарная продолжительность перерывов, мин',
                keyboardType: TextInputType.number,
              ),
            ],

            buildSectionHeader(context, 'Вечерние и ночные часы'),
            buildTextField(
              context: context,
              controller: _chasovVechernih,
              label: 'Вечерних часов в смене (18:00–22:00)',
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              context: context,
              controller: _chasovNochnykh,
              label: 'Ночных часов в смене (22:00–06:00)',
              keyboardType: TextInputType.number,
            ),

            buildSectionHeader(context, 'Примечание'),
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
