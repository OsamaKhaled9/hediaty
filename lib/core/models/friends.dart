class Friend {
  final String id;
  final String name;
  final String profilePictureUrl;
  final List<String> events; // Store event IDs

  Friend({required this.id, required this.name, required this.profilePictureUrl, required this.events});

  factory Friend.fromMap(Map<String, dynamic> data) {
    return Friend(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      events: List<String>.from(data['events'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'events': events,
    };
  }
}
