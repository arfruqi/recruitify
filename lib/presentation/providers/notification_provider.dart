import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:recruitify/data/models/notification.dart';

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    return await fetchMyNotifications();
  }

  Future<List<AppNotification>> fetchMyNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    final response = await Supabase.instance.client
        .from('notifications')
        .select()
        .eq('candidate_id', user.id)
        .order('created_at', ascending: false);

    return response.map((item) => AppNotification.fromJson(item)).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await Supabase.instance.client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);

    state = AsyncValue.data(await fetchMyNotifications());
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(NotificationNotifier.new);

// Shared helper - called from the RECRUITER side (applicant actions) to
// create a notification FOR a candidate. Not part of the Notifier above,
// since the recruiter doesn't have a candidate's notification list loaded -
// this just does a one-off insert.
Future<void> createNotification({
  required String candidateId,
  required String applicationId,
  required String type,
  required String message,
}) async {
  await Supabase.instance.client.from('notifications').insert({
    'candidate_id': candidateId,
    'application_id': applicationId,
    'type': type,
    'message': message,
    'is_read': false,
  });
}
