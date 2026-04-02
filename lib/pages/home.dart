import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/settings.dart';
// справочники
import 'package:zp/pages/spravochniki/dolznosti/dolznostilist.dart';
import 'package:zp/pages/spravochniki/organizacii/organizaciilist.dart';
import 'package:zp/pages/spravochniki/nalogovievicheti/nalogovievichetilist.dart';
import 'package:zp/pages/spravochniki/podrazdelenia/podrazdelenialist.dart';
import 'package:zp/pages/spravochniki/sotrudniki/sotrudnikilist.dart';
import 'package:zp/pages/spravochniki/uslTruda/uslTrudalist.dart';
// журналы
import 'package:zp/pages/documents/avans/avansjornal.dart';
import 'package:zp/pages/documents/otpusk/otpuskjornal.dart';
import 'package:zp/pages/documents/platvedomost/platvedomostjornal.dart';
import 'package:zp/pages/documents/raschetlistok/raschetlistokjornal.dart';
import 'package:zp/pages/documents/tabel/tabeljornal.dart';
// документы (item)
import 'package:zp/pages/documents/avans/avansitem.dart';
import 'package:zp/pages/documents/otpusk/otpuskitem.dart';
import 'package:zp/pages/documents/platvedomost/platvedomostitem.dart';
import 'package:zp/pages/documents/raschetlistok/raschetlistokitem.dart';
import 'package:zp/pages/documents/tabel/tabelitem.dart';

// ─────────────────────────────────────────────
// Типы документов
// ─────────────────────────────────────────────

enum DocType { nachislenie, uderzhanie, avans, otpusk, vedomost, listok }

extension DocTypeExt on DocType {
  String get label {
    switch (this) {
      case DocType.nachislenie:
        return 'Начисление';
      case DocType.uderzhanie:
        return 'Удержание';
      case DocType.avans:
        return 'Аванс';
      case DocType.otpusk:
        return 'Отпуск';
      case DocType.vedomost:
        return 'Платёжная ведомость';
      case DocType.listok:
        return 'Расчётный листок';
    }
  }

  IconData get icon {
    switch (this) {
      case DocType.nachislenie:
        return Icons.add_chart;
      case DocType.uderzhanie:
        return Icons.remove_circle_outline;
      case DocType.avans:
        return Icons.payments_outlined;
      case DocType.otpusk:
        return Icons.beach_access_outlined;
      case DocType.vedomost:
        return Icons.receipt_long_outlined;
      case DocType.listok:
        return Icons.description_outlined;
    }
  }
}

// ─────────────────────────────────────────────
// Модель одного документа в списке
// ─────────────────────────────────────────────

class DocumentItem {
  final int id;
  final DocType type;
  final String title;
  final String subtitle;
  final String sortKey;
  final String periodLabel;
  final String amount;
  final bool isNew;

  const DocumentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.sortKey,
    required this.periodLabel,
    required this.amount,
    this.isNew = false,
  });
}

// ─────────────────────────────────────────────
// Вспомогательные функции
// ─────────────────────────────────────────────

String _formatAmount(dynamic value) {
  if (value == null) return '0 ₽';
  final n = (value as num).toDouble();
  final s = n.toStringAsFixed(0);
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('\u00A0');
    buf.write(s[i]);
  }
  return '${buf.toString()} ₽';
}

String _toSortKey(String periodMesyac) {
  if (periodMesyac.length < 7) return periodMesyac;
  final parts = periodMesyac.split('.');
  if (parts.length < 2) return periodMesyac;
  return '${parts[1]}${parts[0].padLeft(2, '0')}';
}

String _periodLabel(String periodMesyac) {
  if (periodMesyac.length < 7) return periodMesyac;
  final parts = periodMesyac.split('.');
  if (parts.length < 2) return periodMesyac;
  final month = int.tryParse(parts[0]) ?? 0;
  if (month < 1 || month > 12) return periodMesyac;
  const months = [
    '',
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];
  return '${months[month]} ${parts[1]}';
}

String _dateToSortKey(String ddMMYYYY) {
  if (ddMMYYYY.length < 7) return '';
  final parts = ddMMYYYY.split('.');
  if (parts.length < 3) return '';
  return '${parts[2]}${parts[1].padLeft(2, '0')}';
}

String _dateToLabel(String ddMMYYYY) {
  if (ddMMYYYY.length < 7) return ddMMYYYY;
  final parts = ddMMYYYY.split('.');
  if (parts.length < 3) return ddMMYYYY;
  return _periodLabel('${parts[1]}.${parts[2]}');
}

