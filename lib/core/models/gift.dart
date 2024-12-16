import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status; // Status like 'Available', 'Pledged', 'Purchased', etc.
  final String eventId;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.eventId,
  });

  // Convert Gift object to Map for Firestore or local database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
    };
  }

  // Convert Map to Gift object for fetching from Firestore or local database
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Available',
      eventId: map['eventId'] ?? '',
    );
  }

  // Create Gift object from Firestore DocumentSnapshot
  factory Gift.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Gift(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'Available',
      eventId: data['eventId'] ?? '',
    );
  }

  // Create a copy of the Gift object with updated fields
  Gift copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? status,
    String? eventId,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
    );
  }
}
