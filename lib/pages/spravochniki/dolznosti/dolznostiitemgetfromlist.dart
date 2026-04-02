import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'dolznostiitem.dart';

class DolznostiItemGetFromList extends StatefulWidget {
  const DolznostiItemGetFromList({super.key});
  @override
  State<DolznostiItemGetFromList> createState() =>
      _DolznostiItemGetFromListState();
}

class _DolznostiItemGetFromListState extends State<DolznostiItemGetFromList> {
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: const Text('Выбор должности'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Должностей пока нет',
              subtitle: 'Добавьте должности в справочнике',
              onAdd: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DolznostiItem()),
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
                    backgroundColor: scheme.tertiaryContainer,
                    child: Icon(
                      Icons.work_outline,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                  title: Text(item['nazvanie']?.toString() ?? '—'),
                  subtitle: Text(
                    item['podrazNazvanie']?.toString() ?? '—',
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
                          builder: (_) => DolznostiItem(item: item),
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
