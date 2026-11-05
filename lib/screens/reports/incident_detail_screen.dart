import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../utils/incident_ui.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';

class IncidentDetailScreen extends StatefulWidget {
  final String incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  bool _updating = false;

  Future<void> _changeStatus(IncidentStatus status) async {
    setState(() => _updating = true);
    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await provider.updateStatus(widget.incidentId, status);

    if (!mounted) return;
    setState(() => _updating = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Status updated to ${status.label}.'
              : (provider.errorMessage ?? 'Could not update status.'),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final ok = await provider.deleteIncident(widget.incidentId);
    if (!mounted) return;

    if (ok) {
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Report deleted.')));
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Could not delete report.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final incident = context.watch<IncidentProvider>().findById(
          widget.incidentId,
        );
    final theme = Theme.of(context);

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: const Center(child: Text('This report is no longer available.')),
      );
    }

    final isOwner = auth.appUser?.uid == incident.reporterId;
    final canDelete =
        auth.isStaff || (isOwner && incident.status == IncidentStatus.submitted);
    final dateFormat = DateFormat('d MMM y, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete report',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    categoryIcon(incident.category),
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.title,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(incident.category.label),
                      const SizedBox(height: 6),
                      StatusChip(status: incident.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: incident.location,
            ),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text: 'Submitted ${dateFormat.format(incident.createdAt)}',
            ),
            _InfoRow(
              icon: Icons.person_outline,
              text: 'Reported by ${incident.reporterName}',
            ),
            const SizedBox(height: 20),
            Text(
              'Status Timeline',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StatusTimeline(incident: incident),
            const SizedBox(height: 24),
            Text(
              'Description',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(incident.description),
            if (incident.photoUrl != null &&
                incident.photoUrl!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Attached Photo',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  incident.photoUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 100,
                    child: Center(child: Text('Could not load the photo.')),
                  ),
                ),
              ),
            ],
            if (auth.isStaff) ...[
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'Staff: update status',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_updating)
                      const Center(child: CircularProgressIndicator())
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: IncidentStatus.values.map((status) {
                          return ChoiceChip(
                            label: Text(status.label),
                            selected: incident.status == status,
                            onSelected: incident.status == status
                                ? null
                                : (_) => _changeStatus(status),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}