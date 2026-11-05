import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, staff }

class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.createdAt,
  });

  bool get isStaff => role == UserRole.staff;

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: data['role'] == 'staff' ? UserRole.staff : UserRole.student,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}