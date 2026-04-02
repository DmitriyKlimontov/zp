import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'sotrudnikiitem.dart';

class SotrudnikiItemGetFromList extends StatefulWidget {
  const SotrudnikiItemGetFromList({super.key});
  @override
  State<SotrudnikiItemGetFromList> createState() =>
      _SotrudnikiItemGetFromListState();
}

class _SotrudnikiItemGetFromListState extends State<SotrudnikiItemGetFromList> {
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
    // JOIN на uslTruda — чтобы uslTrudaNazvanie был заполнен
    // при открытии SotrudnikiItem в режиме редактирования
    final data = await db.rawQuery('''
      SELECT s.*,
             d.nazvanie AS dolzhnostNazvanie,
             p.nazvanie AS podrazNazvanie,
             u.nazvanie AS uslTrudaNazvanie
      FROM sotrudniki s
      LEFT JOIN dolzhnosti     d ON d.id = s.dolzhnostId
      LEFT JOIN podrazdeleniya p ON p.id = s.podrazdelenieId
      LEFT JOIN uslTruda       u ON u.id = s.uslTrudaId
      ORDER BY s.familiya ASC, s.name ASC
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
        title: const Text('Выбор сотрудника'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Сотрудников пока нет',
              subtitle: 'Добавьте сотрудников в справочнике',
              onAdd: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SotrudnikiItem()),
                );
                _load();
              },
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                final fio =
                    '${item['familiya']} ${item['name']} '
                    '${item['otchestvo']}';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      (item['familiya']?.toString() ?? '?')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(fio),
                  subtitle: Text(
                    item['dolzhnostNazvanie']?.toString() ?? '—',
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
                          builder: (_) => SotrudnikiItem(item: item),
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
