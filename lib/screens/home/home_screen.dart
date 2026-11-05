import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/incident_ui.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/stat_tile.dart';
import '../reports/incident_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onReport;
  final VoidCallback onSeeAll;

  const HomeScreen({
    super.key,
    required this.onReport,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<IncidentProvider>();
    final theme = Theme.of(context);

    final fullName = auth.appUser?.fullName ?? '';
    final firstName = fullName.split(' ').first;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Hello, $firstName 👋',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            auth.isStaff
                ? 'Review reports and update their status.'
                : 'Help make our campus safer. Report issues and track their resolution.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'See an issue on campus?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Report it and help improve our learning environment.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: onReport,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Report an Issue'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report Summary',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.description_outlined,
                  color: const Color(0xFF6C4CF1),
                  value: data.totalCount,
                  label: auth.isStaff ? 'All Reports' : 'My Reports',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.error_outline,
                  color: statusColor(IncidentStatus.submitted),
                  value: data.submittedCount,
                  label: 'Submitted',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.schedule,
                  color: statusColor(IncidentStatus.inProgress),
                  value: data.inProgressCount,
                  label: 'In Progress',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  icon: Icons.check_circle_outline,
                  color: statusColor(IncidentStatus.resolved),
                  value: data.resolvedCount,
                  label: 'Resolved',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent reports
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Reports',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
            ],
          ),
          const SizedBox(height: 4),
          if (data.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (data.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(data.errorMessage!)),
            )
          else if (data.recent.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No reports yet. Tap "Report an Issue" to start.'),
              ),
            )
          else
                        ...data.recent.map(
              (incident) => IncidentCard(
                incident: incident,
                showReporter: auth.isStaff,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          IncidentDetailScreen(incidentId: incident.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}