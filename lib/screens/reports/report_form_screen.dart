import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/category_selector.dart';
import '../../widgets/primary_button.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  static const List<String> _locations = [
    'Student Residence',
    'Block A',
    'Block B',
    'Block C',
    'Cafeteria',
    'Library',
    'Sports Area',
    'Parking Area',
    'Outdoor Grounds',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  IncidentCategory? _category;
  String? _location;
  bool _categoryError = false;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    if (_category == null) {
      setState(() => _categoryError = true);
    }
    if (!valid || _category == null) return;

    setState(() => _submitting = true);

    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final details = _detailsCtrl.text.trim();
    final location = details.isEmpty ? _location! : '${_location!} – $details';

    final ok = await provider.submitIncident(
      title: _titleCtrl.text,
      description: _descCtrl.text,
      category: _category!,
      location: location,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Report submitted successfully.')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Could not submit your report.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a category',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                CategorySelector(
                  selected: _category,
                  onChanged: (c) => setState(() {
                    _category = c;
                    _categoryError = false;
                  }),
                ),
                if (_categoryError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Please select a category',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  maxLength: 80,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Briefly describe the issue...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.trim().length < 5) {
                      return 'Title is too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText:
                        'What happened, when, and what is the impact?',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe the issue';
                    }
                    if (value.trim().length < 10) {
                      return 'Please give a bit more detail (10+ characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _location,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _locations
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (value) => setState(() => _location = value),
                  validator: (value) =>
                      value == null ? 'Please choose a location' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detailsCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Room or exact spot (optional)',
                    hintText: 'e.g. Room 204',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Submit Report',
                  isLoading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}