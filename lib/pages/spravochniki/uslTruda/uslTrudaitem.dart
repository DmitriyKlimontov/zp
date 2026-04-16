import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/widgets/item_action_bar.dart';

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

  // Контроллеры
  late final TextEditingController _nazvanie;
  late final TextEditingController _graficRaboty;
  late final TextEditingController _chasovVSmene;
  late final TextEditingController _vrNachalaRaboty;
  late final TextEditingController _vrOkonchaniyaRaboty;
  late final TextEditingController _kolObedennyhPereryv;
  late final TextEditingController _prodObedennyhPereryv;
  late final TextEditingController _chasovVechernih;
  late final TextEditingController _chasovNochnykh;
  late final TextEditingController _rayonnyKoefficient;
  late final TextEditingController _nadbavkaVechernye;
  late final TextEditingController _nadbavkaNochnye;
  late final TextEditingController _severnyKoefficient;
  late final TextEditingController _severnaaNadbavka;
  late final TextEditingController _primechanie;

  String _klassUslTruda = '2';
  bool _normirovannoye = true;
  bool _estObedPereryv = true;
  bool _estSevernyeNadbavki = false;

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
    _rayonnyKoefficient = TextEditingController(
      text: (d?['rayonnyKoefficient'] as int? ?? 0).toString(),
    );
    _nadbavkaVechernye = TextEditingController(
      text: (d?['nadbavkaVechernye'] as int? ?? 0).toString(),
    );
    _nadbavkaNochnye = TextEditingController(
      text: (d?['nadbavkaNochnye'] as int? ?? 20).toString(),
    );
    _severnyKoefficient = TextEditingController(
      text: (d?['severnyKoefficient'] as int? ?? 0).toString(),
    );
    _severnaaNadbavka = TextEditingController(
      text: (d?['severnaaNadbavka'] as int? ?? 0).toString(),
    );
    _primechanie = TextEditingController(
      text: d?['primechanie']?.toString() ?? '',
    );

    _klassUslTruda = d?['klassUslTruda']?.toString() ?? '2';
    _normirovannoye = (d?['normirovannoye'] as int? ?? 1) == 1;
    _estSevernyeNadbavki = (d?['estSevernyeNadbavki'] as int? ?? 0) == 1;
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
      _rayonnyKoefficient,
      _nadbavkaVechernye,
      _nadbavkaNochnye,
      _severnyKoefficient,
      _severnaaNadbavka,
      _primechanie,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
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
      'rayonnyKoefficient': int.tryParse(_rayonnyKoefficient.text.trim()) ?? 0,
      'nadbavkaVechernye': int.tryParse(_nadbavkaVechernye.text.trim()) ?? 0,
      'nadbavkaNochnye': int.tryParse(_nadbavkaNochnye.text.trim()) ?? 20,
      'severnyKoefficient': int.tryParse(_severnyKoefficient.text.trim()) ?? 0,
      'severnaaNadbavka': int.tryParse(_severnaaNadbavka.text.trim()) ?? 0,
      'estSevernyeNadbavki': _estSevernyeNadbavki ? 1 : 0,
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

  // Вспомогательный виджет — поле только для целых чисел с суффиксом %
  Widget _percentField(
    TextEditingController ctrl,
    String label, {
    String? helperText,
    int defaultVal = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          hintText: '$defaultVal',
          helperText: helperText,
          border: const OutlineInputBorder(),
          suffixText: '%',
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return null;
          final n = int.tryParse(v.trim());
          if (n == null || n < 0) return 'Введите целое число ≥ 0';
          return null;
        },
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
        title: Text(
          _isEdit ? 'Редактировать условие труда' : 'Новое условие труда',
        ),
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
              label: 'Наименование условия труда',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),

            // ── Класс условий труда ─────────────────────────────
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

            // ── График работы ───────────────────────────────────
            buildSectionHeader(context, 'График работы'),
            buildTextField(
              context: context,
              controller: _graficRaboty,
              label: 'График (например: 5-дневная рабочая неделя)',
              maxLines: 2,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),

            // ── Рабочее время ───────────────────────────────────
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

            // ── Нормирование ────────────────────────────────────
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

            // ── Обеденные перерывы ──────────────────────────────
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

            // ── Вечерние и ночные часы ──────────────────────────
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

            // ── Надбавки за вечернее и ночное время ─────────────
            buildSectionHeader(context, 'Надбавки за вечернее и ночное время'),
            _percentField(
              _nadbavkaVechernye,
              'Надбавка за вечернее время',
              helperText:
                  'Целые числа. 0 — надбавка не установлена. '
                  'Пример: 20 означает +20% за вечерние часы.',
            ),
            _percentField(
              _nadbavkaNochnye,
              'Надбавка за ночное время',
              helperText:
                  'Минимум по ТК РФ — 20%. '
                  'Целые числа. 0 — если сотрудник не работает ночью.',
              defaultVal: 20,
            ),

            // ── Районный коэффициент ────────────────────────────
            buildSectionHeader(context, 'Районный коэффициент'),
            _percentField(
              _rayonnyKoefficient,
              'Районный коэффициент',
              helperText:
                  'Целые числа. 0 — не применяется. '
                  'Пример: 15 означает +15% к зарплате.',
            ),

            // ── Северные надбавки ───────────────────────────────
            buildSectionHeader(context, 'Северные надбавки'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Применяются северные надбавки'),
              subtitle: const Text(
                'Процентные надбавки за работу в районах '
                'Крайнего Севера и приравненных местностях',
              ),
              value: _estSevernyeNadbavki,
              onChanged: (v) => setState(() {
                _estSevernyeNadbavki = v;
                if (!v) {
                  _severnyKoefficient.text = '0';
                  _severnaaNadbavka.text = '0';
                }
              }),
            ),
            if (_estSevernyeNadbavki) ...[
              const SizedBox(height: 8),
              _percentField(
                _severnyKoefficient,
                'Северный коэффициент',
                helperText:
                    'Районный коэффициент для КС и приравненных '
                    'местностей. Пример: 50 означает ×1,5 к зарплате.',
              ),
              _percentField(
                _severnaaNadbavka,
                'Процентная надбавка (северная)',
                helperText:
                    'Надбавка за стаж работы в районах КС. '
                    'Начисляется сверх районного коэффициента. '
                    'Пример: 80 — максимум для КС.',
              ),
            ],

            // ── Примечание ──────────────────────────────────────
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ItemActionBar(
        isSaving: _isSaving,
        onCancel: () => Navigator.pop(context),
        onSave: _save,
      ),
    );
  }
}
