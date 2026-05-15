/*
 * Student Numbers: 224081110, 222001607, 222000452, 224065010, 221024286, 224067603, 224054263, 221046289, 222088478, 224013987
 * Student Names: M Lesenyeho, M Machedi, Z Sidamba, B Nakupi, H Sekethwayo, J O Molaba, K Semela, N Gumede, T Mjiyakho, K D Selebalo
 * Question: Splash Screen
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant_app/core/router/app_router.dart';
import 'package:student_assistant_app/core/theme/app_theme.dart';
import 'package:student_assistant_app/viewmodels/auth_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authVM = context.read<AuthViewModel>();
    await authVM.checkSession();

    if (!mounted) return;

    if (authVM.isAuthenticated) {
      final profile = authVM.currentProfile!;
      if (profile.isAdmin) {
        Navigator.pushReplacementNamed(context, AppRouter.adminDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.studentHome);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.school, size: 60, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 24),
            const Text(
              'Student Assistant\nApplication System',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
