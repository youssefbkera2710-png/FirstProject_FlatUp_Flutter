class ChatUser {
  final int id;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String role;

  ChatUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.role,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profileImageUrl: json['profile_image_url'],
      role: json['role'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}
