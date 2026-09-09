import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/presentation/providers/application_provider.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'shortlisted':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey; // 'applied'
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(applicationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: applicationsAsync.when(
        data: (applications) => applications.isEmpty
            ? const Center(child: Text('No applications yet - go browse some jobs!'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                app.jobTitle ?? 'Job no longer available',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(app.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                app.status,
                                style: TextStyle(color: _statusColor(app.status), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        if (app.jobLocation != null) ...[
                          const SizedBox(height: 4),
                          Text(app.jobLocation!, style: const TextStyle(color: Colors.grey)),
                        ],
                        if (app.aiScore != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'AI Match: ${app.aiScore!.toStringAsFixed(0)}%',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
