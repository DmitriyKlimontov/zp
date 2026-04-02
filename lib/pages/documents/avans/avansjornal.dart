import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'avansitem.dart';

class AvansJornal extends StatefulWidget {
  const AvansJornal({super.key});
  @override
  State<AvansJornal> createState() => _AvansJornalState();
}

class _AvansJornalState extends State<AvansJornal> {
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
      SELECT a.*,
             s.familiya || ' ' || s.name || ' ' || s.otchestvo AS fio
      FROM avans a
      LEFT JOIN sotrudniki s ON s.id = a.sotrudnikId
      ORDER BY a.periodMesyac DESC, a.dateVyplaty DESC
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
      MaterialPageRoute(builder: (_) => AvansItem(item: item)),
    );
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final ok = await showDeleteDialog(
      context,
      title: 'Удалить аванс?',
      content:
          'Аванс сотрудника «${item['fio'] ?? '—'}» '
          'за ${item['periodMesyac']} будет удалён.',
    );
    if (ok && mounted) {
      await _db.delete('avans', item['id'] as int);
      showSnack(context, 'Аванс удалён');
      _load();
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'vyplaceno':
        return 'Выплачен';
      case 'otmeneno':
        return 'Отменён';
      default:
        return 'Начислен';
    }
  }

  Color _statusColor(String status, ColorScheme scheme) {
    switch (status) {
      case 'vyplaceno':
        return scheme.primary;
      case 'otmeneno':
        return scheme.error;
      default:
        return scheme.tertiary;
    }
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
        title: const Text('Журнал авансов'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Авансов пока нет',
              subtitle: 'Нажмите + чтобы добавить аванс',
              onAdd: () => _openItem(),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  final status = item['statusVyplaty']?.toString() ?? '';
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: scheme.secondaryContainer,
                      child: Icon(
                        Icons.payments_outlined,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['fio']?.toString() ?? '—',
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item['summaAvansa']} ₽',
                          style: text.bodyMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          item['periodMesyac']?.toString() ?? '—',
                          style: text.bodySmall?.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(
                              status,
                              scheme,
                            ).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _statusLabel(status),
                            style: text.labelSmall?.copyWith(
                              color: _statusColor(status, scheme),
                            ),
                          ),
                        ),
                      ],
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