// ─────────────────────────────────────────────
// Загрузка документов из БД
// ─────────────────────────────────────────────

Future<List<DocumentItem>> _loadDocumentsFromDb() async {
  final db = await DatabaseHelper().database;
  final result = <DocumentItem>[];

  final nachisleniya = await db.rawQuery('''
    SELECT n.id, n.periodMesyac, n.itogoNachisleno,
           s.familiya || ' ' || s.name || ' ' || s.otchestvo AS fio
    FROM nachisleniya n LEFT JOIN sotrudniki s ON s.id = n.sotrudnikId
  ''');
  for (final r in nachisleniya) {
    final pm = r['periodMesyac']?.toString() ?? '';
    result.add(
      DocumentItem(
        id: r['id'] as int,
        type: DocType.nachislenie,
        title: 'Начисление',
        subtitle: r['fio']?.toString() ?? '—',
        sortKey: _toSortKey(pm),
        periodLabel: _periodLabel(pm),
        amount: _formatAmount(r['itogoNachisleno']),
      ),
    );
  }

  final uderzhaniya = await db.rawQuery('''
    SELECT u.id, u.periodMesyac, u.itogoUderzhano,
           s.familiya || ' ' || s.name || ' ' || s.otchestvo AS fio
    FROM uderzhaniya u LEFT JOIN sotrudniki s ON s.id = u.sotrudnikId
  ''');
  for (final r in uderzhaniya) {
    final pm = r['periodMesyac']?.toString() ?? '';
    result.add(
      DocumentItem(
        id: r['id'] as int,
        type: DocType.uderzhanie,
        title: 'Удержание',
        subtitle: r['fio']?.toString() ?? '—',
        sortKey: _toSortKey(pm),
        periodLabel: _periodLabel(pm),
        amount: _formatAmount(r['itogoUderzhano']),
      ),
    );
  }

  final avansy = await db.rawQuery('''
    SELECT a.id, a.periodMesyac, a.summaAvansa,
           s.familiya || ' ' || s.name || ' ' || s.otchestvo AS fio
    FROM avans a LEFT JOIN sotrudniki s ON s.id = a.sotrudnikId
  ''');
  for (final r in avansy) {
    final pm = r['periodMesyac']?.toString() ?? '';
    result.add(
      DocumentItem(
        id: r['id'] as int,
        type: DocType.avans,
        title: 'Аванс',
        subtitle: r['fio']?.toString() ?? '—',
        sortKey: _toSortKey(pm),
        periodLabel: _periodLabel(pm),
        amount: _formatAmount(r['summaAvansa']),
      ),
    );
  }

  final otpuska = await db.rawQuery('''
    SELECT o.id, o.dateNachala, o.kolichestvoDney, o.summaOtpusknyh,
           s.familiya || ' ' || s.name || ' ' || s.otchestvo AS fio
    FROM otpusk o LEFT JOIN sotrudniki s ON s.id = o.sotrudnikId
  ''');
  for (final r in otpuska) {
    final d = r['dateNachala']?.toString() ?? '';
    result.add(
      DocumentItem(
        id: r['id'] as int,
        type: DocType.otpusk,
        title: 'Отпуск',
        subtitle: '${r['fio'] ?? '—'} · ${r['kolichestvoDney']} дн.',
        sortKey: _dateToSortKey(d),
        periodLabel: _dateToLabel(d),
        amount: _formatAmount(r['summaOtpusknyh']),
      ),
    );
  }

  final vedomosti = await db.rawQuery('''
    SELECT pv.id, pv.periodMesyac, pv.itogoPoPerechen,
           pd.nazvanie AS podrazdelenie
    FROM platezhVedomost pv
    LEFT JOIN podrazdeleniya pd ON pd.id = pv.podrazdelenieId
  ''');
  for (final r in vedomosti) {
    final pm = r['periodMesyac']?.toString() ?? '';
    result.add(
      DocumentItem(
        id: r['id'] as int,
        type: DocType.vedomost,
        title: 'Платёжная ведомость',
        subtitle: r['podrazdelenie']?.toString() ?? '—',
        sortKey: _toSortKey(pm),
        periodLabel: _periodLabel(pm),
        amount: _formatAmount(r['itogoPoPerechen']),
      ),
    );
  }

  final listki = await db.rawQuery('''
    SELECT id, god, mesyac, periodLabel, itogoNachisleno,
           vydanSotrudniku, sotrudnikFio FROM raschetnyListok
  ''');
  for (final r in listki) {
    final god = r['god'] as int? ?? 0;
    final mesyac = r['mesyac'] as int? ?? 0;
    final pm = '${mesyac.toString().padLeft(2, '0')}.$god';
    result.add(
      DocumentItem(
        id: r['id'] as int,
        type: DocType.listok,
        title: 'Расчётный листок',
        subtitle: r['sotrudnikFio']?.toString() ?? '—',
        sortKey: _toSortKey(pm),
        periodLabel: r['periodLabel']?.toString().isNotEmpty == true
            ? r['periodLabel'].toString()
            : _periodLabel(pm),
        amount: _formatAmount(r['itogoNachisleno']),
        isNew: (r['vydanSotrudniku'] as int? ?? 0) == 0,
      ),
    );
  }

  return result;
}

