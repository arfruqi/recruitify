class CandidateProfile {
  final String id;
  final String? education;
  final String? fieldOfInterest;
  final String? jobPreferences;
  final List<String> skills;

  CandidateProfile({
    required this.id,
    this.education,
    this.fieldOfInterest,
    this.jobPreferences,
    this.skills = const [],
  });

  factory CandidateProfile.fromJson(Map<String, dynamic> json) {
    return CandidateProfile(
      id: json['id'],
      education: json['education'],
      fieldOfInterest: json['field_of_interest'],
      jobPreferences: json['job_preferences'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
    );
  }
}
