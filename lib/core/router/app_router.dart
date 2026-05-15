/*
 * Student Numbers: 224081110, 222001607, 222000452, 224065010, 221024286, 224067603, 224054263, 221046289, 222088478, 224013987
 * Student Names: M Lesenyeho, M Machedi, Z Sidamba, B Nakupi, H Sekethwayo, J O Molaba, K Semela, N Gumede, T Mjiyakho, K D Selebalo 
 * Question: App Router / Navigation
 */

import 'package:flutter/material.dart';
import 'package:student_assistant_app/views/widgets/splash_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/student/home_screen.dart';
import '../../views/student/application_form_screen.dart';
import '../../views/student/application_detail_screen.dart';
import '../../views/admin/admin_dashboard_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String studentHome = '/student/home';
  static const String applicationForm = '/student/application-form';
  static const String applicationDetail = '/student/application-detail';
  static const String adminDashboard = '/admin/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case studentHome:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case applicationForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ApplicationFormScreen(existingApplication: args),
        );

      case applicationDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ApplicationDetailScreen(application: args),
        );

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }
}