import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/podrazdelenia/podrazdeleniaitemgetfromlist.dart';

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
  late final TextEditingController _okladMin;
  late final TextEditingController _okladMax;
  late final TextEditingController _podrazNazvanie;

  int _podrazdelenieId = 0;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _nazvanie = TextEditingController(text: d?['nazvanie'] ?? '');
    _kod = TextEditingController(text: d?['kod'] ?? '');
    _okladMin = TextEditingController(text: d?['okladMin']?.toString() ?? '');
    _okladMax = TextEditingController(text: d?['okladMax']?.toString() ?? '');
    _podrazNazvanie = TextEditingController(
      text: d?['podrazNazvanie']?.toString() ?? '',
    );
    _podrazdelenieId = d?['podrazdelenieId'] as int? ?? 0;
  }

  @override
  void dispose() {
    for (final c in [_nazvanie, _kod, _okladMin, _okladMax, _podrazNazvanie])
      c.dispose();
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
    final data = {
      'nazvanie': _nazvanie.text.trim(),
      'kod': _kod.text.trim(),
      'okladMin': double.tryParse(_okladMin.text.trim()) ?? 0.0,
      'okladMax': double.tryParse(_okladMax.text.trim()) ?? 0.0,
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
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: Text(_isEdit ? 'Редактировать должность' : 'Новая должность'),
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
              label: 'Наименование должности',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _kod,
              label: 'Код должности',
            ),

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

            buildSectionHeader(context, 'Оклад'),
            buildTextField(
              context: context,
              controller: _okladMin,
              label: 'Минимальный оклад, ₽',
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              context: context,
              controller: _okladMax,
              label: 'Максимальный оклад, ₽',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
