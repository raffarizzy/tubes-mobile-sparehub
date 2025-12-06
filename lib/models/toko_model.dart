import 'package:cloud_firestore/cloud_firestore.dart';

class TokoModel {
  final String id;
  final String namaToko;
  final String pemilikId;
  final String deskripsi;
  final String logoPath;
  final String lokasi;

  TokoModel({
    required this.id,
    required this.namaToko,
    required this.pemilikId,
    required this.deskripsi,
    required this.logoPath,
    required this.lokasi,
  });

  // Convert from Firestore document
  factory TokoModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TokoModel(
      id: doc.id,
      namaToko: data['namaToko'] ?? '',
      pemilikId: data['pemilikId'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      logoPath: data['logoPath'] ?? '',
      lokasi: data['lokasi'] ?? '',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'namaToko': namaToko,
      'pemilikId': pemilikId,
      'deskripsi': deskripsi,
      'logoPath': logoPath,
      'lokasi': lokasi,
    };
  }

  // Convert to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaToko': namaToko,
      'pemilikId': pemilikId,
      'deskripsi': deskripsi,
      'logoPath': logoPath,
      'lokasi': lokasi,
    };
  }
}
