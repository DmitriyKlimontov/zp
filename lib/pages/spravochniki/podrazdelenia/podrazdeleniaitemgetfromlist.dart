import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'podrazdeleniaitem.dart';

class PodrazdeleniaItemGetFromList extends StatefulWidget {
  const PodrazdeleniaItemGetFromList({super.key});

  @override
  State<PodrazdeleniaItemGetFromList> createState() =>
      _PodrazdeleniaItemGetFromListState();
}

class _PodrazdeleniaItemGetFromListState
    extends State<PodrazdeleniaItemGetFromList> {
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: const Text('Выбор подразделения'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Подразделений пока нет',
              subtitle: 'Добавьте подразделения в справочнике',
              onAdd: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PodrazdeleniaItem()),
                );
                _load();
              },
            )
          : ListView.builder(
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
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new_outlined),
                    tooltip: 'Открыть',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PodrazdeleniaItem(item: item),
                        ),
                      );
                      _load();
                    },
                  ),
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
    );
  }
}
