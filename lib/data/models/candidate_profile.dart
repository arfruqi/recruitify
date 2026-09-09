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
    // Defensive parsing: if the 'skills' column is a real Postgres array,
    // Supabase returns a List here. If it was accidentally created as a
    // plain 'text' column instead of 'text[]', it comes back as a single
    // String instead - this handles both without crashing.
    List<String> parsedSkills = [];
    final rawSkills = json['skills'];
    if (rawSkills is List) {
      parsedSkills = List<String>.from(rawSkills);
    } else if (rawSkills is String && rawSkills.isNotEmpty) {
      parsedSkills = rawSkills.split(',').map((s) => s.trim()).toList();
    }

    return CandidateProfile(
      id: json['id'],
      education: json['education'],
      fieldOfInterest: json['field_of_interest'],
      jobPreferences: json['job_preferences'],
      skills: parsedSkills,
    );
  }
}