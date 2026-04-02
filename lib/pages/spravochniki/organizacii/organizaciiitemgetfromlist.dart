import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'organizaciiitem.dart';

class OrganizaciiItemGetFromList extends StatefulWidget {
  const OrganizaciiItemGetFromList({super.key});

  @override
  State<OrganizaciiItemGetFromList> createState() =>
      _OrganizaciiItemGetFromListState();
}

class _OrganizaciiItemGetFromListState
    extends State<OrganizaciiItemGetFromList> {
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
    final data = await _db.getAll('organizaciya');
    if (mounted)
      setState(() {
        _items = data;
        _isLoading = false;
      });
  }

  void _select(Map<String, dynamic> item) {
    Navigator.pop(context, item);
  }

  Future<void> _openItem(Map<String, dynamic> item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrganizaciiItem(item: item)),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        title: const Text('Выбор организации'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Организаций пока нет',
              subtitle: 'Добавьте организацию в справочнике',
              onAdd: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrganizaciiItem()),
                );
                _load();
              },
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final item = _items[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(
                      Icons.business_outlined,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(item['nazvanie']?.toString() ?? '—'),
                  subtitle: Text(
                    'ИНН: ${item['inn'] ?? '—'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: scheme.outline),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new_outlined),
                    tooltip: 'Открыть',
                    onPressed: () => _openItem(item),
                  ),
                  onTap: () => _select(item),
                );
              },
            ),
    );
  }
}
