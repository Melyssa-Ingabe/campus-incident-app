import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/incident.dart';
import '../utils/incident_ui.dart';

class StatusTimeline extends StatelessWidget {
  final Incident incident;

  const StatusTimeline({super.key, required this.incident});

  DateTime? _dateFor(IncidentStatus status) {
    DateTime? found;
    for (final change in incident.statusHistory) {
      if (change.status == status) found = change.at;
    }
    return found;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = IncidentStatus.values;
    final currentIndex = incident.status.index;
    final format = DateFormat('d MMM, HH:mm');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final reached = i <= currentIndex;
        final color = reached
            ? statusColor(step)
            : theme.colorScheme.outlineVariant;
        final date = _dateFor(step);

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i == 0
                          ? Colors.transparent
                          : (reached
                              ? statusColor(step)
                              : theme.colorScheme.outlineVariant),
                    ),
                  ),
                  Container(
                    height: 26,
                    width: 26,
                    decoration: BoxDecoration(
                      color: reached ? color : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: reached
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i == steps.length - 1
                          ? Colors.transparent
                          : (i < currentIndex
                              ? statusColor(steps[i + 1])
                              : theme.colorScheme.outlineVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                step.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: reached ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date == null ? '—' : format.format(date),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
        );
      }),
    );
  }
}