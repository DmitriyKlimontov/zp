import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';

class OrganizaciiItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const OrganizaciiItem({super.key, this.item});

  @override
  State<OrganizaciiItem> createState() => _OrganizaciiItemState();
}

class _OrganizaciiItemState extends State<OrganizaciiItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  late final TextEditingController _nazvanie;
  late final TextEditingController _kratkoeNazvanie;
  late final TextEditingController _inn;
  late final TextEditingController _kpp;
  late final TextEditingController _ogrn;
  late final TextEditingController _yuridicheskiyAdres;
  late final TextEditingController _fakticheskiyAdres;
  late final TextEditingController _telefon;
  late final TextEditingController _elPochta;
  late final TextEditingController _bankRS;
  late final TextEditingController _bankKS;
  late final TextEditingController _bankBIK;
  late final TextEditingController _bankName;
  late final TextEditingController _direktorFio;
  late final TextEditingController _buhgalterFio;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _nazvanie = TextEditingController(text: d?['nazvanie'] ?? '');
    _kratkoeNazvanie = TextEditingController(text: d?['kratkoeNazvanie'] ?? '');
    _inn = TextEditingController(text: d?['inn'] ?? '');
    _kpp = TextEditingController(text: d?['kpp'] ?? '');
    _ogrn = TextEditingController(text: d?['ogrn'] ?? '');
    _yuridicheskiyAdres = TextEditingController(
      text: d?['yuridicheskiyAdres'] ?? '',
    );
    _fakticheskiyAdres = TextEditingController(
      text: d?['fakticheskiyAdres'] ?? '',
    );
    _telefon = TextEditingController(text: d?['telefon'] ?? '');
    _elPochta = TextEditingController(text: d?['elPochta'] ?? '');
    _bankRS = TextEditingController(text: d?['bankRS'] ?? '');
    _bankKS = TextEditingController(text: d?['bankKS'] ?? '');
    _bankBIK = TextEditingController(text: d?['bankBIK'] ?? '');
    _bankName = TextEditingController(text: d?['bankName'] ?? '');
    _direktorFio = TextEditingController(text: d?['direktorFio'] ?? '');
    _buhgalterFio = TextEditingController(text: d?['buhgalterFio'] ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _nazvanie,
      _kratkoeNazvanie,
      _inn,
      _kpp,
      _ogrn,
      _yuridicheskiyAdres,
      _fakticheskiyAdres,
      _telefon,
      _elPochta,
      _bankRS,
      _bankKS,
      _bankBIK,
      _bankName,
      _direktorFio,
      _buhgalterFio,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'nazvanie': _nazvanie.text.trim(),
      'kratkoeNazvanie': _kratkoeNazvanie.text.trim(),
      'inn': _inn.text.trim(),
      'kpp': _kpp.text.trim(),
      'ogrn': _ogrn.text.trim(),
      'yuridicheskiyAdres': _yuridicheskiyAdres.text.trim(),
      'fakticheskiyAdres': _fakticheskiyAdres.text.trim(),
      'telefon': _telefon.text.trim(),
      'elPochta': _elPochta.text.trim(),
      'bankRS': _bankRS.text.trim(),
      'bankKS': _bankKS.text.trim(),
      'bankBIK': _bankBIK.text.trim(),
      'bankName': _bankName.text.trim(),
      'direktorFio': _direktorFio.text.trim(),
      'buhgalterFio': _buhgalterFio.text.trim(),
    };
    if (_isEdit) {
      await _db.update('organizaciya', data, widget.item!['id'] as int);
    } else {
      await _db.insert('organizaciya', data);
    }
    if (mounted) {
      showSnack(
        context,
        _isEdit ? 'Изменения сохранены' : 'Организация добавлена',
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
          _isEdit ? 'Редактировать организацию' : 'Новая организация',
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
            buildSectionHeader(context, 'Основные реквизиты'),
            buildTextField(
              context: context,
              controller: _nazvanie,
              label: 'Полное наименование',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _kratkoeNazvanie,
              label: 'Краткое наименование',
            ),
            buildTextField(
              context: context,
              controller: _inn,
              label: 'ИНН',
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              context: context,
              controller: _kpp,
              label: 'КПП',
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              context: context,
              controller: _ogrn,
              label: 'ОГРН',
              keyboardType: TextInputType.number,
            ),

            buildSectionHeader(context, 'Адреса'),
            buildTextField(
              context: context,
              controller: _yuridicheskiyAdres,
              label: 'Юридический адрес',
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              controller: _fakticheskiyAdres,
              label: 'Фактический адрес',
              maxLines: 2,
            ),

            buildSectionHeader(context, 'Контакты'),
            buildTextField(
              context: context,
              controller: _telefon,
              label: 'Телефон',
              keyboardType: TextInputType.phone,
            ),
            buildTextField(
              context: context,
              controller: _elPochta,
              label: 'Электронная почта',
              keyboardType: TextInputType.emailAddress,
            ),

            buildSectionHeader(context, 'Банковские реквизиты'),
            buildTextField(
              context: context,
              controller: _bankRS,
              label: 'Расчётный счёт',
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              context: context,
              controller: _bankKS,
              label: 'Корреспондентский счёт',
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              context: context,
              controller: _bankBIK,
              label: 'БИК',
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              context: context,
              controller: _bankName,
              label: 'Наименование банка',
            ),

            buildSectionHeader(context, 'Ответственные лица'),
            buildTextField(
              context: context,
              controller: _direktorFio,
              label: 'ФИО директора',
            ),
            buildTextField(
              context: context,
              controller: _buhgalterFio,
              label: 'ФИО главного бухгалтера',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
