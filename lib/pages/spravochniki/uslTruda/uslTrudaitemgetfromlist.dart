import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'uslTrudaitem.dart';

class UslTrudaItemGetFromList extends StatefulWidget {
  const UslTrudaItemGetFromList({super.key});
  @override
  State<UslTrudaItemGetFromList> createState() =>
      _UslTrudaItemGetFromListState();
}

class _UslTrudaItemGetFromListState extends State<UslTrudaItemGetFromList> {
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
    final data = await _db.getAllUslTruda();
    if (mounted)
      setState(() {
        _items = data;
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: const Text('Выбор условия труда'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Условий труда пока нет',
              subtitle: 'Добавьте условия труда в справочнике',
              onAdd: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UslTrudaItem()),
                );
                _load();
              },
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: scheme.tertiaryContainer,
                    child: Icon(
                      Icons.health_and_safety_outlined,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                  title: Text(
                    item['nazvanie']?.toString() ?? '—',
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Класс ${item['klassUslTruda']} · '
                    '${item['chasovVSmene']} ч/смена · '
                    '${item['graficRaboty']}',
                    style: text.bodySmall?.copyWith(color: scheme.outline),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new_outlined),
                    tooltip: 'Открыть',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UslTrudaItem(item: item),
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
