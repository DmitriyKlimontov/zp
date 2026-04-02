import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  Ключи настроек
// ─────────────────────────────────────────────────────────────
class AppPrefsKeys {
  AppPrefsKeys._();
  static const String docListReversed = 'doc_list_reversed';
}

// ─────────────────────────────────────────────────────────────
//  Сервис настроек — загрузка и сохранение
// ─────────────────────────────────────────────────────────────
class AppPrefsService {
  AppPrefsService._();
  static final AppPrefsService instance = AppPrefsService._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // false = сверху вниз, true = снизу вверх (как в мессенджере)
  bool get docListReversed =>
      _prefs.getBool(AppPrefsKeys.docListReversed) ?? false;

  Future<void> setDocListReversed(bool value) =>
      _prefs.setBool(AppPrefsKeys.docListReversed, value);
}

// ─────────────────────────────────────────────────────────────
//  SettingsPage
// ─────────────────────────────────────────────────────────────
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _prefs = AppPrefsService.instance;

  late bool _docListReversed;

  @override
  void initState() {
    super.initState();
    _docListReversed = _prefs.docListReversed;
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // ── Раздел: Список документов ────────────────────────
          _sectionHeader(context, 'Список документов'),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            elevation: 0,
            color: scheme.surfaceContainerLow,
            child: SwitchListTile(
              secondary: Icon(
                _docListReversed
                    ? Icons.vertical_align_bottom
                    : Icons.vertical_align_top,
              ),
              title: const Text('Новые документы сверху'),
              subtitle: Text(
                _docListReversed
                    ? 'Последние документы отображаются вверху списка, как в мессенджерах'
                    : 'Последние документы отображаются внизу списка',
              ),
              value: _docListReversed,
              onChanged: (val) async {
                await _prefs.setDocListReversed(val);
                setState(() => _docListReversed = val);
              },
            ),
          ),

          // Превью порядка списка
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildOrderPreview(context, _docListReversed),
          ),

          // ── Раздел: О приложении ─────────────────────────────
          _sectionHeader(context, 'О приложении'),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            elevation: 0,
            color: scheme.surfaceContainerLow,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Версия'),
                  trailing: Text(
                    '1.0.0',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: scheme.outline),
                  ),
                ),
                Divider(height: 1, indent: 56, color: scheme.outlineVariant),
                ListTile(
                  leading: const Icon(Icons.storage_outlined),
                  title: const Text('База данных'),
                  trailing: Text(
                    'database.dart',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: scheme.outline),
                  ),
                ),
                ListTile(
                  title: Center(
                    child: Text(
                      'Дипломный проект Кдимонтова Д. С. студента ИСП-31 "Мобильное приложение по расчету заработной платы в коммерческих организациях" ',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOrderPreview(BuildContext context, bool reversed) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final items = [
      (Icons.receipt_long_outlined, 'Ведомость · Март 2026', 'новее'),
      (Icons.payments_outlined, 'Аванс · Март 2026', ''),
      (Icons.description_outlined, 'Листок · Февраль 2026', 'старее'),
    ];

    final displayItems = reversed ? items.reversed.toList() : items;

    return Padding(
      key: ValueKey(reversed),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Card(
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.preview_outlined, size: 14, color: scheme.outline),
                  const SizedBox(width: 6),
                  Text(
                    'Превью порядка',
                    style: text.labelSmall?.copyWith(color: scheme.outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...displayItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(item.$1, size: 16, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item.$2, style: text.bodySmall)),
                      if (item.$3.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.$3 == 'новее'
                                ? scheme.primaryContainer
                                : scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.$3,
                            style: text.labelSmall?.copyWith(
                              color: item.$3 == 'новее'
                                  ? scheme.onPrimaryContainer
                                  : scheme.outline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
