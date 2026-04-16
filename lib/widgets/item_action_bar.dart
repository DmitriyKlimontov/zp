// Стиль парящих кнопок для всех страниц

import 'package:flutter/material.dart';

class ItemActionBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  /// Дополнительная кнопка (печать, документ и т.п.).
  /// Если null — кнопка не отображается.
  final VoidCallback? onExtra;
  final IconData extraIcon;
  final String extraLabel;

  const ItemActionBar({
    super.key,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
    this.onExtra,
    this.extraIcon = Icons.picture_as_pdf_outlined,
    this.extraLabel = 'Печать',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        elevation: 4,
        shadowColor: scheme.shadow.withOpacity(0.20),
        borderRadius: BorderRadius.circular(36),
        color: scheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              // ── Отмена ───────────────────────────────────────
              Expanded(
                child: _ActionButton(
                  icon: Icons.close_rounded,
                  label: 'Отмена',
                  color: scheme.onSurfaceVariant,
                  bgColor: scheme.surfaceContainerHighest,
                  onTap: onCancel,
                ),
              ),

              const SizedBox(width: 6),

              // ── Сохранить ─────────────────────────────────────
              Expanded(
                child: _ActionButton(
                  icon: Icons.check_rounded,
                  label: isSaving ? 'Сохранение...' : 'Сохранить',
                  color: scheme.onPrimary,
                  bgColor: isSaving
                      ? scheme.primary.withOpacity(0.55)
                      : scheme.primary,
                  onTap: isSaving ? null : onSave,
                  isLoading: isSaving,
                ),
              ),

              // ── Доп. кнопка (опционально) ─────────────────────
              if (onExtra != null) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: _ActionButton(
                    icon: extraIcon,
                    label: extraLabel,
                    color: scheme.onSecondaryContainer,
                    bgColor: scheme.secondaryContainer,
                    onTap: onExtra,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Кнопка внутри панели ─────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: text.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
