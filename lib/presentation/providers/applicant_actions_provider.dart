import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/data/models/application.dart';
import 'package:recruitify/presentation/providers/notification_provider.dart';

class ApplicantActionsService {
  Future<void> updateStatus(Application application, String newStatus) async {
    await Supabase.instance.client
        .from('applications')
        .update({'status': newStatus})
        .eq('id', application.id);

    final jobLabel = application.jobTitle ?? 'the position';
    await createNotification(
      candidateId: application.candidateId,
      applicationId: application.id,
      type: 'status_update',
      message: 'Your application for $jobLabel was $newStatus.',
    );
  }

  Future<void> scheduleInterview(Application application, DateTime interviewDateTime) async {
    await Supabase.instance.client
        .from('applications')
        .update({'interview_at': interviewDateTime.toIso8601String()})
        .eq('id', application.id);

    final jobLabel = application.jobTitle ?? 'the position';
    final formatted =
        '${interviewDateTime.day}/${interviewDateTime.month}/${interviewDateTime.year} at '
        '${interviewDateTime.hour.toString().padLeft(2, '0')}:${interviewDateTime.minute.toString().padLeft(2, '0')}';

    await createNotification(
      candidateId: application.candidateId,
      applicationId: application.id,
      type: 'interview_scheduled',
      message: 'An interview for $jobLabel has been scheduled for $formatted.',
    );
  }
}

final applicantActionsProvider = Provider<ApplicantActionsService>((ref) => ApplicantActionsService());
