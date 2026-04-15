import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/settings.dart';

// Справочники
import 'package:zp/pages/spravochniki/organizacii/organizaciilist.dart';
import 'package:zp/pages/spravochniki/podrazdelenia/podrazdelenialist.dart';
import 'package:zp/pages/spravochniki/dolznosti/dolznostilist.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikilist.dart';
import 'package:zp/pages/spravochniki/nalogovievicheti/nalogovievichetilist.dart';
import 'package:zp/pages/spravochniki/uslTruda/uslTrudalist.dart';

// Журналы документов
import 'package:zp/pages/documents/avans/avansjornal.dart';
import 'package:zp/pages/documents/otpusk/otpuskjornal.dart';
import 'package:zp/pages/documents/tabel/tabeljornal.dart';
import 'package:zp/pages/documents/platvedomost/platvedomostjornal.dart';
import 'package:zp/pages/documents/raschetlistok/raschetlistokjornal.dart';

// ─────────────────────────────────────────────────────────────
// Модель пункта журнала для body
// ─────────────────────────────────────────────────────────────

class _JornalEntry {
  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  const _JornalEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });
}

final _jornalEntries = <_JornalEntry>[
  _JornalEntry(
    icon: Icons.payments_outlined,
    title: 'Авансы',
    subtitle: 'Журнал авансовых выплат',
    builder: (_) => const AvansJornal(),
  ),
  _JornalEntry(
    icon: Icons.beach_access_outlined,
    title: 'Отпуска',
    subtitle: 'Журнал отпусков',
    builder: (_) => const OtpuskJornal(),
  ),
  _JornalEntry(
    icon: Icons.access_time_outlined,
    title: 'Табель',
    subtitle: 'Учёт рабочего времени',
    builder: (_) => const TabelJornal(),
  ),
  _JornalEntry(
    icon: Icons.receipt_long_outlined,
    title: 'Платёжные ведомости',
    subtitle: 'Журнал платёжных ведомостей',
    builder: (_) => const PlatvedomostJornal(),
  ),
  _JornalEntry(
    icon: Icons.description_outlined,
    title: 'Расчётные листки',
    subtitle: 'Журнал расчётных листков',
    builder: (_) => const RaschetlistokJornal(),
  ),
];

// ─────────────────────────────────────────────────────────────
// Модель пункта справочника для Drawer
// ─────────────────────────────────────────────────────────────

class _SpravEntry {
  final IconData icon;
  final String title;
  final WidgetBuilder builder;
  const _SpravEntry(this.icon, this.title, this.builder);
}

final _spravEntries = <_SpravEntry>[
  _SpravEntry(
    Icons.business_outlined,
    'Организации',
    (_) => const OrganizaciiList(),
  ),
  _SpravEntry(
    Icons.account_tree_outlined,
    'Подразделения',
    (_) => const PodrazdeleniaList(),
  ),
  _SpravEntry(Icons.work_outline, 'Должности', (_) => const DolznostiList()),
  _SpravEntry(
    Icons.people_outline,
    'Сотрудники',
    (_) => const SotrudnikiList(),
  ),
  _SpravEntry(
    Icons.receipt_outlined,
    'Налоговые вычеты',
    (_) => const NalogovievichetiList(),
  ),
  _SpravEntry(
    Icons.tune_outlined,
    'Условия труда',
    (_) => const UslTrudaList(),
  ),
];

// ─────────────────────────────────────────────────────────────
// Доиашняя страница
// ─────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _prefs = AppPrefsService.instance;

  // ── Настройки ──────────────────────────────────────────────

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    setState(() {});
  }

  // ── Переход в журнал ────────────────────────────────────────

  void _openJornal(_JornalEntry entry) {
    Navigator.push(context, MaterialPageRoute(builder: entry.builder));
  }

  // ── Drawer ──────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Шапка
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(
                      Icons.calculate_outlined,
                      color: scheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: text.titleMedium),
                      Text(
                        'Расчёт зарплаты',
                        style: text.bodySmall?.copyWith(color: scheme.outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── Справочники (раскрывающийся список) ───────
                  ExpansionTile(
                    leading: Icon(
                      Icons.menu_book_outlined,
                      color: scheme.primary,
                    ),
                    title: Text(
                      'Справочники',
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    initiallyExpanded: false,
                    childrenPadding: EdgeInsets.zero,
                    children: _spravEntries
                        .map(
                          (e) => ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 56,
                              right: 16,
                            ),
                            leading: Icon(
                              e.icon,
                              size: 20,
                              color: scheme.onSurfaceVariant,
                            ),
                            title: Text(e.title, style: text.bodyMedium),
                            visualDensity: VisualDensity.compact,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: e.builder),
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),

                  // ── Журналы документов (раскрывающийся список) ─
                  ExpansionTile(
                    leading: Icon(
                      Icons.folder_copy_outlined,
                      color: scheme.primary,
                    ),
                    title: Text(
                      'Журналы документов',
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    initiallyExpanded: false,
                    childrenPadding: EdgeInsets.zero,
                    children: _jornalEntries
                        .map(
                          (e) => ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 56,
                              right: 16,
                            ),
                            leading: Icon(
                              e.icon,
                              size: 20,
                              color: scheme.onSurfaceVariant,
                            ),
                            title: Text(e.title, style: text.bodyMedium),
                            visualDensity: VisualDensity.compact,
                            onTap: () {
                              Navigator.pop(context);
                              _openJornal(e);
                            },
                          ),
                        )
                        .toList(),
                  ),

                  const Divider(height: 1),

                  // ── Настройки ──────────────────────────────────
                  ListTile(
                    leading: Icon(
                      Icons.settings_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                    title: Text('Настройки', style: text.bodyMedium),
                    onTap: () {
                      Navigator.pop(context);
                      _openSettings();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body —

  Widget _buildBody(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _jornalEntries.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, indent: 72, color: scheme.outlineVariant),
      itemBuilder: (_, i) {
        final entry = _jornalEntries[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: scheme.secondaryContainer,
            child: Icon(
              entry.icon,
              color: scheme.onSecondaryContainer,
              size: 22,
            ),
          ),
          title: Text(
            entry.title,
            style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            entry.subtitle,
            style: text.bodySmall?.copyWith(color: scheme.outline),
          ),
          trailing: Icon(Icons.chevron_right, color: scheme.outline, size: 20),
          onTap: () => _openJornal(entry),
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Настройки',
            onPressed: _openSettings,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Builder(
        builder: (ctx) => Stack(
          children: [
            _buildBody(ctx),
            Positioned(
              right: 16,
              bottom: 24,
              child: FloatingActionButton(
                heroTag: 'fab_main',
                tooltip: 'Открыть меню',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                child: const Icon(Icons.edit_document),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
