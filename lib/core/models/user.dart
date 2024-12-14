class user {
  String id;
  String fullName;
  String email;
  String phoneNumber;  // Make sure this is included
  String profilePictureUrl;
  String passwordHash;  // Add passwordHash field for storing hashed password

  user({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profilePictureUrl,
    required this.passwordHash,
  });

  // Convert the user model to a Map for Firestore and SQLite insertion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,  // Add this to ensure it's stored
      'profilePictureUrl': profilePictureUrl,
      'passwordHash': passwordHash,  // Add password hash to the map
    };
  }


  // You can also create a fromJson method for serialization
  factory user.fromJson(Map<String, dynamic> json) {
    return user(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePictureUrl: json['profilePictureUrl'],
      passwordHash: json['passwordHash'],  // Add password hash to the constructor arguments
    );
  }
}
