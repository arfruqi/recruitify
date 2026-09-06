import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/presentation/providers/job_provider.dart';
import 'package:recruitify/presentation/screens/recruiter/post_job_screen.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class MyJobsScreen extends ConsumerWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('My Job Postings'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostJobScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: jobsAsync.when(
        data: (jobs) => jobs.isEmpty
            ? const Center(child: Text('No jobs posted yet - tap + to post one'))
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
                          MaterialPageRoute(builder: (context) => PostJobScreen(existingJob: job)),
                        );
                      },
                      title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${job.location} • ${job.jobType} • ${job.status}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.grey[500]),
                        onPressed: () {
                          ref.read(jobProvider.notifier).deleteJob(job.id);
                        },
                      ),
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
