import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/presentation/providers/browse_jobs_provider.dart';
import 'package:recruitify/presentation/screens/candidate/job_detail_screen.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class BrowseJobsScreen extends ConsumerWidget {
  const BrowseJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(browseJobsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Browse Jobs'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: jobsAsync.when(
        data: (jobs) => jobs.isEmpty
            ? const Center(child: Text('No open jobs right now - check back later'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
                        );
                      },
                      title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${job.location} • ${job.jobType} • ${job.salaryRange}'),
                      trailing: const Icon(Icons.chevron_right),
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
