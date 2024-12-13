class user {
  String id;
  String fullName;
  String email;
  String phoneNumber;
  String profilePictureUrl;  // Remove final to make this mutable
  
  user({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profilePictureUrl,  // This can be updated after initialization
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
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
    );
  }
}
