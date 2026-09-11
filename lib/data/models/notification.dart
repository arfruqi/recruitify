class AppNotification {
  final String id;
  final String candidateId;
  final String? applicationId;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.candidateId,
    this.applicationId,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      candidateId: json['candidate_id'],
      applicationId: json['application_id'],
      type: json['type'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
