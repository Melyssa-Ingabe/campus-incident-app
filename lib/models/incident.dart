import 'package:cloud_firestore/cloud_firestore.dart';

enum IncidentCategory { facilities, water, electricity, safety, sanitation }

enum IncidentStatus { submitted, inProgress, resolved }

extension IncidentCategoryX on IncidentCategory {
  String get label {
    switch (this) {
      case IncidentCategory.facilities:
        return 'Facilities';
      case IncidentCategory.water:
        return 'Water';
      case IncidentCategory.electricity:
        return 'Electricity';
      case IncidentCategory.safety:
        return 'Safety';
      case IncidentCategory.sanitation:
        return 'Sanitation';
    }
  }
}

extension IncidentStatusX on IncidentStatus {
  String get label {
    switch (this) {
      case IncidentStatus.submitted:
        return 'Submitted';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }
}

class StatusChange {
  final IncidentStatus status;
  final DateTime at;
  final String byName;

  const StatusChange({
    required this.status,
    required this.at,
    required this.byName,
  });

  factory StatusChange.fromMap(Map<String, dynamic> map) {
    return StatusChange(
      status: IncidentStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => IncidentStatus.submitted,
      ),
      at: (map['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      byName: map['byName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'at': Timestamp.fromDate(at),
      'byName': byName,
    };
  }
}

class Incident {
  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentStatus status;
  final String? photoUrl;
  final String reporterId;
  final String reporterName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusChange> statusHistory;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.statusHistory = const [],
  });

  factory Incident.fromMap(String id, Map<String, dynamic> data) {
    final history = (data['statusHistory'] as List<dynamic>? ?? [])
        .map((e) => StatusChange.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final created = (data['createdAt'] as Timestamp?)?.toDate();
    final updated = (data['updatedAt'] as Timestamp?)?.toDate();

    return Incident(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: IncidentCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => IncidentCategory.facilities,
      ),
      location: data['location'] ?? '',
      status: IncidentStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => IncidentStatus.submitted,
      ),
      photoUrl: data['photoUrl'],
      reporterId: data['reporterId'] ?? '',
      reporterName: data['reporterName'] ?? '',
      createdAt: created ?? DateTime.now(),
      updatedAt: updated ?? created ?? DateTime.now(),
      statusHistory: history,
    );
  }
}