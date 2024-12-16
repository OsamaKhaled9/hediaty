class Event {
  final String id;
  final String userId;
  final String name;
  final DateTime date;
  final String location;
  final String description;

  Event({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
  });

  // Convert to Map (Firestore format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
    };
  }

  // Safely convert from Firestore Map
 factory Event.fromMap(Map<String, dynamic> map, String fallbackId) {
  return Event(
    id: map['id'] as String? ?? fallbackId,
    userId: map['userId'] as String? ?? '',
    name: map['name'] as String? ?? '',
    date: map['date'] != null
        ? DateTime.parse(map['date'] as String)
        : DateTime.now(),
    location: map['location'] as String? ?? 'Unknown location',
    description: map['description'] as String? ?? '',
  );
}



}
