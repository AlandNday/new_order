// domain/core/Models/Review_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String reviewerName;
  final String reviewText;
  final int starRating;
  final Timestamp? timestamp; // Optional, for ordering reviews

  Review({
    required this.id,
    required this.reviewerName,
    required this.reviewText,
    required this.starRating,
    this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      reviewerName: data['reviewerName'] ?? 'Anonymous',
      reviewText: data['reviewText'] ?? '',
      starRating: data['starRating'] ?? 0,
      timestamp: data['timestamp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reviewerName': reviewerName,
      'reviewText': reviewText,
      'starRating': starRating,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }
}
