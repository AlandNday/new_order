class Profile {
  final String id; // This will typically be the Firebase Auth UID
  final String email;
  final String? name;
  final String? avatarUrl;
  final String role; // <--- This is now a String
  final DateTime? createdAt;

  Profile({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.role,
    this.createdAt,
  });

  // Factory constructor to create a Profile instance from a JSON map (e.g., from Firestore)
  factory Profile.fromJson(Map<String, dynamic> json, String id) {
    return Profile(
      id: id,
      email: json['email'] ?? '',
      name: json['name'],
      avatarUrl: json['avatarurl'],
      role:
          json['role'] as String? ??
          'normal', // <--- Directly cast to String, default to 'normal'
      createdAt: (json['createdAt'] != null)
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  // Converts the Profile instance to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role, // <--- Directly use the String value
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
