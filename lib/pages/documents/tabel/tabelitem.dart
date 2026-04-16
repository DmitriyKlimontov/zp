import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikiitemgetfromlist.dart';
import 'package:zp/services/work_calendar.dart';
import 'package:zp/pages/settings/work_calendar_page.dart';
import 'package:zp/widgets/item_action_bar.dart';

class TabelItem extends StatefulWidget {
  final Map<String, dynamic>? item;
  const TabelItem({super.key, this.item});
  @override
  State<TabelItem> createState() => _TabelItemState();
}

class _TabelItemState extends State<TabelItem> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();
  final _calendar = WorkCalendar.instance;
  bool _isSaving = false;

  final _periodMask = MaskTextInputFormatter(
    mask: '##.####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Норма из WorkCalendar — только отображение, НЕ сохраняется в БД
  final _normaChasov = TextEditingController();

  // Поля формы — сохраняются в БД
  late final TextEditingController _periodMesyac;
  late final TextEditingController _rabochihDney;
  late final TextEditingController _faktDney;
  late final TextEditingController
  _faktChasov; // фактически отработано часов, REAL
  late final TextEditingController _vechernikhChasov;
  late final TextEditingController _nochnykChasov;
  late final TextEditingController _sverkhurochnykhChasov;
  late final TextEditingController _prazdnichikhChasov;
  late final TextEditingController _otpuskDney;
  late final TextEditingController _bolnichnyhDney;
  late final TextEditingController _progulDney;
  late final TextEditingController _komandirovkaDney;
  late final TextEditingController _sotrudnikFio;

  int _sotrudnikId = 0;
  String _weekType = '40';
  bool _normAutoFilled = false;

  // Флаг авто-подстановки сверхурочных: сбрасывается при смене нормы
  bool _overtimeAutoSet = false;

  bool get _isEdit => widget.item != null;

  // ── Утилиты ─────────────────────────────────────────────────

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final d = (v as num).toDouble();
    return d == d.floorToDouble() ? d.toStringAsFixed(0) : d.toString();
  }

  double _pd(String s) => double.tryParse(s.trim().replaceAll(',', '.')) ?? 0.0;

  void _syncPeriodMask(String value) {
    if (value.isEmpty) return;
    _periodMask.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: value.replaceAll('.', '')),
    );
  }

  // ── Инициализация ────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final d = widget.item;

    _periodMesyac = TextEditingController(
      text: d?['periodMesyac']?.toString() ?? '',
    );
    _rabochihDney = TextEditingController(
      text: d?['rabochihDney']?.toString() ?? '0',
    );
    _faktDney = TextEditingController(text: d?['faktDney']?.toString() ?? '0');
    _faktChasov = TextEditingController(text: _fmt(d?['faktChasov']));
    _vechernikhChasov = TextEditingController(
      text: _fmt(d?['vechernikhChasov']),
    );
    _nochnykChasov = TextEditingController(text: _fmt(d?['nochnykChasov']));
    _sverkhurochnykhChasov = TextEditingController(
      text: _fmt(d?['sverkhurochnykhChasov']),
    );
    _prazdnichikhChasov = TextEditingController(
      text: _fmt(d?['prazdnichikhChasov']),
    );
    _otpuskDney = TextEditingController(
      text: d?['otpuskDney']?.toString() ?? '0',
    );
    _bolnichnyhDney = TextEditingController(
      text: d?['bolnichnyhDney']?.toString() ?? '0',
    );
    _progulDney = TextEditingController(
      text: d?['progulDney']?.toString() ?? '0',
    );
    _komandirovkaDney = TextEditingController(
      text: d?['komandirovkaDney']?.toString() ?? '0',
    );
    _sotrudnikFio = TextEditingController(text: d?['fio']?.toString() ?? '');
    _sotrudnikId = d?['sotrudnikId'] as int? ?? 0;

    _syncPeriodMask(_periodMesyac.text);

    // При открытии существующей записи — подтянуть норму из календаря
    // чтобы сводка показывала актуальное отклонение
    if (_periodMesyac.text.trim().length >= 7) {
      _fillNormFromCalendar(_periodMesyac.text.trim(), silent: true);
    }

    // Listeners
    _periodMesyac.addListener(_onPeriodChanged);
    _faktChasov.addListener(_onFaktChasovChanged);

    for (final c in [
      _rabochihDney,
      _faktDney,
      _vechernikhChasov,
      _nochnykChasov,
      _sverkhurochnykhChasov,
      _prazdnichikhChasov,
      _otpuskDney,
      _bolnichnyhDney,
      _progulDney,
      _komandirovkaDney,
    ]) {
      c.addListener(_rebuildSummary);
    }
  }

  @override
  void dispose() {
    _periodMesyac.removeListener(_onPeriodChanged);
    _faktChasov.removeListener(_onFaktChasovChanged);
    for (final c in [
      _rabochihDney,
      _faktDney,
      _vechernikhChasov,
      _nochnykChasov,
      _sverkhurochnykhChasov,
      _prazdnichikhChasov,
      _otpuskDney,
      _bolnichnyhDney,
      _progulDney,
      _komandirovkaDney,
    ]) {
      c.removeListener(_rebuildSummary);
    }
    for (final c in [
      _normaChasov,
      _periodMesyac,
      _rabochihDney,
      _faktDney,
      _faktChasov,
      _vechernikhChasov,
      _nochnykChasov,
      _sverkhurochnykhChasov,
      _prazdnichikhChasov,
      _otpuskDney,
      _bolnichnyhDney,
      _progulDney,
      _komandirovkaDney,
      _sotrudnikFio,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Listeners ────────────────────────────────────────────────

  void _rebuildSummary() => setState(() {});

  void _onPeriodChanged() {
    if (_periodMesyac.text.trim().length >= 7) {
      _fillNormFromCalendar(_periodMesyac.text.trim());
    }
  }

  /// Фактические часы изменились → авто-расчёт сверхурочных
  void _onFaktChasovChanged() {
    setState(() {});

    final norma = _pd(_normaChasov.text);
    final fakt = _pd(_faktChasov.text);

    if (norma <= 0) return;

    final autoOvertime = (fakt - norma).clamp(0.0, double.infinity);
    final currentOvertime = _pd(_sverkhurochnykhChasov.text);

    // Подставляем авто только если поле сверхурочных ещё не тронуто (== 0)
    // или это первый авто-проход
    if (!_overtimeAutoSet || currentOvertime == 0.0) {
      _overtimeAutoSet = true;
      _sverkhurochnykhChasov.text = autoOvertime == 0
          ? '0'
          : _fmt(autoOvertime);
    }
  }

  // ── Норма из производственного календаря ────────────────────

  /// [silent] = true — заполняет только _normaChasov и _rabochihDney,
  /// не показывает метку «Подставлено из календаря» (используется при открытии)
  void _fillNormFromCalendar(String period, {bool silent = false}) {
    final parts = period.split('.');
    if (parts.length < 2) return;
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null || month < 1 || month > 12) return;

    final monthName = WorkCalendar.monthNames[month - 1];
    final hours = _calendar.getWorkHours(year, monthName, _weekType);
    final days = _calendar.getWorkDays(year, monthName, _weekType);
    if (hours <= 0) return;

    setState(() {
      _rabochihDney.text = days.round().toString();
      _normaChasov.text = hours.toStringAsFixed(1);
      _normAutoFilled = !silent;
      _overtimeAutoSet = false; // сброс при смене нормы
    });

    // После обновления нормы пересчитываем авто-сверхурочные
    _onFaktChasovChanged();
  }

  void _onWeekTypeChanged(String wt) {
    setState(() {
      _weekType = wt;
      _normAutoFilled = false;
      _overtimeAutoSet = false;
    });
    if (_periodMesyac.text.trim().length >= 7) {
      _fillNormFromCalendar(_periodMesyac.text.trim());
    }
  }

  // ── Выбор сотрудника ─────────────────────────────────────────

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
      });
    }
  }

  // ── Сохранение ───────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // _normaChasov НЕ сохраняется — берётся из WorkCalendar каждый раз
    final data = {
      'sotrudnikId': _sotrudnikId,
      'periodMesyac': _periodMesyac.text.trim(),
      'rabochihDney': int.tryParse(_rabochihDney.text.trim()) ?? 0,
      'faktDney': int.tryParse(_faktDney.text.trim()) ?? 0,
      'faktChasov': _pd(_faktChasov.text), // REAL
      'vechernikhChasov': _pd(_vechernikhChasov.text),
      'nochnykChasov': _pd(_nochnykChasov.text),
      'sverkhurochnykhChasov': _pd(_sverkhurochnykhChasov.text),
      'prazdnichikhChasov': _pd(_prazdnichikhChasov.text),
      'otpuskDney': int.tryParse(_otpuskDney.text.trim()) ?? 0,
      'bolnichnyhDney': int.tryParse(_bolnichnyhDney.text.trim()) ?? 0,
      'progulDney': int.tryParse(_progulDney.text.trim()) ?? 0,
      'komandirovkaDney': int.tryParse(_komandirovkaDney.text.trim()) ?? 0,
    };

    try {
      if (_isEdit) {
        await _db.update('tabel', data, widget.item!['id'] as int);
      } else {
        await _db.insert('tabel', data);
      }
      if (mounted) {
        showSnack(
          context,
          _isEdit ? 'Изменения сохранены' : 'Запись добавлена',
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted)
        showSnack(
          context,
          'Запись для этого сотрудника за данный период уже существует',
          isError: true,
        );
    }
    if (mounted) setState(() => _isSaving = false);
  }

  // ── Вспомогательные виджеты полей ───────────────────────────

  Widget _intField(TextEditingController ctrl, String label) => buildTextField(
    context: context,
    controller: ctrl,
    label: label,
    keyboardType: TextInputType.number,
  );

  Widget _doubleHoursField(
    TextEditingController ctrl,
    String label, {
    String? helperText,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: label,
        hintText: '0',
        helperText: helperText ?? 'Допускается дробное значение, например: 1.5',
        border: const OutlineInputBorder(),
        suffixText: 'ч',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        final n = double.tryParse(v.trim().replaceAll(',', '.'));
        if (n == null || n < 0) return 'Введите число ≥ 0';
        return null;
      },
    ),
  );

  // ── Сводка ───────────────────────────────────────────────────

  Widget _buildSummary() {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Дни
    final factD = int.tryParse(_faktDney.text) ?? 0;
    final otpusk = int.tryParse(_otpuskDney.text) ?? 0;
    final boln = int.tryParse(_bolnichnyhDney.text) ?? 0;
    final prog = int.tryParse(_progulDney.text) ?? 0;
    final komand = int.tryParse(_komandirovkaDney.text) ?? 0;
    final totalD = factD + otpusk + boln + prog + komand;
    final normaD = int.tryParse(_rabochihDney.text) ?? 0;
    final diffD = totalD - normaD;

    // Часы
    final normaCh = _pd(_normaChasov.text); // из WorkCalendar
    final faktCh = _pd(_faktChasov.text); // введено пользователем
    final diffCh = faktCh - normaCh;
    final vecher = _pd(_vechernikhChasov.text);
    final noch = _pd(_nochnykChasov.text);
    final sverk = _pd(_sverkhurochnykhChasov.text);
    final prazdnik = _pd(_prazdnichikhChasov.text);

    // Авто-сверхурочные (для подсказки об отклонении)
    final autoOvertime = normaCh > 0
        ? (faktCh - normaCh).clamp(0.0, double.infinity)
        : 0.0;
    final overtimeDiff = sverk - autoOvertime;

    Widget row(String label, String value, {Color? color}) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: text.bodySmall?.copyWith(color: scheme.outline),
            ),
          ),
          Text(
            value,
            style: text.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? scheme.onSurface,
            ),
          ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Сводка',
            style: text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // ── Дни ─────────────────────────────────────────────
          Text(
            'ДНИ',
            style: text.labelSmall?.copyWith(
              color: scheme.outline,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          row('Итого дней учёта:', '$totalD'),
          row('Норма дней:', '$normaD'),
          row(
            'Отклонение по дням:',
            diffD == 0 ? '0' : (diffD > 0 ? '+$diffD' : '$diffD'),
            color: diffD == 0
                ? null
                : diffD > 0
                ? scheme.primary
                : scheme.error,
          ),

          const Divider(height: 16),

          // ── Часы ─────────────────────────────────────────────
          Text(
            'ЧАСЫ',
            style: text.labelSmall?.copyWith(
              color: scheme.outline,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),

          if (normaCh > 0)
            row('Норма часов:', '${normaCh.toStringAsFixed(1)} ч'),

          row(
            'Фактически отработано:',
            faktCh > 0 ? '${faktCh.toStringAsFixed(1)} ч' : '—',
          ),

          if (faktCh > 0 && normaCh > 0)
            row(
              'Отклонение по часам:',
              diffCh == 0
                  ? '0 ч'
                  : '${diffCh > 0 ? '+' : ''}${diffCh.toStringAsFixed(1)} ч',
              color: diffCh == 0
                  ? null
                  : diffCh > 0
                  ? scheme.error
                  : scheme.primary,
            ),

          if (vecher > 0)
            row(
              'Вечерних часов:',
              '${vecher.toStringAsFixed(1)} ч',
              color: scheme.tertiary,
            ),
          if (noch > 0)
            row(
              'Ночных часов:',
              '${noch.toStringAsFixed(1)} ч',
              color: scheme.tertiary,
            ),
          if (prazdnik > 0)
            row(
              'Праздничных/выходных:',
              '${prazdnik.toStringAsFixed(1)} ч',
              color: scheme.primary,
            ),

          if (sverk > 0) ...[
            row(
              'Сверхурочных:',
              '${sverk.toStringAsFixed(1)} ч',
              color: scheme.error,
            ),
            // Подсказка если ручной ввод отличается от авто
            if (normaCh > 0 && overtimeDiff.abs() > 0.05)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 12, color: scheme.outline),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Авто-расчёт: ${autoOvertime.toStringAsFixed(1)} ч'
                        ' (скорректировано вручную)',
                        style: text.labelSmall?.copyWith(color: scheme.outline),
                      ),
                    ),
                  ],
                ),
              ),
          ],

          // Обычные часы = факт − (вечерние + ночные + сверхурочные + праздничные)
          /*if (faktCh > 0 && (vecher + noch + sverk + prazdnik) > 0) ...[
            const Divider(height: 12),
            row(
              'Обычных часов:',
              '${(faktCh - vecher - noch - sverk - prazdnik).clamp(0.0, double.infinity).toStringAsFixed(1)} ч',
            ),
          ],*/
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Показываем баннер если факт > нормы
    final normaCh = _pd(_normaChasov.text);
    final faktCh = _pd(_faktChasov.text);
    final diffCh = faktCh - normaCh;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: Text(_isEdit ? 'Редактировать табель' : 'Новая запись табеля'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Производственный календарь',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkCalendarPage()),
              );
              if (_periodMesyac.text.trim().length >= 7) {
                _fillNormFromCalendar(_periodMesyac.text.trim());
              }
            },
          ),
        ],
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
            // ── Сотрудник ─────────────────────────────────────
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

            // ── Период ────────────────────────────────────────
            buildSectionHeader(context, 'Период'),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _periodMesyac,
                inputFormatters: [_periodMask],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Период (ММ.ГГГГ)',
                  hintText: 'ММГГГГ',
                  helperText: 'Вводите только цифры, например: 032026',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Обязательное поле';
                  final p = v.trim().split('.');
                  if (p.length != 2) return 'Формат: ММ.ГГГГ';
                  final m = int.tryParse(p[0]) ?? 0;
                  final y = int.tryParse(p[1]) ?? 0;
                  if (m < 1 || m > 12) return 'Месяц от 01 до 12';
                  if (y < 2000 || y > 2100) return 'Год от 2000 до 2100';
                  return null;
                },
              ),
            ),

            // ── Норма рабочей недели ──────────────────────────
            buildSectionHeader(context, 'Норма рабочей недели'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '40', label: Text('40 ч/нед')),
                ButtonSegment(value: '36', label: Text('36 ч/нед')),
                ButtonSegment(value: '24', label: Text('24 ч/нед')),
              ],
              selected: {_weekType},
              onSelectionChanged: (s) => _onWeekTypeChanged(s.first),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.auto_fix_high_outlined, size: 16),
                  label: const Text('Применить норму'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    final p = _periodMesyac.text.trim();
                    if (p.length < 7) {
                      showSnack(
                        context,
                        'Сначала введите период',
                        isError: true,
                      );
                      return;
                    }
                    _fillNormFromCalendar(p);
                  },
                ),
              ],
            ),

            // ── Норма (только отображение из WorkCalendar) ────
            buildSectionHeader(context, 'Рабочее время по норме'),
            if (_normAutoFilled)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Подставлено из производственного календаря',
                      style: text.labelSmall?.copyWith(color: scheme.primary),
                    ),
                  ],
                ),
              ),
            _intField(_rabochihDney, 'Рабочих дней по норме'),
            // _normaChasov — readOnly, значение из WorkCalendar
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _normaChasov,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Рабочих часов по норме',
                  border: const OutlineInputBorder(),
                  suffixText: 'ч',
                  helperText:
                      'Рассчитывается автоматически из '
                      'производственного календаря',
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest,
                ),
              ),
            ),

            // ── Фактически отработано ─────────────────────────
            buildSectionHeader(context, 'Фактически отработано'),
            _intField(_faktDney, 'Отработано дней'),

            // faktChasov — вводит пользователь, REAL, сохраняется в БД
            _doubleHoursField(
              _faktChasov,
              'Отработано часов',
              helperText:
                  'Фактически отработанные часы. '
                  'При превышении нормы — разница подставляется '
                  'в сверхурочные автоматически.',
            ),

            // ── Баннер сверхурочных ───────────────────────────
            if (normaCh > 0 && diffCh > 0.05)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 14,
                        color: scheme.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Превышение нормы на ${diffCh.toStringAsFixed(1)} ч — '
                          'подставлено в сверхурочные.',
                          style: text.labelSmall?.copyWith(color: scheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Учёт часов по видам ───────────────────────────
            buildSectionHeader(context, 'Учёт часов по видам'),
            _doubleHoursField(
              _vechernikhChasov,
              'Часы в вечернее время (18:00–22:00)',
            ),
            _doubleHoursField(
              _nochnykChasov,
              'Часы в ночное время (22:00–06:00)',
            ),
            _doubleHoursField(_sverkhurochnykhChasov, 'Сверхурочные часы'),
            _doubleHoursField(
              _prazdnichikhChasov,
              'Часы в праздничные и выходные дни',
            ),

            // ── Отсутствия ────────────────────────────────────
            buildSectionHeader(context, 'Отсутствия'),
            _intField(_otpuskDney, 'Дней в отпуске'),
            _intField(_bolnichnyhDney, 'Дней на больничном'),
            _intField(_progulDney, 'Прогулы (дней)'),
            _intField(_komandirovkaDney, 'Командировка (дней)'),

            // ── Сводка ────────────────────────────────────────
            _buildSummary(),
          ],
        ),
      ),
    );
  }
}
