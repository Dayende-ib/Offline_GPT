class UserProfile {
  final String id;
  final String fullName;
  final String email;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
