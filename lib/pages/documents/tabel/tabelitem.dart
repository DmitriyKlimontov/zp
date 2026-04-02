import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikiitemgetfromlist.dart';
import 'package:zp/services/work_calendar.dart';
import 'package:zp/pages/settings/work_calendar_page.dart';

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

  late final TextEditingController _periodMesyac;
  late final TextEditingController _rabochihDney;
  late final TextEditingController _faktDney;
  late final TextEditingController _faktChasov;
  late final TextEditingController _otpuskDney;
  late final TextEditingController _bolnichnyhDney;
  late final TextEditingController _progulDney;
  late final TextEditingController _komandirovkaDney;
  late final TextEditingController _sotrudnikFio;

  int _sotrudnikId = 0;
  String _weekType = '40'; // '40' | '36' | '24'
  bool _normAutoFilled = false;

  bool get _isEdit => widget.item != null;

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
    _faktChasov = TextEditingController(
      text: d?['faktChasov']?.toString() ?? '0',
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

    _periodMesyac.addListener(_onPeriodChanged);
  }

  @override
  void dispose() {
    _periodMesyac.removeListener(_onPeriodChanged);
    for (final c in [
      _periodMesyac,
      _rabochihDney,
      _faktDney,
      _faktChasov,
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

  // ── Автоподстановка нормы из производственного календаря ─────

  void _onPeriodChanged() {
    final period = _periodMesyac.text.trim();
    // Ждём полного «ММ.ГГГГ» = 7 символов минимум
    if (period.length >= 7) _fillNormFromCalendar(period);
  }

  void _fillNormFromCalendar(String period) {
    final parts = period.split('.');
    if (parts.length < 2) return;
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || year == null || month < 1 || month > 12) return;

    final monthName = WorkCalendar.monthNames[month - 1];
    final hours = _calendar.getWorkHours(year, monthName, _weekType);
    final days = _calendar.getWorkDays(year, monthName, _weekType);

    if (hours <= 0) return; // год не найден в календаре

    setState(() {
      _rabochihDney.text = days.round().toString();
      _faktChasov.text = hours.toStringAsFixed(1);
      _normAutoFilled = true;
    });
  }

  void _onWeekTypeChanged(String wt) {
    setState(() {
      _weekType = wt;
      _normAutoFilled = false;
    });
    final period = _periodMesyac.text.trim();
    if (period.length >= 7) _fillNormFromCalendar(period);
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

  // ── Сохранение ────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // faktChasov в БД хранится как INTEGER, поэтому округляем
    final faktChasovVal = double.tryParse(_faktChasov.text.trim()) ?? 0.0;

    final data = {
      'sotrudnikId': _sotrudnikId,
      'periodMesyac': _periodMesyac.text.trim(),
      'rabochihDney': int.tryParse(_rabochihDney.text.trim()) ?? 0,
      'faktDney': int.tryParse(_faktDney.text.trim()) ?? 0,
      'faktChasov': faktChasovVal.round(),
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

  Widget _intField(TextEditingController ctrl, String label) => buildTextField(
    context: context,
    controller: ctrl,
    label: label,
    keyboardType: TextInputType.number,
  );

  // ── Сводка ────────────────────────────────────────────────────

  Widget _buildSummary() {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final fact = int.tryParse(_faktDney.text) ?? 0;
    final otpusk = int.tryParse(_otpuskDney.text) ?? 0;
    final boln = int.tryParse(_bolnichnyhDney.text) ?? 0;
    final prog = int.tryParse(_progulDney.text) ?? 0;
    final komand = int.tryParse(_komandirovkaDney.text) ?? 0;
    final total = fact + otpusk + boln + prog + komand;
    final norma = int.tryParse(_rabochihDney.text) ?? 0;
    final diff = total - norma;

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
          _row(context, 'Итого дней учёта:', '$total'),
          _row(context, 'Норма дней:', '$norma'),
          _row(
            context,
            'Отклонение:',
            diff == 0 ? '0' : (diff > 0 ? '+$diff' : '$diff'),
            color: diff == 0
                ? null
                : diff > 0
                ? scheme.primary
                : scheme.error,
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
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
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

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
              // После редактирования — обновляем норму
              final period = _periodMesyac.text.trim();
              if (period.length >= 7) _fillNormFromCalendar(period);
            },
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
            // ── Сотрудник ───────────────────────────────────────
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

            // ── Период ──────────────────────────────────────────
            buildSectionHeader(context, 'Период'),
            buildTextField(
              context: context,
              controller: _periodMesyac,
              label: 'Период (ММ.ГГГГ)',
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Обязательное поле' : null,
            ),

            // ── Тип рабочей недели ──────────────────────────────
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
                    final period = _periodMesyac.text.trim();
                    if (period.length < 7) {
                      showSnack(
                        context,
                        'Сначала введите период (ММ.ГГГГ)',
                        isError: true,
                      );
                      return;
                    }
                    _fillNormFromCalendar(period);
                  },
                ),
              ],
            ),

            // ── Норма ───────────────────────────────────────────
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
            buildTextField(
              context: context,
              controller: _faktChasov,
              label: 'Рабочих часов по норме',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            // ── Фактически ──────────────────────────────────────
            buildSectionHeader(context, 'Фактически отработано'),
            _intField(_faktDney, 'Отработано дней'),

            // ── Отсутствия ───────────────────────────────────────
            buildSectionHeader(context, 'Отсутствия'),
            _intField(_otpuskDney, 'Дней в отпуске'),
            _intField(_bolnichnyhDney, 'Дней на больничном'),
            _intField(_progulDney, 'Прогулы (дней)'),
            _intField(_komandirovkaDney, 'Командировка (дней)'),

            // ── Сводка ───────────────────────────────────────────
            _buildSummary(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
