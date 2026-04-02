import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'platvedomostitem.dart';

class PlatvedomostJornal extends StatefulWidget {
  const PlatvedomostJornal({super.key});
  @override
  State<PlatvedomostJornal> createState() => _PlatvedomostJornalState();
}

class _PlatvedomostJornalState extends State<PlatvedomostJornal> {
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
      SELECT pv.*,
             o.nazvanie  AS orgNazvanie,
             pd.nazvanie AS podrazNazvanie
      FROM platezhVedomost pv
      LEFT JOIN organizaciya   o  ON o.id  = pv.organizaciyaId
      LEFT JOIN podrazdeleniya pd ON pd.id = pv.podrazdelenieId
      ORDER BY pv.periodMesyac DESC, pv.dateVyplaty DESC
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
      MaterialPageRoute(builder: (_) => PlatvedomostItem(item: item)),
    );
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final db = await _db.database;
    final deps = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM platezhVedomostStroka WHERE vedomostId = ?',
      [item['id']],
    );
    final cnt = deps.first['cnt'] as int? ?? 0;
    if (cnt > 0) {
      if (mounted)
        await showDeleteBlockedDialog(
          context,
          title: 'Удаление невозможно',
          content:
              'В ведомости есть $cnt строк(и) с данными сотрудников.\n'
              'Сначала удалите строки ведомости.',
        );
      return;
    }
    final ok = await showDeleteDialog(
      context,
      title: 'Удалить ведомость?',
      content:
          '№${item['nomerVedomosti']} за ${item['periodMesyac']} '
          'будет удалена без возможности восстановления.',
    );
    if (ok && mounted) {
      await _db.delete('platezhVedomost', item['id'] as int);
      showSnack(context, 'Ведомость удалена');
      _load();
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'utverzdena':
        return 'Утверждена';
      case 'vyplacena':
        return 'Выплачена';
      case 'zakryta':
        return 'Закрыта';
      default:
        return 'Черновик';
    }
  }

  Color _statusColor(String s, ColorScheme scheme) {
    switch (s) {
      case 'utverzdena':
        return scheme.tertiary;
      case 'vyplacena':
        return scheme.primary;
      case 'zakryta':
        return scheme.outline;
      default:
        return scheme.secondary;
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
        title: const Text('Журнал платёжных ведомостей'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Ведомостей пока нет',
              subtitle: 'Нажмите + чтобы создать ведомость',
              onAdd: () => _openItem(),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  final status = item['statusVedomosti']?.toString() ?? '';
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '№${item['nomerVedomosti'] ?? '—'} · ${item['periodMesyac']}',
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${item['itogoPoPerechen']} ₽',
                          style: text.bodyMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['podrazNazvanie']?.toString() ?? '—',
                            style: text.bodySmall?.copyWith(
                              color: scheme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
