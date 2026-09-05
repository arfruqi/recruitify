class Profile {
  final String id;
  final String role;
  final String fullName;
  final String email;
  final String? phone;

  Profile({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    this.phone,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      role: json['role'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
