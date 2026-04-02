import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'sotrudnikiitem.dart';

class SotrudnikiList extends StatefulWidget {
  const SotrudnikiList({super.key});
  @override
  State<SotrudnikiList> createState() => _SotrudnikiListState();
}

class _SotrudnikiListState extends State<SotrudnikiList> {
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
    // JOIN на uslTruda — чтобы при открытии редактирования
    // поле uslTrudaNazvanie было предзаполнено
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

  Future<void> _openItem({Map<String, dynamic>? item}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SotrudnikiItem(item: item)),
    );
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final db = await _db.database;
    final tables = {
      'nachisleniya': 'начислениях',
      'uderzhaniya': 'удержаниях',
      'avans': 'авансах',
      'otpusk': 'отпусках',
      'tabel': 'табеле',
      'raschetnyListok': 'расчётных листках',
    };
    for (final entry in tables.entries) {
      final r = await db.rawQuery(
        'SELECT COUNT(*) AS cnt FROM ${entry.key} WHERE sotrudnikId = ?',
        [item['id']],
      );
      final cnt = r.first['cnt'] as int? ?? 0;
      if (cnt > 0) {
        if (mounted) {
          await showDeleteBlockedDialog(
            context,
            title: 'Удаление невозможно',
            content:
                'Сотрудник упоминается в $cnt записях '
                '(${entry.value}).\nСначала удалите связанные документы.',
          );
        }
        return;
      }
    }
    final fio = '${item['familiya']} ${item['name']} ${item['otchestvo']}';
    final ok = await showDeleteDialog(
      context,
      title: 'Удалить сотрудника?',
      content: '«$fio» будет удалён без возможности восстановления.',
    );
    if (ok && mounted) {
      await _db.delete('sotrudniki', item['id'] as int);
      showSnack(context, 'Сотрудник удалён');
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
        title: const Text('Сотрудники'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Сотрудников пока нет',
              subtitle: 'Нажмите + чтобы добавить сотрудника',
              onAdd: () => _openItem(),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
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
                      '${item['dolzhnostNazvanie'] ?? '—'} · '
                      '${item['podrazNazvanie'] ?? '—'}',
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
