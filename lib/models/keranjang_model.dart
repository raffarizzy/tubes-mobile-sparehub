import 'package:cloud_firestore/cloud_firestore.dart';

class KeranjangModel {
  final String id;
  final String userId;
  final String produkId;
  final int jumlah;

  KeranjangModel({
    required this.id,
    required this.userId,
    required this.produkId,
    required this.jumlah,
  });

  // Convert from Firestore document
  factory KeranjangModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KeranjangModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      produkId: data['produkId'] ?? '',
      jumlah: data['jumlah'] ?? 0,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'produkId': produkId,
      'jumlah': jumlah,
    };
  }

  // Convert to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'produkId': produkId,
      'jumlah': jumlah,
    };
  }
}