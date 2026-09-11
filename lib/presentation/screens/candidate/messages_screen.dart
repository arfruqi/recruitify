import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recruitify/presentation/providers/notification_provider.dart';
import 'package:recruitify/presentation/theme/app_colors.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'interview_scheduled':
        return Icons.calendar_today;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: notificationsAsync.when(
        data: (notifications) => notifications.isEmpty
            ? const Center(child: Text('No messages yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: notification.isRead
                          ? null
                          : Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Icon(_iconFor(notification.type), color: accentColor),
                      title: Text(
                        notification.message,
                        style: TextStyle(
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(_timeAgo(notification.createdAt)),
                      onTap: () {
                        if (!notification.isRead) {
                          ref.read(notificationProvider.notifier).markAsRead(notification.id);
                        }
                      },
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
