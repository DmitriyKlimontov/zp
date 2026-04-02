import 'package:flutter/material.dart';
import 'package:zp/db/database.dart';
import 'package:zp/pages/spravochniki/spravochniki_shared.dart';
import 'uslTrudaitem.dart';

class UslTrudaList extends StatefulWidget {
  const UslTrudaList({super.key});
  @override
  State<UslTrudaList> createState() => _UslTrudaListState();
}

class _UslTrudaListState extends State<UslTrudaList> {
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

  Future<void> _openItem({Map<String, dynamic>? item}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UslTrudaItem(item: item)),
    );
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    // Проверка зависимостей
    final cnt = await _db.countSotrudnikiByUslTruda(item['id'] as int);
    if (cnt > 0) {
      if (mounted)
        await showDeleteBlockedDialog(
          context,
          title: 'Удаление невозможно',
          content:
              'Условие труда используется у $cnt сотрудника(ов).\n'
              'Сначала измените условие труда у этих сотрудников.',
        );
      return;
    }
    final ok = await showDeleteDialog(
      context,
      title: 'Удалить условие труда?',
      content:
          '«${item['nazvanie']}» будет удалено без возможности восстановления.',
    );
    if (ok && mounted) {
      await _db.deleteUslTruda(item['id'] as int);
      showSnack(context, 'Условие труда удалено');
      _load();
    }
  }

  String _klassLabel(String klass) {
    switch (klass) {
      case '1':
        return 'Класс 1 — Оптимальные';
      case '2':
        return 'Класс 2 — Допустимые';
      case '3.1':
        return 'Класс 3.1 — Вредные';
      case '3.2':
        return 'Класс 3.2 — Вредные';
      case '3.3':
        return 'Класс 3.3 — Вредные';
      case '3.4':
        return 'Класс 3.4 — Вредные';
      case '4':
        return 'Класс 4 — Опасные';
      default:
        return klass.isNotEmpty ? 'Класс $klass' : '—';
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
        title: const Text('Условия труда'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? buildEmptyState(
              context: context,
              title: 'Условий труда пока нет',
              subtitle: 'Нажмите + чтобы добавить условие труда',
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _klassLabel(item['klassUslTruda']?.toString() ?? ''),
                          style: text.bodySmall?.copyWith(
                            color: scheme.outline,
                          ),
                        ),
                        Text(
                          '${item['chasovVSmene']} ч/смена · '
                          '${item['graficRaboty']}',
                          style: text.bodySmall?.copyWith(
                            color: scheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    isThreeLine: true,
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
