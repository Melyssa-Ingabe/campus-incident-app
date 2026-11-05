import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/incident.dart';

class IncidentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('incidents');

  /// Staff see every report.
  Stream<List<Incident>> streamAll() {
    return _incidents.snapshots().map(_toSortedList);
  }

  /// Students only see the reports they submitted.
  Stream<List<Incident>> streamForReporter(String uid) {
    return _incidents
        .where('reporterId', isEqualTo: uid)
        .snapshots()
        .map(_toSortedList);
  }

  List<Incident> _toSortedList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final list = snapshot.docs
        .map((doc) => Incident.fromMap(doc.id, doc.data()))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> create({
    required AppUser reporter,
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    String? photoUrl,
  }) async {
    final now = Timestamp.now();
    await _incidents.add({
      'title': title.trim(),
      'description': description.trim(),
      'category': category.name,
      'location': location,
      'status': IncidentStatus.submitted.name,
      'photoUrl': photoUrl,
      'reporterId': reporter.uid,
      'reporterName': reporter.fullName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': [
        {
          'status': IncidentStatus.submitted.name,
          'at': now,
          'byName': reporter.fullName,
        }
      ],
    });
  }

  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required String staffName,
  }) async {
    await _incidents.doc(incidentId).update({
      'status': newStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': newStatus.name,
          'at': Timestamp.now(),
          'byName': staffName,
        }
      ]),
    });
  }

  Future<void> delete(String incidentId) async {
    await _incidents.doc(incidentId).delete();
  }
}