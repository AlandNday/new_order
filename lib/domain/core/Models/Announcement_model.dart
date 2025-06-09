import 'package:cloud_firestore/cloud_firestore.dart'; // Import if your timestamp is Firestore Timestamp

class Announcement {
  final String id;
  final String imageUrl;
  final String eventName;
  final String date;
  final String startTime;
  final String description;

  Announcement({
    required this.id,
    required this.imageUrl,
    required this.eventName,
    required this.date,
    required this.startTime,
    required this.description,
  });

  // Factory constructor to create an Announcement from a Firestore DocumentSnapshot
  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '', // Provide default empty string
      eventName: data['eventName'] ?? 'No Event Name',
      date: data['date'] ?? 'No Date',
      // Assuming 'startTime' might be a specific format or 'TBA'
      startTime: data['startTime'] ?? 'TBA',
      description: data['description'] ?? 'No Description',
    );
  }

  // Optional: Convert to JSON for saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'eventName': eventName,
      'date': date,
      'startTime': startTime,
      'description': description,
    };
  }
}
