// ════════════════════════════════════════════════════════════════
//  Список налоговых вычетов по сотрудникам
// ════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'nalogovievichetiitem.dart';

class NalogovievichetiList extends StatefulWidget {
  const NalogovievichetiList({super.key});
  @override
  State<NalogovievichetiList> createState() => _NalogovievichetiListState();
}

class _NalogovievichetiListState extends State<NalogovievichetiList> {
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
      SELECT nv.*,
             s.familiya || ' ' || s.name || ' ' || s.otchestvo AS fio
      FROM nalogovyeVychety nv
      LEFT JOIN sotrudniki s ON s.id = nv.sotrudnikId
      ORDER BY s.familiya ASC, nv.kodVycheta ASC
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
      MaterialPageRoute(builder: (_) => NalogovievichetiItem(item: item)),
    );
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final ok = await showDeleteDialog(
      context,
      title: 'Удалить вычет?',
      content:
          'Вычет «${item['nazvanie']}» (код ${item['kodVycheta']}) '
          'будет удалён без возможности восстановления.',
    );
    if (ok && mounted) {
      await _db.delete('nalogovyeVychety', item['id'] as int);
      showSnack(context, 'Вычет удалён');
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
        title: const Text('Налоговые вычеты'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Вычетов пока нет',
              subtitle: 'Нажмите + чтобы добавить вычет',
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
                      child: Text(
                        '${item['kodVycheta'] ?? ''}',
                        style: TextStyle(
                          color: scheme.onSecondaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(item['nazvanie']?.toString() ?? '—'),
                    subtitle: Text(
                      '${item['fio'] ?? '—'} · '
                      '${item['summaVycheta']} ₽',
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
