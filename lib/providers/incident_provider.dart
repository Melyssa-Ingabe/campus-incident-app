import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service;
  StreamSubscription<List<Incident>>? _subscription;

  AppUser? _user;
  List<Incident> _incidents = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  IncidentCategory? _categoryFilter;
  IncidentStatus? _statusFilter;

  IncidentProvider({IncidentService? service})
      : _service = service ?? IncidentService();

  List<Incident> get incidents => _incidents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  IncidentCategory? get categoryFilter => _categoryFilter;
  IncidentStatus? get statusFilter => _statusFilter;

  int get totalCount => _incidents.length;
  int get submittedCount =>
      _incidents.where((i) => i.status == IncidentStatus.submitted).length;
  int get inProgressCount =>
      _incidents.where((i) => i.status == IncidentStatus.inProgress).length;
  int get resolvedCount =>
      _incidents.where((i) => i.status == IncidentStatus.resolved).length;

  List<Incident> get recent => _incidents.take(3).toList();

  List<Incident> get filtered {
    final query = _searchQuery.trim().toLowerCase();
    return _incidents.where((i) {
      final matchesQuery = query.isEmpty ||
          i.title.toLowerCase().contains(query) ||
          i.description.toLowerCase().contains(query) ||
          i.location.toLowerCase().contains(query);
      final matchesCategory =
          _categoryFilter == null || i.category == _categoryFilter;
      final matchesStatus = _statusFilter == null || i.status == _statusFilter;
      return matchesQuery && matchesCategory && matchesStatus;
    }).toList();
  }

  Incident? findById(String id) {
    for (final incident in _incidents) {
      if (incident.id == id) return incident;
    }
    return null;
  }

  /// Called whenever the logged-in user changes.
  void updateUser(AppUser? user) {
    if (user?.uid == _user?.uid) return;
    _user = user;
    _subscription?.cancel();
    _incidents = [];
    _errorMessage = null;

    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final stream = user.isStaff
        ? _service.streamAll()
        : _service.streamForReporter(user.uid);

    _subscription = stream.listen(
      (data) {
        _incidents = data;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _errorMessage = 'Could not load reports. Check your connection.';
        notifyListeners();
      },
    );
  }

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategoryFilter(IncidentCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setStatusFilter(IncidentStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    _statusFilter = null;
    notifyListeners();
  }

  Future<bool> submitIncident({
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    String? photoUrl,
  }) async {
    final user = _user;
    if (user == null) return false;
    try {
      await _service.create(
        reporter: user,
        title: title,
        description: description,
        category: category,
        location: location,
        photoUrl: photoUrl,
      );
      return true;
    } catch (_) {
      _errorMessage = 'Could not submit your report. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(String incidentId, IncidentStatus status) async {
    final user = _user;
    if (user == null || !user.isStaff) {
      _errorMessage = 'Only staff can update report status.';
      notifyListeners();
      return false;
    }
    try {
      await _service.updateStatus(
        incidentId: incidentId,
        newStatus: status,
        staffName: user.fullName,
      );
      return true;
    } catch (_) {
      _errorMessage = 'Could not update the status. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteIncident(String incidentId) async {
    try {
      await _service.delete(incidentId);
      return true;
    } catch (_) {
      _errorMessage = 'Could not delete the report. Please try again.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}