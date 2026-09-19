class Application {
  final String id;
  final String jobId;
  final String candidateId;
  final String resumePath;
  final double? aiScore;
  final String? aiSummary;
  final String status;
  final DateTime? interviewAt;
  final String? jobTitle;
  final String? jobLocation;
  final String? candidateName;
  final String? candidateEmail;

  Application({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.resumePath,
    this.aiScore,
    this.aiSummary,
    required this.status,
    this.interviewAt,
    this.jobTitle,
    this.jobLocation,
    this.candidateName,
    this.candidateEmail,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    final jobData = json['jobs'];
    final profileData = json['profiles'];
    return Application(
      id: json['id'],
      jobId: json['job_id'],
      candidateId: json['candidate_id'],
      resumePath: json['resume_url'],
      aiScore: json['ai_score'] != null ? (json['ai_score'] as num).toDouble() : null,
      aiSummary: json['ai_summary'],
      status: json['status'],
      interviewAt: json['interview_at'] != null ? DateTime.parse(json['interview_at']) : null,
      jobTitle: jobData != null ? jobData['title'] : null,
      jobLocation: jobData != null ? jobData['location'] : null,
      candidateName: profileData != null ? profileData['full_name'] : null,
      candidateEmail: profileData != null ? profileData['email'] : null,
    );
  }
}