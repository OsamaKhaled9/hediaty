class User {
  final String id;
  final String name;
  final String email;
  final String profilePictureUrl;

  User({required this.id, required this.name, required this.email, required this.profilePictureUrl});

  // From Firestore
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
