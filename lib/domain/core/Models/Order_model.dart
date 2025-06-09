// File: domain/core/Models/order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Represents an individual order item within an order
class OrderItem {
  final String name;
  final int quantity;
  final double price;

  // Simplified constructor
  OrderItem({required this.name, required this.quantity, required this.price});

  // Simplified factory constructor to create an OrderItem from a Map (parsed from Firestore)
  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
    name: map['name'] ?? 'Unknown Item',
    quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
  );

  // Simplified helper method to generate a display string for the item
  String toDisplayString() => '${quantity} x ${name}';
}

// Represents an entire order
class Order {
  final String id; // Document ID from Firestore
  final String tableNumber;
  final String status;
  final String paymentstatus;
  final double totalAmount;
  final Timestamp timestamp;
  final String? paymentProofUrl; // Nullable
  final List<OrderItem> items; // List of OrderItem objects

  Order({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.paymentstatus,
    required this.totalAmount,
    required this.timestamp,
    required this.paymentProofUrl,
    required this.items,
  });

  // Factory constructor to create an Order from a Firestore DocumentSnapshot
  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id, // Get the document ID from the snapshot
      tableNumber: data['tableNumber'] ?? 'N/A',
      status: data['status'] ?? 'unknown',
      paymentstatus: data['paymentstatus'] ?? 'unknown',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      timestamp: data['timestamp'] as Timestamp,
      paymentProofUrl: data['paymentProofUrl'],
      // Map the list of dynamic items to a list of OrderItem objects
      items:
          (data['items'] as List<dynamic>?)
              ?.map(
                (itemMap) => OrderItem.fromMap(itemMap as Map<String, dynamic>),
              )
              .toList() ??
          [], // Provide an empty list if 'items' is null
    );
  }

  // Helper getter for active status
  bool get isActive {
    return status == 'pending' || status == 'preparing';
  }
}
