import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'raschetlistokitem.dart';

class RaschetlistokJornal extends StatefulWidget {
  const RaschetlistokJornal({super.key});
  @override
  State<RaschetlistokJornal> createState() => _RaschetlistokJornalState();
}

class _RaschetlistokJornalState extends State<RaschetlistokJornal> {
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
      SELECT rl.*,
             zm.statusMesyaca
      FROM raschetnyListok rl
      LEFT JOIN zarplataMesyac zm ON zm.id = rl.zarplataMesyacId
      ORDER BY rl.god DESC, rl.mesyac DESC, rl.sotrudnikFio ASC
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
      MaterialPageRoute(builder: (_) => RaschetlistokItem(item: item)),
    );
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final ok = await showDeleteDialog(
      context,
      title: 'Удалить расчётный листок?',
      content:
          '${item['sotrudnikFio'] ?? '—'} · '
          '${item['periodLabel'] ?? '—'} будет удалён.',
    );
    if (ok && mounted) {
      await _db.delete('raschetnyListok', item['id'] as int);
      showSnack(context, 'Листок удалён');
      _load();
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
        title: const Text('Журнал расчётных листков'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Расчётных листков нет',
              subtitle: 'Нажмите + чтобы создать листок',
              onAdd: () => _openItem(),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  final vydan = (item['vydanSotrudniku'] as int? ?? 0) == 1;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          backgroundColor: scheme.primaryContainer,
                          child: Icon(
                            Icons.description_outlined,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        if (!vydan)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: scheme.primary,
                            ),
                          ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['sotrudnikFio']?.toString() ?? '—',
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${item['itogoNachisleno']} ₽',
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
                          item['periodLabel']?.toString() ?? '—',
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
                            color: vydan
                                ? scheme.primary.withOpacity(0.1)
                                : scheme.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            vydan ? 'Выдан' : 'Не выдан',
                            style: text.labelSmall?.copyWith(
                              color: vydan ? scheme.primary : scheme.tertiary,
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
