// ignore_for_file: use_build_context_synchronously

/*
 * Student Numbers: 224081110, 222001607, 222000452, 224065010, 221024286, 224067603, 224054263, 221046289, 222088478, 224013987
 * Student Names: M Lesenyeho, M Machedi, Z Sidamba, B Nakupi, H Sekethwayo, J O Molaba, K Semela, N Gumede, T Mjiyakho, K D Selebalo 
 * Question: Student Home Screen (Read Operation)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final userId = context.read<AuthViewModel>().currentProfile?.id;
    if (userId != null) {
      context.read<ApplicationViewModel>().loadApplications(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final appVM = context.watch<ApplicationViewModel>();
    final profile = authVM.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authVM.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRouter.login);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${profile?.fullName.split(' ').first ?? 'Student'} 👋',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile?.studentNumber ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Applications section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Applications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (appVM.state == AppViewState.loading)
                    const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
              const SizedBox(height: 12),

              // Applications list
              if (appVM.state == AppViewState.error)
                _ErrorWidget(message: appVM.errorMessage ?? 'Error loading data')
              else if (appVM.applications.isEmpty &&
                  appVM.state == AppViewState.success)
                _EmptyState(onApply: () => Navigator.pushNamed(
                    context, AppRouter.applicationForm))
              else
                ...appVM.applications.map((app) => ApplicationCard(
                      application: app,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.applicationDetail,
                        arguments: {'application': app},
                      ),
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: appVM.hasExistingApplication
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.applicationForm),
              icon: const Icon(Icons.add),
              label: const Text('Apply Now'),
            ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, style: const TextStyle(color: AppTheme.errorColor)),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onApply;
  const _EmptyState({required this.onApply});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No applications yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Tap Apply Now to submit your first application',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.add),
              label: const Text('Apply Now'),
            ),
          ],
        ),
      );
}
