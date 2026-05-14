// ignore_for_file: deprecated_member_use

/*
 * Student Numbers: 224081110, 222001607, 222000452, 224065010, 221024286, 224067603, 224054263, 221046289, 222088478, 224013987
 * Student Names: M Lesenyeho, M Machedi, Z Sidamba, B Nakupi, H Sekethwayo, J O Molaba, K Semela, N Gumede, T Mjiyakho, K D Selebalo 
 * Question: Admin Dashboard (Read / Update / Delete Operations)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../models/application_model.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/status_badge.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadAllApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminVM.loadAllApplications(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.logout();
              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, AppRouter.login);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatCard(
                  count: adminVM.pendingCount,
                  label: 'Pending',
                  color: AppTheme.warningColor,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  count: adminVM.approvedCount,
                  label: 'Approved',
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  count: adminVM.rejectedCount,
                  label: 'Rejected',
                  color: AppTheme.errorColor,
                ),
              ],
            ),
          ),

          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['all', 'pending', 'approved', 'rejected']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          filter[0].toUpperCase() + filter.substring(1),
                        ),
                        selected: adminVM.currentFilter == filter,
                        selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                        checkmarkColor: AppTheme.primaryColor,
                        onSelected: (_) => adminVM.setFilter(filter),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Applications list
          Expanded(
            child: adminVM.state == AdminViewState.loading
                ? const Center(child: CircularProgressIndicator())
                : adminVM.filteredApplications.isEmpty
                ? const Center(child: Text('No applications found'))
                : RefreshIndicator(
                    onRefresh: adminVM.loadAllApplications,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: adminVM.filteredApplications.length,
                      itemBuilder: (context, index) {
                        final app = adminVM.filteredApplications[index];
                        return _AdminApplicationTile(
                          app: app,
                          adminVM: adminVM,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AdminApplicationTile extends StatelessWidget {
  final ApplicationModel app;
  final AdminViewModel adminVM;

  const _AdminApplicationTile({required this.app, required this.adminVM});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            app.studentName.isNotEmpty ? app.studentName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          app.studentName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          app.studentNumber,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: StatusBadge(status: app.status),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _InfoRow('Year of Study', 'Year ${app.yearOfStudy}'),
                _InfoRow(
                  'Module 1',
                  '${app.module1Level} – ${app.module1Name}',
                ),
                if (app.module2Name != null)
                  _InfoRow(
                    'Module 2',
                    '${app.module2Level} – ${app.module2Name}',
                  ),
                _InfoRow(
                  'Meets Requirements',
                  app.meetsMinimumRequirements ? 'Yes ✓' : 'No ✗',
                ),
                if (app.documentUrl != null)
                  const _InfoRow('Document', 'Uploaded ✓'),
                const SizedBox(height: 12),

                // Action buttons (only for pending)
                if (app.status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                          onPressed: () async {
                            final ok = await adminVM.approveApplication(
                              app.id!,
                            );
                            if (context.mounted && ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Application approved.'),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                          ),
                          onPressed: () async {
                            final ok = await adminVM.rejectApplication(app.id!);
                            if (context.mounted && ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Application rejected.'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                // Delete (invalid) button
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove Invalid Application'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Application'),
        content: Text(
          'Remove application from ${app.studentName}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await adminVM.deleteApplication(app.id!);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatCard({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    ),
  );
}
