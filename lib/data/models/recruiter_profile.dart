class RecruiterProfile {
  final String id;
  final String? businessName;
  final String? location;

  RecruiterProfile({
    required this.id,
    this.businessName,
    this.location,
  });

  factory RecruiterProfile.fromJson(Map<String, dynamic> json) {
    return RecruiterProfile(
      id: json['id'],
      businessName: json['business_name'],
      location: json['location'],
    );
  }
}
