import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/data/models/application.dart';
import 'package:recruitify/presentation/providers/interview_provider.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  final Application application;
  const InterviewScreen({super.key, required this.application});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final Map<String, TextEditingController> controllers = {};
  bool isSubmitting = false;
  bool controllersInitialized = false;

  // Questions and any previously-saved answers both arrive asynchronously.
  // This builds one controller per question, pre-filled with an existing
  // answer if the candidate already started/finished this interview before.
  void _initControllers(List<dynamic> questions, List<dynamic> existingAnswers) {
    if (controllersInitialized) return;
    for (final q in questions) {
      final existing = existingAnswers.where((a) => a.questionId == q.id);
      controllers[q.id] = TextEditingController(
        text: existing.isNotEmpty ? existing.first.answerText : '',
      );
    }
    controllersInitialized = true;
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => isSubmitting = true);
    try {
      final answersByQuestionId = {
        for (final entry in controllers.entries) entry.key: entry.value.text.trim(),
      };
      await ref.read(interviewAnswerServiceProvider).submitAnswers(
            applicationId: widget.application.id,
            answersByQuestionId: answersByQuestionId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Answers submitted')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(interviewQuestionsForJobProvider(widget.application.jobId));
    final answersAsync = ref.watch(interviewAnswersForApplicationProvider(widget.application.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Interview Questions'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: questionsAsync.when(
        data: (questions) => answersAsync.when(
          data: (existingAnswers) {
            if (questions.isEmpty) {
              return const Center(child: Text('No interview questions available for this job yet.'));
            }
            _initControllers(questions, existingAnswers);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < questions.length; i++) ...[
                    Text(
                      'Q${i + 1}. ${questions[i].questionText}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controllers[questions[i].id],
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Your answer...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isSubmitting ? null : _submit,
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Submit Answers'),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
