// lib/pages/settings/work_calendar_page.dart
//
// Страница редактирования производственного календаря.
// Открывается из Настроек или из TabeItem.
// Пользователь может изменить нормы часов для любого месяца/года.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zp/services/work_calendar.dart';

class WorkCalendarPage extends StatefulWidget {
  const WorkCalendarPage({super.key});

  @override
  State<WorkCalendarPage> createState() => _WorkCalendarPageState();
}

class _WorkCalendarPageState extends State<WorkCalendarPage>
    with SingleTickerProviderStateMixin {
  final _calendar = WorkCalendar.instance;

  // Контроллеры: [year][monthIndex][weekTypeIndex]
  // weekTypes: 0='40', 1='36', 2='24'
  late Map<int, List<List<TextEditingController>>> _controllers;

  late TabController _tabController;
  bool _isSaving = false;
  bool _isDirty = false; // есть несохранённые изменения

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _calendar.years.length, vsync: this);
    _buildControllers();
  }

  void _buildControllers() {
    _controllers = {};
    for (final year in _calendar.years) {
      final monthCtrls = <List<TextEditingController>>[];
      for (final month in WorkCalendar.monthNames) {
        final wtCtrls = WorkCalendar.weekTypes.map((wt) {
          final val = _calendar.getWorkHours(year, month, wt);
          final ctrl = TextEditingController(text: _formatHours(val));
          ctrl.addListener(() => setState(() => _isDirty = true));
          return ctrl;
        }).toList();
        monthCtrls.add(wtCtrls);
      }
      _controllers[year] = monthCtrls;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final yearCtrls in _controllers.values) {
      for (final monthCtrls in yearCtrls) {
        for (final c in monthCtrls) c.dispose();
      }
    }
    super.dispose();
  }

  String _formatHours(double v) =>
      v == v.floorToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _save() async {
    // Применяем значения из контроллеров в WorkCalendar
    for (final year in _calendar.years) {
      for (int mi = 0; mi < WorkCalendar.monthNames.length; mi++) {
        final month = WorkCalendar.monthNames[mi];
        for (int wi = 0; wi < WorkCalendar.weekTypes.length; wi++) {
          final wt = WorkCalendar.weekTypes[wi];
          final val = double.tryParse(
            _controllers[year]![mi][wi].text.trim().replaceAll(',', '.'),
          );
          if (val != null && val >= 0) {
            _calendar.yearlyWorkHours[year] ??= {};
            _calendar.yearlyWorkHours[year]![month] ??= {};
            _calendar.yearlyWorkHours[year]![month]![wt] = val;
          }
        }
      }
    }

    setState(() => _isSaving = true);
    await _calendar.save();
    setState(() {
      _isSaving = false;
      _isDirty = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Производственный календарь сохранён'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _resetToDefaults() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сбросить к значениям по умолчанию?'),
        content: const Text(
          'Все ваши изменения будут удалены и заменены '
          'стандартными нормами.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await _calendar.resetToDefaults();
    // Пересобираем контроллеры с новыми значениями
    for (final yearCtrls in _controllers.values) {
      for (final monthCtrls in yearCtrls) {
        for (final c in monthCtrls) c.dispose();
      }
    }
    setState(() {
      _buildControllers();
      _isDirty = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные сброшены к значениям по умолчанию'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final years = _calendar.years;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: const Text('Производственный календарь'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_outlined),
            tooltip: 'Сбросить к умолчаниям',
            onPressed: _resetToDefaults,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: (!_isDirty || _isSaving) ? null : _save,
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
        bottom: TabBar(
          controller: _tabController,
          tabs: years.map((y) => Tab(text: '$y')).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: years.map((year) => _buildYearTab(context, year)).toList(),
      ),
    );
  }

  Widget _buildYearTab(BuildContext context, int year) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final yearIdx = _calendar.years.indexOf(year);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок таблицы
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    'Месяц',
                    style: text.labelSmall?.copyWith(
                      color: scheme.outline,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                ...WorkCalendar.weekTypes.map(
                  (wt) => Expanded(
                    child: Text(
                      '$wt ч/нед',
                      textAlign: TextAlign.center,
                      style: text.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 8),

          // Строки месяцев
          ...List.generate(WorkCalendar.monthNames.length, (mi) {
            final month = WorkCalendar.monthNames[mi];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  // Название месяца
                  SizedBox(
                    width: 90,
                    child: Text(month, style: text.bodyMedium),
                  ),
                  // Три поля: 40 / 36 / 24
                  ...List.generate(WorkCalendar.weekTypes.length, (wi) {
                    final ctrl = _controllers[year]![mi][wi];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextFormField(
                          controller: ctrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          textAlign: TextAlign.center,
                          style: text.bodySmall,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          // Подсказка
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 14, color: scheme.outline),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Нормы часов по производственному календарю РФ. '
                  'Значения можно изменить если организация работает '
                  'по отличному от стандартного графику.',
                  style: text.bodySmall?.copyWith(color: scheme.outline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
