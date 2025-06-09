import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl; // Add this for product images

  Product({
    required this.id,
    required this.price,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  // Convert a Product object to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      // 'id' is typically the document ID in Firestore, not stored in the map
    };
  }

  // Create a Product object from a Firestore DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id, // The document ID is the product ID
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(), // Ensure double type
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