// ─────────────────────────────────────────────
// Группировка
// ─────────────────────────────────────────────

List<MapEntry<String, List<DocumentItem>>> _buildGroups(
  List<DocumentItem> docs,
  bool reversed,
) {
  final keyToLabel = <String, String>{};
  for (final d in docs) {
    keyToLabel[d.sortKey] = d.periodLabel;
  }
  final sortedKeys = keyToLabel.keys.toList()
    ..sort((a, b) => reversed ? b.compareTo(a) : a.compareTo(b));
  return sortedKeys.map((key) {
    final groupDocs = docs.where((d) => d.sortKey == key).toList()
      ..sort((a, b) => reversed ? b.id.compareTo(a.id) : a.id.compareTo(b.id));
    return MapEntry(keyToLabel[key]!, groupDocs);
  }).toList();
}

// ─────────────────────────────────────────────
// Конфигурация журналов — один источник правды
// ─────────────────────────────────────────────

class _JornalConfig {
  final String label;
  final IconData icon;
  final Widget jornal; // страница журнала
  final Widget newItem; // страница нового документа
  const _JornalConfig({
    required this.label,
    required this.icon,
    required this.jornal,
    required this.newItem,
  });
}

const List<_JornalConfig> _jornals = [
  _JornalConfig(
    label: 'Аванс',
    icon: Icons.payments_outlined,
    jornal: AvansJornal(),
    newItem: AvansItem(),
  ),
  _JornalConfig(
    label: 'Отпуск',
    icon: Icons.beach_access_outlined,
    jornal: OtpuskJornal(),
    newItem: OtpuskItem(),
  ),
  _JornalConfig(
    label: 'Табель',
    icon: Icons.access_time_outlined,
    jornal: TabelJornal(),
    newItem: TabelItem(),
  ),
  _JornalConfig(
    label: 'Платёжная ведомость',
    icon: Icons.receipt_long_outlined,
    jornal: PlatvedomostJornal(),
    newItem: PlatvedomostItem(),
  ),
  _JornalConfig(
    label: 'Расчётный листок',
    icon: Icons.description_outlined,
    jornal: RaschetlistokJornal(),
    newItem: RaschetlistokItem(),
  ),
];

// ─────────────────────────────────────────────
// Пункты Drawer
// ─────────────────────────────────────────────

class _DrawerItem {
  final IconData icon;
  final String title;
  final WidgetBuilder builder;
  const _DrawerItem(this.icon, this.title, this.builder);
}

final List<_DrawerItem> _drawerItems = [
  _DrawerItem(
    Icons.business_outlined,
    'Организации',
    (_) => const OrganizaciiList(),
  ),
  _DrawerItem(
    Icons.account_tree_outlined,
    'Подразделения',
    (_) => const PodrazdeleniaList(),
  ),
  _DrawerItem(Icons.work_outline, 'Должности', (_) => const DolznostiList()),
  _DrawerItem(
    Icons.people_outline,
    'Сотрудники',
    (_) => const SotrudnikiList(),
  ),
  _DrawerItem(
    Icons.receipt_outlined,
    'Налоговые вычеты',
    (_) => const NalogovievichetiList(),
  ),
  _DrawerItem(
    Icons.health_and_safety_outlined,
    'Условия труда',
    (_) => const UslTrudaList(),
  ),
];

// ─────────────────────────────────────────────
// Пункты FAB
// ─────────────────────────────────────────────

class _FabMenuItem {
  final IconData icon;
  final String label;
  const _FabMenuItem(this.icon, this.label);
}

