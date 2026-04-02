import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'nalogovievichetiitem.dart';

class NalogovievichetiItemGetFromList extends StatefulWidget {
  const NalogovievichetiItemGetFromList({super.key});
  @override
  State<NalogovievichetiItemGetFromList> createState() =>
      _NalogovievichetiItemGetFromListState();
}

class _NalogovievichetiItemGetFromListState
    extends State<NalogovievichetiItemGetFromList> {
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: const Text('Выбор вычета'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Вычетов пока нет',
              subtitle: 'Добавьте вычеты в справочнике',
              onAdd: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NalogovievichetiItem(),
                  ),
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
                    '${item['fio'] ?? '—'} · ${item['summaVycheta']} ₽',
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
                          builder: (_) => NalogovievichetiItem(item: item),
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
