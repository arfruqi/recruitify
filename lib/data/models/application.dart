class Application {
  final String id;
  final String jobId;
  final String candidateId;
  final String resumePath;
  final double? aiScore;
  final String status;
  final String? jobTitle;
  final String? jobLocation;

  Application({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.resumePath,
    this.aiScore,
    required this.status,
    this.jobTitle,
    this.jobLocation,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    // 'jobs' shows up here only if the query asked for it via an embedded
    // join (see fetchMyApplications) - it's the related job row, nested
    // inside this application's json.
    final jobData = json['jobs'];
    return Application(
      id: json['id'],
      jobId: json['job_id'],
      candidateId: json['candidate_id'],
      resumePath: json['resume_url'],
      aiScore: json['ai_score'] != null ? (json['ai_score'] as num).toDouble() : null,
      status: json['status'],
      jobTitle: jobData != null ? jobData['title'] : null,
      jobLocation: jobData != null ? jobData['location'] : null,
    );
  }
}