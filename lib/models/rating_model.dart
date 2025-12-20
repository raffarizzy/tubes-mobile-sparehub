import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String produkId;
  final String userId;
  final String userName;
  final int rating;
  final String komentar;
  final String tanggal;

  RatingModel({
    required this.id,
    required this.produkId,
    required this.userId,
    this.userName = 'Anonymous', // Default value if not provided
    required this.rating,
    required this.komentar,
    required this.tanggal,
  });

  // Convert from Firestore document
  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      produkId: data['produkId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      rating: data['rating'] ?? 0,
      komentar: data['komentar'] ?? '',
      tanggal: data['tanggal'] ?? '',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'produkId': produkId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'komentar': komentar,
      'tanggal': tanggal,
    };
  }

  // Convert to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produkId': produkId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'komentar': komentar,
      'tanggal': tanggal,
    };
  }
}
