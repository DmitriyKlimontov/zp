import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/organizacii/organizaciiitemgetfromlist.dart';
import 'package:zp/core/widgets/item_action_bar.dart';

class PodrazdeleniaItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const PodrazdeleniaItem({super.key, this.item});

  @override
  State<PodrazdeleniaItem> createState() => _PodrazdeleniaItemState();
}

class _PodrazdeleniaItemState extends State<PodrazdeleniaItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  late final TextEditingController _nazvanie;
  late final TextEditingController _kod;
  late final TextEditingController _orgNazvanie;

  int _organizaciyaId = 0;
  int _rukovoditelId = 0;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _nazvanie = TextEditingController(text: d?['nazvanie'] ?? '');
    _kod = TextEditingController(text: d?['kod'] ?? '');
    _orgNazvanie = TextEditingController(text: d?['orgNazvanie'] ?? '');
    _organizaciyaId = d?['organizaciyaId'] as int? ?? 0;
    _rukovoditelId = d?['rukovoditelId'] as int? ?? 0;
  }

  @override
  void dispose() {
    _nazvanie.dispose();
    _kod.dispose();
    _orgNazvanie.dispose();
    super.dispose();
  }

  Future<void> _pickOrganizaciya() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const OrganizaciiItemGetFromList()),
    );
    if (result != null) {
      setState(() {
        _organizaciyaId = result['id'] as int;
        _orgNazvanie.text = result['nazvanie']?.toString() ?? '';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'nazvanie': _nazvanie.text.trim(),
      'kod': _kod.text.trim(),
      'organizaciyaId': _organizaciyaId,
      'rukovoditelId': _rukovoditelId,
    };
    if (_isEdit) {
      await _db.update('podrazdeleniya', data, widget.item!['id'] as int);
    } else {
      await _db.insert('podrazdeleniya', data);
    }
    if (mounted) {
      showSnack(
        context,
        _isEdit ? 'Изменения сохранены' : 'Подразделение добавлено',
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
          _isEdit ? 'Редактировать подразделение' : 'Новое подразделение',
        ),
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
              label: 'Наименование подразделения',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _kod,
              label: 'Код подразделения',
            ),

            buildSectionHeader(context, 'Организация'),
            buildTextField(
              context: context,
              controller: _orgNazvanie,
              label: 'Организация',
              readOnly: true,
              onTap: _pickOrganizaciya,
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
              validator: (_) =>
                  _organizaciyaId == 0 ? 'Выберите организацию' : null,
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
