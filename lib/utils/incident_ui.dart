import 'package:flutter/material.dart';
import '../models/incident.dart';

IconData categoryIcon(IncidentCategory category) {
  switch (category) {
    case IncidentCategory.facilities:
      return Icons.apartment_rounded;
    case IncidentCategory.water:
      return Icons.water_drop_outlined;
    case IncidentCategory.electricity:
      return Icons.bolt_rounded;
    case IncidentCategory.safety:
      return Icons.shield_outlined;
    case IncidentCategory.sanitation:
      return Icons.delete_outline_rounded;
  }
}

Color statusColor(IncidentStatus status) {
  switch (status) {
    case IncidentStatus.submitted:
      return const Color(0xFFF59E0B);
    case IncidentStatus.inProgress:
      return const Color(0xFF6C4CF1);
    case IncidentStatus.resolved:
      return const Color(0xFF16A34A);
  }
}