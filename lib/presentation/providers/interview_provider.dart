import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/data/models/interview.dart';

// All questions for a given job - shared by every candidate who applies.
final interviewQuestionsForJobProvider = FutureProvider.family<List<InterviewQuestion>, String>((ref, jobId) async {
  final response = await Supabase.instance.client
      .from('interview_questions')
      .select()
      .eq('job_id', jobId)
      .order('id');

  return response.map((item) => InterviewQuestion.fromJson(item)).toList();
});

// This candidate's own answers for one specific application (if any exist yet).
final interviewAnswersForApplicationProvider = FutureProvider.family<List<InterviewAnswer>, String>((ref, applicationId) async {
  final response = await Supabase.instance.client
      .from('interview_answers')
      .select()
      .eq('application_id', applicationId);

  return response.map((item) => InterviewAnswer.fromJson(item)).toList();
});

class InterviewAnswerService {
  // Saves/updates answers for a set of questions in one go. Uses upsert per
  // row - same "insert if new, update if it already exists" idea from the
  // profile screens, just applied per-question instead of per-profile.
  Future<void> submitAnswers({
    required String applicationId,
    required Map<String, String> answersByQuestionId,
  }) async {
    final rows = answersByQuestionId.entries
        .map((entry) => {
              'application_id': applicationId,
              'question_id': entry.key,
              'answer_text': entry.value,
            })
        .toList();

    await Supabase.instance.client.from('interview_answers').upsert(
          rows,
          onConflict: 'application_id,question_id',
        );
  }
}

final interviewAnswerServiceProvider = Provider<InterviewAnswerService>((ref) => InterviewAnswerService());
