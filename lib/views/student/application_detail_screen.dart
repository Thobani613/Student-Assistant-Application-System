// ignore_for_file: deprecated_member_use

/*
 * Student Numbers: 224081110, 222001607, 222000452, 224065010, 221024286, 224067603, 224054263, 221046289, 222088478, 224013987
 * Student Names: M Lesenyeho, M Machedi, Z Sidamba, B Nakupi, H Sekethwayo, J O Molaba, K Semela, N Gumede, T Mjiyakho, K D Selebalo
 * Question: Application Detail Screen (Read / Delete)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/application_model.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final app = application['application'] as ApplicationModel;
    final bool isPending = app.status == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          if (isPending)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.pushNamed(
                    context,
                    AppRouter.applicationForm,
                    arguments: {'application': app},
                  );
                } else if (value == 'delete') {
                  _confirmDelete(context, app);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit Application')),
                PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _statusBgColor(app.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(_statusIcon(app.status),
                      size: 40, color: _statusColor(app.status)),
                  const SizedBox(height: 8),
                  Text(
                    app.status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _statusColor(app.status)),
                  ),
                  if (!isPending)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'You can no longer edit this application.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _DetailCard(
              title: 'Personal Information',
              rows: [
                _Row('Full Name', app.studentName),
                _Row('Student Number', app.studentNumber),
                _Row('Year of Study', 'Year ${app.yearOfStudy}'),
              ],
            ),
            const SizedBox(height: 12),

            _DetailCard(
              title: 'Module 1',
              rows: [
                _Row('Level', app.module1Level),
                _Row('Module', app.module1Name),
              ],
            ),
            const SizedBox(height: 12),

            if (app.module2Name != null) ...[
              _DetailCard(
                title: 'Module 2',
                rows: [
                  _Row('Level', app.module2Level ?? ''),
                  _Row('Module', app.module2Name!),
                ],
              ),
              const SizedBox(height: 12),
            ],

            _DetailCard(
              title: 'Eligibility',
              rows: [
                _Row(
                  'Meets Minimum Requirements',
                  app.meetsMinimumRequirements ? 'Yes ✓' : 'No ✗',
                ),
                if (app.documentUrl != null)
                  const _Row('Supporting Document', 'Uploaded ✓'),
              ],
            ),
            const SizedBox(height: 12),

            _DetailCard(
              title: 'Submission Details',
              rows: [
                if (app.createdAt != null)
                  _Row('Submitted',
                      '${app.createdAt!.day}/${app.createdAt!.month}/${app.createdAt!.year}'),
                if (app.updatedAt != null)
                  _Row('Last Updated',
                      '${app.updatedAt!.day}/${app.updatedAt!.month}/${app.updatedAt!.year}'),
              ],
            ),

            if (isPending) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _confirmDelete(context, app),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Application'),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  Color _statusBgColor(String status) {
    return _statusColor(status).withOpacity(0.1);
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }

  void _confirmDelete(BuildContext context, ApplicationModel app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text(
            'Are you sure you want to delete this application? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<ApplicationViewModel>()
                  .deleteApplication(app.id!);
              if (context.mounted) {
                if (success) {
                  Navigator.pop(context); // go back to home
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Application deleted.'),
                      backgroundColor: AppTheme.successColor));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Row {
  final String label;
  final String value;
  const _Row(this.label, this.value);
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<_Row> rows;

  const _DetailCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.primaryColor)),
            const Divider(height: 16),
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(row.label,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      Text(row.value,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
