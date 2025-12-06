import 'package:cloud_firestore/cloud_firestore.dart';

class PesananModel {
  final String id;
  final String userId;
  final String produkId;
  final int jumlah;
  final int totalHarga;
  final String status;
  final String tanggal;
  final String alamatPengiriman;

  PesananModel({
    required this.id,
    required this.userId,
    required this.produkId,
    required this.jumlah,
    required this.totalHarga,
    required this.status,
    required this.tanggal,
    required this.alamatPengiriman,
  });

  // Convert from Firestore document
  factory PesananModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PesananModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      produkId: data['produkId'] ?? '',
      jumlah: data['jumlah'] ?? 0,
      totalHarga: data['totalHarga'] ?? 0,
      status: data['status'] ?? '',
      tanggal: data['tanggal'] ?? '',
      alamatPengiriman: data['alamatPengiriman'] ?? '',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'produkId': produkId,
      'jumlah': jumlah,
      'totalHarga': totalHarga,
      'status': status,
      'tanggal': tanggal,
      'alamatPengiriman': alamatPengiriman,
    };
  }

  // Convert to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'produkId': produkId,
      'jumlah': jumlah,
      'totalHarga': totalHarga,
      'status': status,
      'tanggal': tanggal,
      'alamatPengiriman': alamatPengiriman,
    };
  }
}
