import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'podrazdeleniaitem.dart';

class PodrazdeleniaList extends StatefulWidget {
  const PodrazdeleniaList({super.key});

  @override
  State<PodrazdeleniaList> createState() => _PodrazdeleniaListState();
}

class _PodrazdeleniaListState extends State<PodrazdeleniaList> {
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
      SELECT p.*, o.nazvanie AS orgNazvanie
      FROM podrazdeleniya p
      LEFT JOIN organizaciya o ON o.id = p.organizaciyaId
      ORDER BY p.nazvanie ASC
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
      MaterialPageRoute(builder: (_) => PodrazdeleniaItem(item: item)),
    );
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final db = await _db.database;
    final deps = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM sotrudniki WHERE podrazdelenieId = ?',
      [item['id']],
    );
    final cnt = deps.first['cnt'] as int? ?? 0;
    if (cnt > 0) {
      if (mounted) {
        await showDeleteBlockedDialog(
          context,
          title: 'Удаление невозможно',
          content: 'Подразделение используется у $cnt сотрудника(ов).',
        );
      }
      return;
    }
    final confirmed = await showDeleteDialog(
      context,
      title: 'Удалить подразделение?',
      content:
          '«${item['nazvanie']}» будет удалено без возможности восстановления.',
    );
    if (confirmed && mounted) {
      await _db.delete('podrazdeleniya', item['id'] as int);
      showSnack(context, 'Подразделение удалено');
      _load();
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
        title: const Text('Подразделения'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Подразделений пока нет',
              subtitle: 'Нажмите + чтобы добавить подразделение',
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
                      backgroundColor: scheme.secondaryContainer,
                      child: Icon(
                        Icons.account_tree_outlined,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(item['nazvanie']?.toString() ?? '—'),
                    subtitle: Text(
                      item['orgNazvanie']?.toString() ?? '—',
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
