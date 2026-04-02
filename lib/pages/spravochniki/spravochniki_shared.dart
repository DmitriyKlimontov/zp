import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  Общие виджеты и утилиты для всех страниц справочников
// ─────────────────────────────────────────────────────────────

/// Секция-заголовок внутри формы элемента
Widget buildSectionHeader(BuildContext context, String title) {
  final scheme = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: scheme.primary,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// Стандартное текстовое поле формы
Widget buildTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  String? hint,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  bool readOnly = false,
  VoidCallback? onTap,
  String? Function(String?)? validator,
  Widget? suffixIcon,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
    ),
  );
}

/// Пустой экран для списков справочников
Widget buildEmptyState({
  required BuildContext context,
  required String title,
  required String subtitle,
  required VoidCallback onAdd,
}) {
  final scheme = Theme.of(context).colorScheme;
  final text = Theme.of(context).textTheme;
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_outlined, size: 80, color: scheme.outlineVariant),
        const SizedBox(height: 16),
        Text(
          title,
          style: text.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: scheme.outline),
        ),
        const SizedBox(height: 32),
        FilledButton.tonal(onPressed: onAdd, child: const Text('Добавить')),
      ],
    ),
  );
}

/// FAB «+» — единый стиль для всех списков
Widget buildAddFab(VoidCallback onPressed) {
  return FloatingActionButton(
    heroTag: 'fab_add',
    onPressed: onPressed,
    child: const Icon(Icons.add),
  );
}

/// Диалог подтверждения удаления
Future<bool> showDeleteDialog(
  BuildContext context, {
  required String title,
  required String content,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Диалог ошибки удаления (есть зависимые записи)
Future<void> showDeleteBlockedDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded),
      title: Text(title),
      content: Text(content),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Понятно'),
        ),
      ],
    ),
  );
}

/// SnackBar-уведомление
void showSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
