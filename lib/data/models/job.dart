class Job {
  final String id;
  final String recruiterId;
  final String title;
  final String description;
  final String requirements;
  final String location;
  final String salaryRange;
  final String jobType;
  final String status;

  Job({
    required this.id,
    required this.recruiterId,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    required this.salaryRange,
    required this.jobType,
    required this.status,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      recruiterId: json['recruiter_id'],
      title: json['title'],
      description: json['description'],
      requirements: json['requirements'],
      location: json['location'],
      salaryRange: json['salary_range'],
      jobType: json['job_type'],
      status: json['status'],
    );
  }
}
