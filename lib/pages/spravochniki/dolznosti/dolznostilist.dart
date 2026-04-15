// ════════════════════════════════════════════════════════════════
//  Список справочника Должности
// ════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'dolznostiitem.dart';

class DolznostiList extends StatefulWidget {
  const DolznostiList({super.key});
  @override
  State<DolznostiList> createState() => _DolznostiListState();
}

class _DolznostiListState extends State<DolznostiList> {
  final _db = DatabaseHelper();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final db = await _db.database;
    final data = await db.rawQuery('''
      SELECT d.*, p.nazvanie AS podrazNazvanie
      FROM dolzhnosti d
      LEFT JOIN podrazdeleniya p ON p.id = d.podrazdelenieId
      ORDER BY d.nazvanie ASC
    ''');
    if (mounted)
      setState(() {
        _items = data;
        _isLoading = false;
      });
  }

  Future<void> _openItem({Map<String, dynamic>? item}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DolznostiItem(item: item)),
    );
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final db = await _db.database;
    final deps = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM sotrudniki WHERE dolzhnostId = ?',
      [item['id']],
    );
    final cnt = deps.first['cnt'] as int? ?? 0;
    if (cnt > 0) {
      if (mounted)
        await showDeleteBlockedDialog(
          context,
          title: 'Удаление невозможно',
          content: 'Должность назначена $cnt сотруднику(ам).',
        );
      return;
    }
    final ok = await showDeleteDialog(
      context,
      title: 'Удалить должность?',
      content: '«${item['nazvanie']}» будет удалена.',
    );
    if (ok && mounted) {
      await _db.delete('dolzhnosti', item['id'] as int);
      showSnack(context, 'Должность удалена');
      _load();
    }
  }

  String _oplatyLabel(Map<String, dynamic> item) {
    final isOklad = (item['isOklad'] as int? ?? 1) == 1;
    if (isOklad) {
      final oklad = (item['oklad'] as num?)?.toDouble() ?? 0.0;
      return 'Оклад: ${oklad.toStringAsFixed(0)} ₽/мес';
    } else {
      final stavka = (item['chasovayaStavka'] as num?)?.toDouble() ?? 0.0;
      return 'Часовая ставка: ${stavka.toStringAsFixed(2)} ₽/ч';
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
        title: const Text('Должности'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Должностей пока нет',
              subtitle: 'Нажмите + чтобы добавить должность',
              onAdd: () => _openItem(),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.tertiaryContainer,
                      child: Icon(
                        Icons.work_outline,
                        color: scheme.onTertiaryContainer,
                      ),
                    ),
                    title: Text(item['nazvanie']?.toString() ?? '—'),
                    subtitle: Text(
                      '${item['podrazNazvanie'] ?? '—'} · ${_oplatyLabel(item)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: scheme.outline),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: scheme.error,
                          onPressed: () => _delete(item),
                        ),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                    onTap: () => _openItem(item: item),
                  );
                },
              ),
            ),
      floatingActionButton: buildAddFab(() => _openItem()),
    );
  }
}
