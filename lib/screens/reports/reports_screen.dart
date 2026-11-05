import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<IncidentProvider>();
    final theme = Theme.of(context);

    Widget body;
    if (data.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (data.errorMessage != null) {
      body = Center(child: Text(data.errorMessage!));
    } else if (data.incidents.isEmpty) {
      body = const Center(child: Text('No reports yet.'));
    } else {
      body = ListView(
        padding: const EdgeInsets.all(20),
        children: data.incidents
            .map((i) => IncidentCard(incident: i, showReporter: auth.isStaff))
            .toList(),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              auth.isStaff ? 'All Reports' : 'My Reports',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}