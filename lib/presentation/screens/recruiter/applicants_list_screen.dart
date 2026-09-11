import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/data/models/job.dart';
import 'package:recruitify/presentation/providers/applicants_provider.dart';
import 'package:recruitify/presentation/screens/recruiter/applicant_detail_screen.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class ApplicantsListScreen extends ConsumerWidget {
  final Job job;
  const ApplicantsListScreen({super.key, required this.job});

  Color _statusColor(String status) {
    switch (status) {
      case 'shortlisted':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calling the family provider WITH an argument - job.id - is what
    // makes it fetch applicants for THIS specific job.
    final applicantsAsync = ref.watch(applicantsForJobProvider(job.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text('Applicants - ${job.title}'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: applicantsAsync.when(
        data: (applicants) => applicants.isEmpty
            ? const Center(child: Text('No applicants yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: applicants.length,
                itemBuilder: (context, index) {
                  final applicant = applicants[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ApplicantDetailScreen(application: applicant)),
                        );
                      },
                      title: Text(applicant.candidateName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(applicant.candidateEmail ?? ''),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(applicant.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          applicant.status,
                          style: TextStyle(color: _statusColor(applicant.status), fontWeight: FontWeight.w600),
                        ),
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
