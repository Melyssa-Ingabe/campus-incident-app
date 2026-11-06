import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/services/auth_service.dart';
import 'package:campus_incident_app/utils/validators.dart';

void main() {
  group('Email validation (ALU only)', () {
    test('accepts student and staff ALU emails', () {
      expect(Validators.email('jane@alustudent.com'), isNull);
      expect(Validators.email('john@alueducation.com'), isNull);
    });

    test('accepts plus aliases and mixed case', () {
      expect(Validators.email('Jane+staff@AluStudent.com'), isNull);
      expect(AuthService.isAllowedEmail('jane+x@alustudent.com'), isTrue);
    });

    test('rejects non-ALU and empty emails', () {
      expect(Validators.email('jane@gmail.com'), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
    });
  });

  group('Password validation', () {
    test('rejects short or empty passwords', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('12345'), isNotNull);
    });

    test('accepts 6+ characters', () {
      expect(Validators.password('abc123'), isNull);
    });

    test('confirm password must match', () {
      final check = Validators.confirmPassword(() => 'abc123');
      expect(check('abc123'), isNull);
      expect(check('different'), isNotNull);
    });
  });

  group('Incident model', () {
    test('parses a Firestore map', () {
      final incident = Incident.fromMap('id1', {
        'title': 'Water shortage',
        'description': 'No water since morning',
        'category': 'water',
        'location': 'Student Residence',
        'status': 'inProgress',
        'reporterId': 'u1',
        'reporterName': 'Amina',
      });

      expect(incident.id, 'id1');
      expect(incident.category, IncidentCategory.water);
      expect(incident.status, IncidentStatus.inProgress);
      expect(incident.photoUrl, isNull);
    });

    test('falls back to safe defaults for unknown values', () {
      final incident = Incident.fromMap('id2', {
        'category': 'unknown',
        'status': 'unknown',
      });

      expect(incident.category, IncidentCategory.facilities);
      expect(incident.status, IncidentStatus.submitted);
    });
  });
}