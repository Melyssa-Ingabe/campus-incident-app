import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../utils/incident_ui.dart';

class CategorySelector extends StatelessWidget {
  final IncidentCategory? selected;
  final ValueChanged<IncidentCategory> onChanged;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: IncidentCategory.values.map((category) {
        final isSelected = category == selected;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 104,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  categoryIcon(category),
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                ),
                const SizedBox(height: 6),
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? theme.colorScheme.onPrimary : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}