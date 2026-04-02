import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'otpuskitem.dart';

class OtpuskJornal extends StatefulWidget {
  const OtpuskJornal({super.key});
  @override
  State<OtpuskJornal> createState() => _OtpuskJornalState();
}

class _OtpuskJornalState extends State<OtpuskJornal> {
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
      SELECT o.*,
             s.familiya || ' ' || s.name || ' ' || s.otchestvo AS fio
      FROM otpusk o
      LEFT JOIN sotrudniki s ON s.id = o.sotrudnikId
      ORDER BY o.dateNachala DESC
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
      MaterialPageRoute(builder: (_) => OtpuskItem(item: item)),
    );
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final db = await _db.database;
    final deps = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM raschetOtpusknyh WHERE otpuskId = ?',
      [item['id']],
    );
    final cnt = deps.first['cnt'] as int? ?? 0;
    if (cnt > 0) {
      if (mounted)
        await showDeleteBlockedDialog(
          context,
          title: 'Удаление невозможно',
          content:
              'К этому отпуску привязан расчёт отпускных.\n'
              'Сначала удалите расчёт.',
        );
      return;
    }
    final ok = await showDeleteDialog(
      context,
      title: 'Удалить отпуск?',
      content:
          'Отпуск сотрудника «${item['fio'] ?? '—'}» '
          'с ${item['dateNachala']} по ${item['dateOkonchaniya']} будет удалён.',
    );
    if (ok && mounted) {
      await _db.delete('otpusk', item['id'] as int);
      showSnack(context, 'Отпуск удалён');
      _load();
    }
  }

  String _vidLabel(String vid) {
    switch (vid) {
      case 'uchebniy':
        return 'Учебный';
      case 'dekretnyy':
        return 'Декретный';
      case 'bez_oplaty':
        return 'Без оплаты';
      default:
        return 'Ежегодный';
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
        title: const Text('Журнал отпусков'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Отпусков пока нет',
              subtitle: 'Нажмите + чтобы добавить отпуск',
              onAdd: () => _openItem(),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final item = _items[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: scheme.secondaryContainer,
                      child: Icon(
                        Icons.beach_access_outlined,
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
                        Text(
                          '${item['kolichestvoDney']} дн.',
                          style: text.bodyMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${_vidLabel(item['vidOtpuska']?.toString() ?? '')} · '
                      '${item['dateNachala']} – ${item['dateOkonchaniya']}',
                      style: text.bodySmall?.copyWith(color: scheme.outline),
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
