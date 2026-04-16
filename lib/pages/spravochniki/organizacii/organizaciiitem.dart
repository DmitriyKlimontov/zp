import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/widgets/item_action_bar.dart';

// ── Словарь налоговых режимов (ключ-значение) ─────────────────
const Map<int, String> _nalogoviyRezhimLabels = {
  0: 'Выберите режим налогообложения',
  1: 'Общий режим налогообложения (ОСН)',
  2: 'УСН',
  3: 'ЕНВД',
  4: 'ИТ компания',
};

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

  // ── Контроллеры ───────────────────────────────────────────────
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

  // Налоговый режим — выбор из выпадающего списка
  int _nalogoviyRezhim = 0;

  // ── Маски ─────────────────────────────────────────────────────

  final _maskInn = MaskTextInputFormatter(
    mask: '##########',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskKpp = MaskTextInputFormatter(
    mask: '#########',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskOgrn = MaskTextInputFormatter(
    mask: '#############',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskTelefon = MaskTextInputFormatter(
    mask: '+7-###-###-####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskBankRS = MaskTextInputFormatter(
    mask: '####################',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskBankKS = MaskTextInputFormatter(
    mask: '####################',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskBankBIK = MaskTextInputFormatter(
    mask: '#########',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool get _isEdit => widget.item != null;

  // ── Синхронизация маски ───────────────────────────────────────
  void _syncMask(MaskTextInputFormatter mask, String value) {
    if (value.isEmpty) return;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    mask.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: digits),
    );
  }

  // ── Валидаторы ────────────────────────────────────────────────

  String? _validateInn(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.replaceAll(RegExp(r'\D'), '').length != 10)
      return 'ИНН организации — 10 цифр';
    return null;
  }

  String? _validateKpp(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.replaceAll(RegExp(r'\D'), '').length != 9) return 'КПП — 9 цифр';
    return null;
  }

  String? _validateOgrn(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.replaceAll(RegExp(r'\D'), '').length != 13) return 'ОГРН — 13 цифр';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (!v.trim().contains('@') || !v.trim().contains('.')) {
      return 'Введите корректный email (содержит @ и .)';
    }
    return null;
  }

  String? _validateBankAccount(String? v, String label) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.replaceAll(RegExp(r'\D'), '').length != 20) return '$label — 20 цифр';
    return null;
  }

  String? _validateBik(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.replaceAll(RegExp(r'\D'), '').length != 9) return 'БИК — 9 цифр';
    return null;
  }

  // ── Инициализация ─────────────────────────────────────────────

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

    _nalogoviyRezhim = d?['nalogoviyRezhim'] as int? ?? 0;

    // Синхронизируем маски
    _syncMask(_maskInn, _inn.text);
    _syncMask(_maskKpp, _kpp.text);
    _syncMask(_maskOgrn, _ogrn.text);
    _syncMask(_maskBankRS, _bankRS.text);
    _syncMask(_maskBankKS, _bankKS.text);
    _syncMask(_maskBankBIK, _bankBIK.text);
    final telDigits = _telefon.text.replaceAll('+7', '').replaceAll('-', '');
    _syncMask(_maskTelefon, telDigits);
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

  // ── Сохранение ────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_nalogoviyRezhim == 0) {
      showSnack(context, 'Выберите режим налогообложения', isError: true);
      return;
    }
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
      'nalogoviyRezhim': _nalogoviyRezhim,
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

  // ── Вспомогательный виджет: поле с маской ────────────────────

  Widget _maskedField(
    TextEditingController ctrl,
    MaskTextInputFormatter mask,
    String label, {
    String? hintText,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        inputFormatters: [mask],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          helperText: helperText,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

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
            // ── Основные реквизиты ──────────────────────────────
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
            _maskedField(
              _inn,
              _maskInn,
              'ИНН',
              hintText: '__________',
              helperText: '10 цифр',
              validator: _validateInn,
            ),
            _maskedField(
              _kpp,
              _maskKpp,
              'КПП',
              hintText: '_________',
              helperText: '9 цифр',
              validator: _validateKpp,
            ),
            _maskedField(
              _ogrn,
              _maskOgrn,
              'ОГРН',
              hintText: '_____________',
              helperText: '13 цифр',
              validator: _validateOgrn,
            ),

            // ── Адреса ──────────────────────────────────────────
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

            // ── Контакты ────────────────────────────────────────
            buildSectionHeader(context, 'Контакты'),
            _maskedField(
              _telefon,
              _maskTelefon,
              'Телефон',
              hintText: '+7-___-___-____',
              helperText: 'Вводите 10 цифр после +7',
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _elPochta,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Электронная почта',
                  hintText: 'example@domain.ru',
                  helperText: 'Должна содержать @ и .',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
            ),

            // ── Банковские реквизиты ─────────────────────────────
            buildSectionHeader(context, 'Банковские реквизиты'),
            _maskedField(
              _bankRS,
              _maskBankRS,
              'Расчётный счёт',
              hintText: '____________________',
              helperText: '20 цифр',
              validator: (v) => _validateBankAccount(v, 'Расчётный счёт'),
            ),
            _maskedField(
              _bankKS,
              _maskBankKS,
              'Корреспондентский счёт',
              hintText: '____________________',
              helperText: '20 цифр',
              validator: (v) =>
                  _validateBankAccount(v, 'Корреспондентский счёт'),
            ),
            _maskedField(
              _bankBIK,
              _maskBankBIK,
              'БИК',
              hintText: '_________',
              helperText: '9 цифр',
              validator: _validateBik,
            ),
            buildTextField(
              context: context,
              controller: _bankName,
              label: 'Наименование банка',
            ),

            // ── Налоговый режим ──────────────────────────────────
            buildSectionHeader(context, 'Налоговый режим'),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<int>(
                value: _nalogoviyRezhim,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Режим налогообложения',
                  border: const OutlineInputBorder(),
                  // Подсвечиваем если не выбрано
                  enabledBorder: _nalogoviyRezhim == 0
                      ? OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      : null,
                ),
                items: _nalogoviyRezhimLabels.entries
                    .map(
                      (e) => DropdownMenuItem<int>(
                        value: e.key,
                        child: Text(
                          e.value,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _nalogoviyRezhim = v ?? 0),
                validator: (v) => (v == null || v == 0)
                    ? 'Выберите режим налогообложения'
                    : null,
              ),
            ),

            // ── Ответственные лица ───────────────────────────────
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
