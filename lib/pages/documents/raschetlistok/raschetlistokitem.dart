import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikiitemgetfromlist.dart';
import 'package:zp/widgets/item_action_bar.dart';

class RaschetlistokItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const RaschetlistokItem({super.key, this.item});
  @override
  State<RaschetlistokItem> createState() => _RaschetlistokItemState();
}

class _RaschetlistokItemState extends State<RaschetlistokItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  bool _isSaving = false;

  late final TextEditingController _sotrudnikFio;
  late final TextEditingController _dateFomirovaniya;
  late final TextEditingController _periodLabel;
  late final TextEditingController _god;
  late final TextEditingController _mesyac;
  late final TextEditingController _dolzhnost;
  late final TextEditingController _podrazdelenie;
  late final TextEditingController _tarifnayaStavka;
  late final TextEditingController _oklad;
  late final TextEditingController _premiya;
  late final TextEditingController _nadbavki;
  late final TextEditingController _otpusknye;
  late final TextEditingController _bolnichnye;
  late final TextEditingController _materialPomosh;
  late final TextEditingController _inyeNachisleniya;
  late final TextEditingController _itogoNachisleno;
  late final TextEditingController _ndfl;
  late final TextEditingController _pfr;
  late final TextEditingController _foms;
  late final TextEditingController _fss;
  late final TextEditingController _alimenty;
  late final TextEditingController _inyeUderzhaniya;
  late final TextEditingController _itogoUderzhano;
  late final TextEditingController _avansVyplachenRanee;
  late final TextEditingController _kVyplate;
  late final TextEditingController _faktVyplaceno;
  late final TextEditingController _dolg;
  late final TextEditingController _dateVydachi;

  // Маска даты формирования и выдачи
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

  int _sotrudnikId = 0;
  int _zarplataMesyacId = 0;
  bool _vydanSotrudniku = false;

  bool get _isEdit => widget.item != null;

  void _syncMask(MaskTextInputFormatter m, String v) {
    if (v.isEmpty) return;
    m.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: v.replaceAll('.', '')),
    );
  }

  @override
  void initState() {
    super.initState();
    final d = widget.item;
    _sotrudnikFio = TextEditingController(
      text: d?['sotrudnikFio']?.toString() ?? '',
    );
    _dateFomirovaniya = TextEditingController(
      text: d?['dateFomirovaniya']?.toString() ?? '',
    );
    _periodLabel = TextEditingController(
      text: d?['periodLabel']?.toString() ?? '',
    );
    _god = TextEditingController(text: d?['god']?.toString() ?? '');
    _mesyac = TextEditingController(text: d?['mesyac']?.toString() ?? '');
    _dolzhnost = TextEditingController(text: d?['dolzhnost']?.toString() ?? '');
    _podrazdelenie = TextEditingController(
      text: d?['podrazdelenie']?.toString() ?? '',
    );
    _tarifnayaStavka = TextEditingController(
      text: d?['tarifnayaStavka']?.toString() ?? '',
    );
    _oklad = TextEditingController(text: d?['oklad']?.toString() ?? '');
    _premiya = TextEditingController(text: d?['premiya']?.toString() ?? '');
    _nadbavki = TextEditingController(text: d?['nadbavki']?.toString() ?? '');
    _otpusknye = TextEditingController(text: d?['otpusknye']?.toString() ?? '');
    _bolnichnye = TextEditingController(
      text: d?['bolnichnye']?.toString() ?? '',
    );
    _materialPomosh = TextEditingController(
      text: d?['materialPomosh']?.toString() ?? '',
    );
    _inyeNachisleniya = TextEditingController(
      text: d?['inyeNachisleniya']?.toString() ?? '',
    );
    _itogoNachisleno = TextEditingController(
      text: d?['itogoNachisleno']?.toString() ?? '',
    );
    _ndfl = TextEditingController(text: d?['ndfl']?.toString() ?? '');
    _pfr = TextEditingController(text: d?['pfr']?.toString() ?? '');
    _foms = TextEditingController(text: d?['foms']?.toString() ?? '');
    _fss = TextEditingController(text: d?['fss']?.toString() ?? '');
    _alimenty = TextEditingController(text: d?['alimenty']?.toString() ?? '');
    _inyeUderzhaniya = TextEditingController(
      text: d?['inyeUderzhaniya']?.toString() ?? '',
    );
    _itogoUderzhano = TextEditingController(
      text: d?['itogoUderzhano']?.toString() ?? '',
    );
    _avansVyplachenRanee = TextEditingController(
      text: d?['avansVyplachenRanee']?.toString() ?? '',
    );
    _kVyplate = TextEditingController(text: d?['kVyplate']?.toString() ?? '');
    _faktVyplaceno = TextEditingController(
      text: d?['faktVyplaceno']?.toString() ?? '',
    );
    _dolg = TextEditingController(text: d?['dolg']?.toString() ?? '');
    _dateVydachi = TextEditingController(
      text: d?['dateVydachi']?.toString() ?? '',
    );
    _sotrudnikId = d?['sotrudnikId'] as int? ?? 0;
    _zarplataMesyacId = d?['zarplataMesyacId'] as int? ?? 0;
    _vydanSotrudniku = (d?['vydanSotrudniku'] as int? ?? 0) == 1;
    _syncMask(_maskDate1, _dateFomirovaniya.text);
    _syncMask(_maskDate2, _dateVydachi.text);
  }

  @override
  void dispose() {
    for (final c in [
      _sotrudnikFio,
      _dateFomirovaniya,
      _periodLabel,
      _god,
      _mesyac,
      _dolzhnost,
      _podrazdelenie,
      _tarifnayaStavka,
      _oklad,
      _premiya,
      _nadbavki,
      _otpusknye,
      _bolnichnye,
      _materialPomosh,
      _inyeNachisleniya,
      _itogoNachisleno,
      _ndfl,
      _pfr,
      _foms,
      _fss,
      _alimenty,
      _inyeUderzhaniya,
      _itogoUderzhano,
      _avansVyplachenRanee,
      _kVyplate,
      _faktVyplaceno,
      _dolg,
      _dateVydachi,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickSotrudnik() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const SotrudnikiItemGetFromList()),
    );
    if (result != null) {
      setState(() {
        _sotrudnikId = result['id'] as int;
        _sotrudnikFio.text =
            '${result['familiya']} ${result['name']} ${result['otchestvo']}';
        _dolzhnost.text = result['dolzhnostNazvanie']?.toString() ?? '';
        _podrazdelenie.text = result['podrazNazvanie']?.toString() ?? '';
      });
    }
  }

  // TODO: будет реализовано позже — генерация расчётного листка
  void _openDocGenDialog() {
    showSnack(context, 'Генерация расчётного листка — в разработке');
  }

  Widget _rublField(TextEditingController ctrl, String label) => buildTextField(
    context: context,
    controller: ctrl,
    label: '$label, ₽',
    keyboardType: TextInputType.number,
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final data = {
      'sotrudnikId': _sotrudnikId,
      'zarplataMesyacId': _zarplataMesyacId,
      'god': int.tryParse(_god.text.trim()) ?? 0,
      'mesyac': int.tryParse(_mesyac.text.trim()) ?? 0,
      'periodLabel': _periodLabel.text.trim(),
      'dateFomirovaniya': _dateFomirovaniya.text.trim(),
      'sotrudnikFio': _sotrudnikFio.text.trim(),
      'dolzhnost': _dolzhnost.text.trim(),
      'podrazdelenie': _podrazdelenie.text.trim(),
      'tarifnayaStavka': double.tryParse(_tarifnayaStavka.text.trim()) ?? 0.0,
      'oklad': double.tryParse(_oklad.text.trim()) ?? 0.0,
      'premiya': double.tryParse(_premiya.text.trim()) ?? 0.0,
      'nadbavki': double.tryParse(_nadbavki.text.trim()) ?? 0.0,
      'otpusknye': double.tryParse(_otpusknye.text.trim()) ?? 0.0,
      'bolnichnye': double.tryParse(_bolnichnye.text.trim()) ?? 0.0,
      'materialPomosh': double.tryParse(_materialPomosh.text.trim()) ?? 0.0,
      'inyeNachisleniya': double.tryParse(_inyeNachisleniya.text.trim()) ?? 0.0,
      'itogoNachisleno': double.tryParse(_itogoNachisleno.text.trim()) ?? 0.0,
      'ndfl': double.tryParse(_ndfl.text.trim()) ?? 0.0,
      'pfr': double.tryParse(_pfr.text.trim()) ?? 0.0,
      'foms': double.tryParse(_foms.text.trim()) ?? 0.0,
      'fss': double.tryParse(_fss.text.trim()) ?? 0.0,
      'alimenty': double.tryParse(_alimenty.text.trim()) ?? 0.0,
      'inyeUderzhaniya': double.tryParse(_inyeUderzhaniya.text.trim()) ?? 0.0,
      'itogoUderzhano': double.tryParse(_itogoUderzhano.text.trim()) ?? 0.0,
      'avansVyplachenRanee':
          double.tryParse(_avansVyplachenRanee.text.trim()) ?? 0.0,
      'kVyplate': double.tryParse(_kVyplate.text.trim()) ?? 0.0,
      'faktVyplaceno': double.tryParse(_faktVyplaceno.text.trim()) ?? 0.0,
      'dolg': double.tryParse(_dolg.text.trim()) ?? 0.0,
      'vydanSotrudniku': _vydanSotrudniku ? 1 : 0,
      'dateVydachi': _dateVydachi.text.trim(),
    };
    try {
      if (_isEdit) {
        await _db.update('raschetnyListok', data, widget.item!['id'] as int);
      } else {
        await _db.insert('raschetnyListok', data);
      }
      if (mounted) {
        showSnack(context, _isEdit ? 'Изменения сохранены' : 'Листок создан');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted)
        showSnack(
          context,
          'Листок для этого сотрудника за данный период уже существует',
          isError: true,
        );
    }
    if (mounted) setState(() => _isSaving = false);
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
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: Text(
          _isEdit ? 'Редактировать листок' : 'Новый расчётный листок',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ItemActionBar(
        isSaving: _isSaving,
        onCancel: () => Navigator.pop(context),
        onSave: _save,
        // TODO: onExtra подключится когда будет готова генерация расчётного листка
        //onExtra: _isEdit ? _openDocGenDialog : null,
        //extraIcon: Icons.picture_as_pdf_outlined,
        //extraLabel: 'Печать',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            buildSectionHeader(context, 'Сотрудник'),
            buildTextField(
              context: context,
              controller: _sotrudnikFio,
              label: 'Сотрудник',
              readOnly: true,
              onTap: _pickSotrudnik,
              suffixIcon: const Icon(Icons.arrow_forward_ios, size: 16),
              validator: (_) =>
                  _sotrudnikId == 0 ? 'Выберите сотрудника' : null,
            ),
            buildTextField(
              context: context,
              controller: _dolzhnost,
              label: 'Должность',
            ),
            buildTextField(
              context: context,
              controller: _podrazdelenie,
              label: 'Подразделение',
            ),
            _rublField(_tarifnayaStavka, 'Тарифная ставка (оклад)'),

            buildSectionHeader(context, 'Период'),
            buildTextField(
              context: context,
              controller: _periodLabel,
              label: 'Период (например: Март 2026)',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),
            buildTextField(
              context: context,
              controller: _god,
              label: 'Год',
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              context: context,
              controller: _mesyac,
              label: 'Месяц (1-12)',
              keyboardType: TextInputType.number,
            ),
            _dateField(_dateFomirovaniya, _maskDate1, 'Дата формирования'),

            buildSectionHeader(context, 'Начислено'),
            _rublField(_oklad, 'Оклад'),
            _rublField(_premiya, 'Премия'),
            _rublField(_nadbavki, 'Надбавки'),
            _rublField(_otpusknye, 'Отпускные'),
            _rublField(_bolnichnye, 'Больничные'),
            _rublField(_materialPomosh, 'Материальная помощь'),
            _rublField(_inyeNachisleniya, 'Иные начисления'),
            _rublField(_itogoNachisleno, 'Итого начислено'),

            buildSectionHeader(context, 'Удержано'),
            _rublField(_ndfl, 'НДФЛ'),
            _rublField(_pfr, 'ПФР'),
            _rublField(_foms, 'ФОМС'),
            _rublField(_fss, 'ФСС'),
            _rublField(_alimenty, 'Алименты'),
            _rublField(_inyeUderzhaniya, 'Иные удержания'),
            _rublField(_itogoUderzhano, 'Итого удержано'),

            buildSectionHeader(context, 'Выплаты'),
            _rublField(_avansVyplachenRanee, 'Аванс выплачен ранее'),
            _rublField(_kVyplate, 'К выплате'),
            _rublField(_faktVyplaceno, 'Фактически выплачено'),
            _rublField(_dolg, 'Долг'),

            buildSectionHeader(context, 'Выдача'),
            SwitchListTile(
              title: const Text('Листок выдан сотруднику'),
              value: _vydanSotrudniku,
              onChanged: (v) => setState(() => _vydanSotrudniku = v),
            ),
            _dateField(_dateVydachi, _maskDate2, 'Дата выдачи'),
          ],
        ),
      ),
    );
  }
}