const _fabItems = <_FabMenuItem>[
  _FabMenuItem(Icons.note_add_outlined, 'Новый документ'),
  _FabMenuItem(Icons.folder_copy_outlined, 'Журналы документов'),
  _FabMenuItem(Icons.menu_book_outlined, 'Справочники'),
];

// ─────────────────────────────────────────────
// HomePage
// ─────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _prefs = AppPrefsService.instance;

  bool _fabExpanded = false;
  late bool _docListReversed;

  List<DocumentItem> _documents = [];
  bool _isLoading = true;

  late final AnimationController _fabController;
  late final Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _docListReversed = _prefs.docListReversed;
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
    _loadDocuments();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    final docs = await _loadDocumentsFromDb();
    if (mounted)
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
  }

  void _toggleFab() {
    setState(() {
      _fabExpanded = !_fabExpanded;
      _fabExpanded ? _fabController.forward() : _fabController.reverse();
    });
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    setState(() => _docListReversed = _prefs.docListReversed);
  }

  // ── Диалог выбора типа документа для создания ─────────────────

  Future<void> _showNewDocumentDialog() async {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Новый документ',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ..._jornals.map(
              (j) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(j.icon, color: scheme.onPrimaryContainer),
                ),
                title: Text(j.label),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => j.newItem),
                  );
                  _loadDocuments();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Диалог выбора журнала ───────────────────────────────────────

  Future<void> _showJornalsDialog() async {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Журналы документов',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ..._jornals.map(
              (j) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.secondaryContainer,
                  child: Icon(j.icon, color: scheme.onSecondaryContainer),
                ),
                title: Text('Журнал: ${j.label.toLowerCase()}'),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => j.jornal),
                  );
                  _loadDocuments();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Диалог выбора справочника ───────────────────────────────────

  Future<void> _showSpravochnikiDialog() async {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Справочники',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ..._drawerItems.map(
              (d) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.tertiaryContainer,
                  child: Icon(d.icon, color: scheme.onTertiaryContainer),
                ),
                title: Text(d.title),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: d.builder),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Открыть документ на редактирование ─────────────────────────
  //
  // Для начислений и удержаний отдельных страниц нет — переходим
  // в соответствующий журнал, отфильтрованный по id не нужен,
  // просто открываем журнал.

  Future<void> _openDocumentItem(DocumentItem doc) async {
    Widget? page;

    switch (doc.type) {
      case DocType.avans:
        // Загружаем полную запись из БД и открываем AvansItem
        final db = await DatabaseHelper().database;
        final rows = await db.rawQuery(
          '''
          SELECT a.*, s.familiya || ' ' || s.name || ' ' || s.otchestvo AS fio
          FROM avans a LEFT JOIN sotrudniki s ON s.id = a.sotrudnikId
          WHERE a.id = ?
        ''',
          [doc.id],
        );
        if (rows.isNotEmpty && mounted) {
          page = AvansItem(item: rows.first);
        }
        break;

      case DocType.otpusk:
        final db = await DatabaseHelper().database;
        final rows = await db.rawQuery(
          '''
          SELECT o.*, s.familiya || ' ' || s.name || ' ' || s.otchestvo AS fio
          FROM otpusk o LEFT JOIN sotrudniki s ON s.id = o.sotrudnikId
          WHERE o.id = ?
        ''',
          [doc.id],
        );
        if (rows.isNotEmpty && mounted) {
          page = OtpuskItem(item: rows.first);
        }
        break;

      case DocType.vedomost:
        final db = await DatabaseHelper().database;
        final rows = await db.rawQuery(
          '''
          SELECT pv.*,
                 o.nazvanie  AS orgNazvanie,
                 pd.nazvanie AS podrazNazvanie
          FROM platezhVedomost pv
          LEFT JOIN organizaciya   o  ON o.id  = pv.organizaciyaId
          LEFT JOIN podrazdeleniya pd ON pd.id = pv.podrazdelenieId
          WHERE pv.id = ?
        ''',
          [doc.id],
        );
        if (rows.isNotEmpty && mounted) {
          page = PlatvedomostItem(item: rows.first);
        }
        break;

      case DocType.listok:
        final db = await DatabaseHelper().database;
        final rows = await db.rawQuery(
          '''
          SELECT rl.*, zm.statusMesyaca
          FROM raschetnyListok rl
          LEFT JOIN zarplataMesyac zm ON zm.id = rl.zarplataMesyacId
          WHERE rl.id = ?
        ''',
          [doc.id],
        );
        if (rows.isNotEmpty && mounted) {
          page = RaschetlistokItem(item: rows.first);
        }
        break;

      // Для начислений и удержаний открываем соответствующий журнал
      case DocType.nachislenie:
      case DocType.uderzhanie:
        // TODO: добавить NachisleniyaJornal / UderzhaniyaJornal когда будут готовы
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Журнал начислений/удержаний в разработке'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
    }

    if (page != null && mounted) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
      _loadDocuments();
    }
  }

  // ── Обработчик нажатий на FAB-пункты ───────────────────────────

  Future<void> _onFabItemTap(int index) async {
    _toggleFab();
    await Future.delayed(const Duration(milliseconds: 150));
    switch (index) {
      case 0:
        await _showNewDocumentDialog();
        break;
      case 1:
        await _showJornalsDialog();
        break;
      case 2:
        await _showSpravochnikiDialog();
        break;
    }
  }

  // ── Пустой экран ─────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: scheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Документов пока нет',
            style: text.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите кнопку + чтобы добавить\nпервый документ',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.outline),
          ),
          const SizedBox(height: 32),
          FilledButton.tonal(
            onPressed: _showNewDocumentDialog,
            child: const Text('Добавить документ'),
          ),
        ],
      ),
    );
  }

  // ── Список документов ────────────────────────────────────────

  Widget _buildDocumentList(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_documents.isEmpty) return _buildEmptyState(context);

    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final groups = _buildGroups(_documents, _docListReversed);

    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: groups.length,
        itemBuilder: (context, i) {
          final entry = groups[i];
          final docs = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: text.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Divider(color: scheme.outlineVariant, height: 1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${docs.length} doc.',
                      style: text.labelSmall?.copyWith(color: scheme.outline),
                    ),
                  ],
                ),
              ),
              ...docs.map((doc) => _buildDocumentTile(context, doc)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocumentTile(BuildContext context, DocumentItem doc) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: scheme.secondaryContainer,
            child: Icon(
              doc.type.icon,
              color: scheme.onSecondaryContainer,
              size: 20,
            ),
          ),
          if (doc.isNew)
            Positioned(
              right: -2,
              top: -2,
              child: CircleAvatar(radius: 5, backgroundColor: scheme.primary),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              doc.title,
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            doc.amount,
            style: text.bodyMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          doc.subtitle,
          style: text.bodySmall?.copyWith(color: scheme.outline),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () => _openDocumentItem(doc), // ← открываем документ
    );
  }

  // ── Drawer ───────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return NavigationDrawer(
      selectedIndex: -1,
      onDestinationSelected: (int index) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: _drawerItems[index].builder),
        );
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.calculate_outlined,
                  color: scheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(widget.title, style: text.titleMedium),
              Text(
                'Справочники',
                style: text.bodySmall?.copyWith(color: scheme.outline),
              ),
            ],
          ),
        ),
        const Divider(indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'СПРАВОЧНИКИ',
            style: text.labelSmall?.copyWith(
              color: scheme.outline,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ..._drawerItems.map(
          (item) => NavigationDrawerDestination(
            icon: Icon(item.icon),
            label: Text(item.title),
          ),
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Настройки'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          onTap: () {
            Navigator.pop(context);
            _openSettings();
          },
        ),
      ],
    );
  }

  // ── FAB ──────────────────────────────────────────────────────

  Widget _buildFab(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ..._fabItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) => Opacity(
              opacity: _fabAnimation.value,
              child: Transform.translate(
                offset: Offset(
                  0,
                  (1 - _fabAnimation.value) * 20.0 * (index + 1),
                ),
                child: child,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _fabAnimation,
                    builder: (context, _) => Opacity(
                      opacity: _fabAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.shadow.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item.label,
                          style: text.labelMedium?.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton.small(
                    heroTag: 'fab_$index',
                    onPressed: () => _onFabItemTap(index), // ← подключено
                    child: Icon(item.icon),
                  ),
                ],
              ),
            ),
          );
        }),
        FloatingActionButton(
          heroTag: 'fab_main',
          onPressed: _toggleFab,
          child: AnimatedRotation(
            turns: _fabExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 220),
            child: const Icon(Icons.add),
          ),
        ),
      ],
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
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Поиск',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Фильтр',
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: GestureDetector(
        onTap: () {
          if (_fabExpanded) _toggleFab();
        },
        child: _buildDocumentList(context),
      ),
      floatingActionButton: _buildFab(context),
    );
  }
}
