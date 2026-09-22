import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:recruitify/data/models/application.dart';
import 'package:recruitify/presentation/providers/applicants_provider.dart';
import 'package:recruitify/presentation/providers/applicant_actions_provider.dart';
import 'package:recruitify/presentation/providers/interview_provider.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class ApplicantDetailScreen extends ConsumerStatefulWidget {
  final Application application;
  const ApplicantDetailScreen({super.key, required this.application});

  @override
  ConsumerState<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends ConsumerState<ApplicantDetailScreen> {
  bool isUpdating = false;

  Future<void> _openResume(BuildContext context) async {
    try {
      final signedUrl = await getResumeSignedUrl(widget.application.resumePath);
      final uri = Uri.parse(signedUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open resume: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => isUpdating = true);
    try {
      await ref.read(applicantActionsProvider).updateStatus(widget.application, newStatus);
      ref.invalidate(applicantsForJobProvider(widget.application.jobId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  Future<void> _scheduleInterview() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null || !mounted) return;

    final interviewDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() => isUpdating = true);
    try {
      await ref.read(applicantActionsProvider).scheduleInterview(widget.application, interviewDateTime);
      ref.invalidate(applicantsForJobProvider(widget.application.jobId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interview scheduled and candidate notified')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value ?? 'Not provided'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(candidateDetailProvider(widget.application.candidateId));
    final questionsAsync = ref.watch(interviewQuestionsForJobProvider(widget.application.jobId));
    final answersAsync = ref.watch(interviewAnswersForApplicationProvider(widget.application.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(widget.application.candidateName ?? 'Applicant'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.application.candidateName ?? 'Unknown', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.application.candidateEmail ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            if (widget.application.aiScore != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: accentColor, size: 18),
                        const SizedBox(width: 6),
                        const Text('AI Match Score', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(
                          '${widget.application.aiScore!.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor),
                        ),
                      ],
                    ),
                    if (widget.application.aiSummary != null && widget.application.aiSummary!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(widget.application.aiSummary!, style: const TextStyle(color: Colors.black87)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openResume(context),
                icon: const Icon(Icons.description),
                label: const Text('View Resume'),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    onPressed: isUpdating ? null : () => _updateStatus('shortlisted'),
                    child: const Text('Shortlist'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: isUpdating ? null : () => _updateStatus('accepted'),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: isUpdating ? null : () => _updateStatus('rejected'),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Interview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (widget.application.interviewAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Scheduled: ${widget.application.interviewAt}'),
              ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isUpdating ? null : _scheduleInterview,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Schedule Interview'),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Interview Responses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            questionsAsync.when(
              data: (questions) => answersAsync.when(
                data: (answers) {
                  if (questions.isEmpty) {
                    return const Text('No interview questions were generated for this job.', style: TextStyle(color: Colors.grey));
                  }
                  if (answers.isEmpty) {
                    return const Text('Candidate has not answered yet.', style: TextStyle(color: Colors.grey));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < questions.length; i++) ...[
                        Text('Q${i + 1}. ${questions[i].questionText}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Builder(builder: (context) {
                          final matching = answers.where((a) => a.questionId == questions[i].id);
                          final answerText = matching.isNotEmpty ? matching.first.answerText : '(not answered)';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(answerText, style: const TextStyle(color: Colors.black87)),
                          );
                        }),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),

            const Text('Candidate Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            profileAsync.when(
              data: (profile) {
                if (profile == null) {
                  return const Text('No additional profile details provided.', style: TextStyle(color: Colors.grey));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Education', profile.education),
                    _detailRow('Field of Interest', profile.fieldOfInterest),
                    _detailRow('Job Preferences', profile.jobPreferences),
                    const SizedBox(height: 8),
                    const Text('Skills', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: profile.skills.map((s) => Chip(label: Text(s))).toList(),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading profile: $error'),
            ),
          ],
        ),
      ),
    );
  }
}