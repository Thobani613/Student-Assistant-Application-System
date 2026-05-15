import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/application_model.dart';
import 'status_badge.dart';

class ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onTap;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: const Icon(Icons.description_outlined,
              color: AppTheme.primaryColor),
        ),
        title: Text(
          application.module1Name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(application.module1Level,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            if (application.module2Name != null)
              Text('+  ${application.module2Name}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: StatusBadge(status: application.status),
      ),
    );
  }
}
