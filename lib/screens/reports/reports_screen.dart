import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';
import 'incident_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _open(Incident incident) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncidentDetailScreen(incidentId: incident.id),
      ),
    );
  }

  bool _hasFilters(IncidentProvider data) =>
      data.searchQuery.isNotEmpty ||
      data.categoryFilter != null ||
      data.statusFilter != null;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<IncidentProvider>();
    final theme = Theme.of(context);
    final results = data.filtered;

    Widget body;
    if (data.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (data.errorMessage != null) {
      body = Center(child: Text(data.errorMessage!));
    } else if (data.incidents.isEmpty) {
      body = const Center(child: Text('No reports yet.'));
    } else if (results.isEmpty) {
      body = const Center(child: Text('No reports match your search.'));
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
        children: results
            .map(
              (i) => IncidentCard(
                incident: i,
                showReporter: auth.isStaff,
                onTap: () => _open(i),
              ),
            )
            .toList(),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              auth.isStaff ? 'All Reports' : 'My Reports',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: data.setSearch,
              decoration: InputDecoration(
                hintText: 'Search by title, description or location',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: data.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          data.setSearch('');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _chip(
                  label: 'All status',
                  selected: data.statusFilter == null,
                  onTap: () => data.setStatusFilter(null),
                ),
                ...IncidentStatus.values.map(
                  (s) => _chip(
                    label: s.label,
                    selected: data.statusFilter == s,
                    onTap: () => data.setStatusFilter(s),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _chip(
                  label: 'All categories',
                  selected: data.categoryFilter == null,
                  onTap: () => data.setCategoryFilter(null),
                ),
                ...IncidentCategory.values.map(
                  (c) => _chip(
                    label: c.label,
                    selected: data.categoryFilter == c,
                    onTap: () => data.setCategoryFilter(c),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${results.length} of ${data.incidents.length} reports',
                  style: theme.textTheme.bodySmall,
                ),
                if (_hasFilters(data))
                  TextButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      data.clearFilters();
                    },
                    child: const Text('Clear filters'),
                  ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}