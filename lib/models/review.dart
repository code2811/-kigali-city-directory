import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
