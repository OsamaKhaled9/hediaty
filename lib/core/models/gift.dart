import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String id;
  final String eventId;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imagePath; // Path to uploaded image
  final String status; // 'Available', 'Pledged', 'Purchased'
  final String? pledgedBy; // User ID of pledger, if any

  Gift({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imagePath,
    required this.status,
    this.pledgedBy,
  });

  // Convert Gift object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imagePath': imagePath,
      'status': status,
      'pledgedBy': pledgedBy,
    };
  }

  // Convert JSON/Map to Gift object
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] ?? '',
      eventId: map['eventId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['imagePath'] ?? '',
      status: map['status'] ?? 'Available',
      pledgedBy: map['pledgedBy'],
    );
  }

  // Convert Firestore DocumentSnapshot to Gift
  factory Gift.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Gift(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imagePath: data['imagePath'] ?? '',
      status: data['status'] ?? 'Available',
      pledgedBy: data['pledgedBy'],
    );
  }

  // Copy method to create a modified version of the Gift object
  Gift copyWith({
    String? id,
    String? eventId,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imagePath,
    String? status,
    String? pledgedBy,
  }) {
    return Gift(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      pledgedBy: pledgedBy ?? this.pledgedBy,
    );
  }
}
