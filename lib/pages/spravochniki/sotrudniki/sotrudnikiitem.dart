import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/dolznosti/dolznostiitemgetfromlist.dart';
import 'package:zp/pages/spravochniki/podrazdelenia/podrazdeleniaitemgetfromlist.dart';
import 'package:zp/pages/spravochniki/uslTruda/uslTrudaitemgetfromlist.dart';
import 'package:zp/pages/documents/doc_generation_dialog.dart';

class SotrudnikiItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const SotrudnikiItem({super.key, this.item});
  @override
  State<SotrudnikiItem> createState() => _SotrudnikiItemState();
}

class _SotrudnikiItemState extends State<SotrudnikiItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  // ── Личные данные ─────────────────────────────────────────────
  late final TextEditingController _familiya;
  late final TextEditingController _name;
  late final TextEditingController _otchestvo;
  late final TextEditingController _dateBirth;
  late final TextEditingController _mestoBirth;
  late final TextEditingController _adresRegistr;
  late final TextEditingController _adresGitelstva;
  late final TextEditingController _telefon;
  late final TextEditingController _elPochta;
  late final TextEditingController _inn;
  late final TextEditingController _snils;

  // ── Паспорт ───────────────────────────────────────────────────
  late final TextEditingController _pasportSeria;
  late final TextEditingController _pasportNomer;
  late final TextEditingController _pasportVidan;
  late final TextEditingController _pasportVidanDateTime;
  late final TextEditingController _pasportKodPodrazdeleniya;

  // ── Банк ──────────────────────────────────────────────────────
  late final TextEditingController _bankRS;
  late final TextEditingController _bankKS;
  late final TextEditingController _bankBIK;
  late final TextEditingController _bankName;

  // ── Трудовая ──────────────────────────────────────────────────
  late final TextEditingController _datePriema;
  late final TextEditingController _dateUvolneniya;
  late final TextEditingController _dolzhnostNazvanie;
  late final TextEditingController _podrazNazvanie;
  late final TextEditingController _uslTrudaNazvanie;

  int _dolzhnostId = 0;
  int _podrazdelenieId = 0;
  int _uslTrudaId = 0; // ← исправление: поле было, но не сохранялось
  int _stavka = 1;

  // ── Маски ─────────────────────────────────────────────────────

  // Даты: ДДММГГГГ → ДД.ММ.ГГГГ
  final _maskDateBirth = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskPasportVidanDT = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskDatePriema = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _maskDateUvolneniya = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // ИНН: 12 цифр, без разделителей
  final _maskInn = MaskTextInputFormatter(
    mask: '############',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // СНИЛС: ХХХ-ХХХ-ХХХ-ХХ
  final _maskSnils = MaskTextInputFormatter(
    mask: '###-###-###-##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Телефон: +7-ХХХ-ХХХ-ХХХХ
  final _maskTelefon = MaskTextInputFormatter(
    mask: '+7-###-###-####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Паспорт серия: ХХ ХХ
  final _maskPasportSeria = MaskTextInputFormatter(
    mask: '## ##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Паспорт номер: ХХХХХХ
  final _maskPasportNomer = MaskTextInputFormatter(
    mask: '######',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Код подразделения паспорта: ХХХ-ХХХ
  final _maskPasportKod = MaskTextInputFormatter(
    mask: '###-###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Расчётный и корр. счёт: 20 цифр
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

  // БИК: 9 цифр
  final _maskBankBIK = MaskTextInputFormatter(
    mask: '#########',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool get _isEdit => widget.item != null;

  // ── Синхронизация маски с имеющимся значением ─────────────────
  void _syncMask(
    MaskTextInputFormatter mask,
    String value, {
    bool removeDots = true,
    bool removeDashes = false,
  }) {
    if (value.isEmpty) return;
    var raw = value;
    if (removeDots) raw = raw.replaceAll('.', '');
    if (removeDashes) raw = raw.replaceAll('-', '');
    mask.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: raw));
  }

  // ── Валидация дат ─────────────────────────────────────────────
  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      DateFormat('dd.MM.yyyy').parseStrict(value.trim());
      return null;
    } catch (_) {
      return 'Формат: ДД.ММ.ГГГГ';
    }
  }

  String? _validateRequiredDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Обязательное поле';
    return _validateDate(value);
  }

  @override
  void initState() {
    super.initState();
    final d = widget.item;

    _familiya = TextEditingController(text: d?['familiya']?.toString() ?? '');
    _name = TextEditingController(text: d?['name']?.toString() ?? '');
    _otchestvo = TextEditingController(text: d?['otchestvo']?.toString() ?? '');
    _dateBirth = TextEditingController(text: d?['dateBirth']?.toString() ?? '');
    _mestoBirth = TextEditingController(
      text: d?['mestoBirth']?.toString() ?? '',
    );
    _adresRegistr = TextEditingController(
      text: d?['adresRegistr']?.toString() ?? '',
    );
    _adresGitelstva = TextEditingController(
      text: d?['adresGitelstva']?.toString() ?? '',
    );
    _telefon = TextEditingController(text: d?['telefon']?.toString() ?? '');
    _elPochta = TextEditingController(text: d?['elPochta']?.toString() ?? '');
    _inn = TextEditingController(text: d?['inn']?.toString() ?? '');
    _snils = TextEditingController(text: d?['snils']?.toString() ?? '');
    _pasportSeria = TextEditingController(
      text: d?['pasportSeria']?.toString() ?? '',
    );
    _pasportNomer = TextEditingController(
      text: d?['pasportNomer']?.toString() ?? '',
    );
    _pasportVidan = TextEditingController(
      text: d?['pasportVidan']?.toString() ?? '',
    );
    _pasportVidanDateTime = TextEditingController(
      text: d?['pasportVidanDateTime']?.toString() ?? '',
    );
    _pasportKodPodrazdeleniya = TextEditingController(
      text: d?['pasportKodPodrazdeleniya']?.toString() ?? '',
    );
    _bankRS = TextEditingController(text: d?['bankRS']?.toString() ?? '');
    _bankKS = TextEditingController(text: d?['bankKS']?.toString() ?? '');
    _bankBIK = TextEditingController(text: d?['bankBIK']?.toString() ?? '');
    _bankName = TextEditingController(text: d?['bankName']?.toString() ?? '');
    _datePriema = TextEditingController(
      text: d?['datePriema']?.toString() ?? '',
    );
    _dateUvolneniya = TextEditingController(
      text: d?['dateUvolneniya']?.toString() ?? '',
    );
    _dolzhnostNazvanie = TextEditingController(
      text: d?['dolzhnostNazvanie']?.toString() ?? '',
    );
    _podrazNazvanie = TextEditingController(
      text: d?['podrazNazvanie']?.toString() ?? '',
    );
    _uslTrudaNazvanie = TextEditingController(
      text: d?['uslTrudaNazvanie']?.toString() ?? '',
    );

    _dolzhnostId = d?['dolzhnostId'] as int? ?? 0;
    _podrazdelenieId = d?['podrazdelenieId'] as int? ?? 0;
    _uslTrudaId = d?['uslTrudaId'] as int? ?? 0;
    _stavka = d?['stavka'] as int? ?? 1;

    // Синхронизация масок
    _syncMask(_maskDateBirth, _dateBirth.text);
    _syncMask(_maskPasportVidanDT, _pasportVidanDateTime.text);
    _syncMask(_maskDatePriema, _datePriema.text);
    _syncMask(_maskDateUvolneniya, _dateUvolneniya.text);
    _syncMask(_maskInn, _inn.text, removeDots: false);
    _syncMask(_maskSnils, _snils.text, removeDots: false, removeDashes: true);
    _syncMask(
      _maskTelefon,
      _telefon.text.replaceAll('+7', '').replaceFirst('-', ''),
      removeDots: false,
      removeDashes: true,
    );
    _syncMask(
      _maskPasportSeria,
      _pasportSeria.text.replaceAll(' ', ''),
      removeDots: false,
    );
    _syncMask(_maskPasportNomer, _pasportNomer.text, removeDots: false);
    _syncMask(
      _maskPasportKod,
      _pasportKodPodrazdeleniya.text,
      removeDots: false,
      removeDashes: true,
    );
    _syncMask(_maskBankRS, _bankRS.text, removeDots: false);
    _syncMask(_maskBankKS, _bankKS.text, removeDots: false);
    _syncMask(_maskBankBIK, _bankBIK.text, removeDots: false);
  }

  @override
  void dispose() {
    for (final c in [
      _familiya,
      _name,
      _otchestvo,
      _dateBirth,
      _mestoBirth,
      _adresRegistr,
      _adresGitelstva,
      _telefon,
      _elPochta,
      _inn,
      _snils,
      _pasportSeria,
      _pasportNomer,
      _pasportVidan,
      _pasportVidanDateTime,
      _pasportKodPodrazdeleniya,
      _bankRS,
      _bankKS,
      _bankBIK,
      _bankName,
      _datePriema,
      _dateUvolneniya,
      _dolzhnostNazvanie,
      _podrazNazvanie,
      _uslTrudaNazvanie,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Выбор из справочников ─────────────────────────────────────

  Future<void> _pickDolzhnost() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const DolznostiItemGetFromList()),
    );
    if (result != null) {
      setState(() {
        _dolzhnostId = result['id'] as int;
        _dolzhnostNazvanie.text = result['nazvanie']?.toString() ?? '';
      });
    }
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

  Future<void> _pickUslTruda() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const UslTrudaItemGetFromList()),
    );
    if (result != null) {
      setState(() {
        _uslTrudaId = result['id'] as int; // ← ключевое исправление
        _uslTrudaNazvanie.text = result['nazvanie']?.toString() ?? '';
      });
    }
  }

  Future<void> _openDocGenDialog() async {
    // Сохраняем если есть несохранённые данные — предупреждаем
    if (!_isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Сначала сохраните сотрудника, затем генерируйте документы',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await showDialog(
      context: context,
      builder: (_) =>
          DocGenerationDialog(sotrudnikId: widget.item!['id'] as int),
    );
  }

  // ── Сохранение ────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'familiya': _familiya.text.trim(),
      'name': _name.text.trim(),
      'otchestvo': _otchestvo.text.trim(),
      'dateBirth': _dateBirth.text.trim(),
      'mestoBirth': _mestoBirth.text.trim(),
      'adresRegistr': _adresRegistr.text.trim(),
      'adresGitelstva': _adresGitelstva.text.trim(),
      'telefon': _telefon.text.trim(),
      'elPochta': _elPochta.text.trim(),
      'inn': _inn.text.trim(),
      'snils': _snils.text.trim(),
      'pasportSeria': _pasportSeria.text.trim(),
      'pasportNomer': _pasportNomer.text.trim(),
      'pasportVidan': _pasportVidan.text.trim(),
      'pasportVidanDateTime': _pasportVidanDateTime.text.trim(),
      'pasportKodPodrazdeleniya': _pasportKodPodrazdeleniya.text.trim(),
      'bankRS': _bankRS.text.trim(),
      'bankKS': _bankKS.text.trim(),
      'bankBIK': _bankBIK.text.trim(),
      'bankName': _bankName.text.trim(),
      'datePriema': _datePriema.text.trim(),
      'dateUvolneniya': _dateUvolneniya.text.trim(),
      'dolzhnostId': _dolzhnostId,
      'podrazdelenieId': _podrazdelenieId,
      'uslTrudaId': _uslTrudaId, // ← сохраняется в БД
      'stavka': _stavka,
    };
    if (_isEdit) {
      await _db.update('sotrudniki', data, widget.item!['id'] as int);
    } else {
      await _db.insert('sotrudniki', data);
    }
    if (mounted) {
      showSnack(
        context,
        _isEdit ? 'Изменения сохранены' : 'Сотрудник добавлен',
      );
      Navigator.pop(context);
    }
  }

  // ── Вспомогательные виджеты ───────────────────────────────────

  // Поле с маской даты
  Widget _dateField(
    TextEditingController ctrl,
    MaskTextInputFormatter mask,
    String label, {
    bool required = false,
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
          helperText: 'Вводите только цифры',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        validator: required ? _validateRequiredDate : _validateDate,
      ),
    );
  }

  // Поле с произвольной маской
  Widget _maskedField(
    TextEditingController ctrl,
    MaskTextInputFormatter mask,
    String label, {
    String? helperText,
    String? hintText,
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
        title: Text(_isEdit ? 'Редактировать сотрудника' : 'Новый сотрудник'),
        actions: [
          // Кнопка генерации документов (только в режиме редактирования)
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Генерация документов',
              onPressed: _openDocGenDialog,
            ),
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
            // ── ФИО ──────────────────────────────────────────────
            buildSectionHeader(context, 'ФИО'),
            buildTextField(
              context: context,
              controller: _familiya,
              label: 'Фамилия',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _name,
              label: 'Имя',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _otchestvo,
              label: 'Отчество',
            ),

            // ── Личные данные ─────────────────────────────────────
            buildSectionHeader(context, 'Личные данные'),
            _dateField(
              _dateBirth,
              _maskDateBirth,
              'Дата рождения',
              required: true,
            ),
            buildTextField(
              context: context,
              controller: _mestoBirth,
              label: 'Место рождения',
            ),

            // ИНН: 12 цифр
            _maskedField(
              _inn,
              _maskInn,
              'ИНН',
              hintText: '____________',
              helperText: '12 цифр без разделителей',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final digits = v.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 12) return 'ИНН должен содержать 12 цифр';
                return null;
              },
            ),

            // СНИЛС: ХХХ-ХХХ-ХХХ-ХХ
            _maskedField(
              _snils,
              _maskSnils,
              'СНИЛС',
              hintText: '___-___-___-__',
              helperText: '11 цифр',
            ),

            // ── Адреса ────────────────────────────────────────────
            buildSectionHeader(context, 'Адреса'),
            buildTextField(
              context: context,
              controller: _adresRegistr,
              label: 'Адрес регистрации',
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              controller: _adresGitelstva,
              label: 'Адрес проживания',
              maxLines: 2,
            ),

            // ── Контакты ──────────────────────────────────────────
            buildSectionHeader(context, 'Контакты'),
            // Телефон: +7-ХХХ-ХХХ-ХХХХ
            _maskedField(
              _telefon,
              _maskTelefon,
              'Телефон',
              hintText: '+7-___-___-____',
              helperText: 'Вводите 10 цифр после +7',
            ),
            buildTextField(
              context: context,
              controller: _elPochta,
              label: 'Электронная почта',
              keyboardType: TextInputType.emailAddress,
            ),

            // ── Паспорт ───────────────────────────────────────────
            buildSectionHeader(context, 'Паспорт'),
            // Серия: ХХ ХХ
            _maskedField(
              _pasportSeria,
              _maskPasportSeria,
              'Серия',
              hintText: '__ __',
              helperText: '4 цифры',
            ),
            // Номер: ХХХХХХ
            _maskedField(
              _pasportNomer,
              _maskPasportNomer,
              'Номер',
              hintText: '______',
              helperText: '6 цифр',
            ),
            buildTextField(
              context: context,
              controller: _pasportVidan,
              label: 'Кем выдан',
            ),
            _dateField(
              _pasportVidanDateTime,
              _maskPasportVidanDT,
              'Дата выдачи',
            ),
            // Код подразделения: ХХХ-ХХХ
            _maskedField(
              _pasportKodPodrazdeleniya,
              _maskPasportKod,
              'Код подразделения',
              hintText: '___-___',
              helperText: '6 цифр',
            ),

            // ── Банковские реквизиты ──────────────────────────────
            buildSectionHeader(context, 'Банковские реквизиты'),
            // Расчётный счёт: 20 цифр
            _maskedField(
              _bankRS,
              _maskBankRS,
              'Расчётный счёт',
              hintText: '____________________',
              helperText: '20 цифр',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final digits = v.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 20) return 'Расчётный счёт — 20 цифр';
                return null;
              },
            ),
            // Корреспондентский счёт: 20 цифр
            _maskedField(
              _bankKS,
              _maskBankKS,
              'Корреспондентский счёт',
              hintText: '____________________',
              helperText: '20 цифр',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final digits = v.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 20) return 'Корр. счёт — 20 цифр';
                return null;
              },
            ),
            // БИК: 9 цифр
            _maskedField(
              _bankBIK,
              _maskBankBIK,
              'БИК',
              hintText: '_________',
              helperText: '9 цифр',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final digits = v.replaceAll(RegExp(r'\D'), '');
                if (digits.length != 9) return 'БИК — 9 цифр';
                return null;
              },
            ),
            buildTextField(
              context: context,
              controller: _bankName,
              label: 'Наименование банка',
            ),

            // ── Трудовая деятельность ─────────────────────────────
            buildSectionHeader(context, 'Трудовая деятельность'),
            buildTextField(
              context: context,
              controller: _dolzhnostNazvanie,
              label: 'Должность',
              readOnly: true,
              onTap: _pickDolzhnost,
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            buildTextField(
              context: context,
              controller: _podrazNazvanie,
              label: 'Подразделение',
              readOnly: true,
              onTap: _pickPodrazdelenie,
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            _dateField(
              _datePriema,
              _maskDatePriema,
              'Дата приёма на работу',
              required: true,
            ),
            _dateField(_dateUvolneniya, _maskDateUvolneniya, 'Дата увольнения'),

            // ── Ставка ────────────────────────────────────────────
            buildSectionHeader(context, 'Ставка'),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1,0')),
                ButtonSegment(value: 2, label: Text('0,5')),
                ButtonSegment(value: 3, label: Text('0,25')),
              ],
              selected: {_stavka},
              onSelectionChanged: (s) => setState(() => _stavka = s.first),
            ),

            // ── Условия труда ─────────────────────────────────────
            buildSectionHeader(context, 'Условия труда'),
            buildTextField(
              context: context,
              controller: _uslTrudaNazvanie,
              label: 'Условие труда на рабочем месте',
              readOnly: true,
              onTap: _pickUslTruda, // ← вызывает правильный метод
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
