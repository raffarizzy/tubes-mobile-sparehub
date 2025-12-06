import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nama;
  final String email;
  final String alamat;
  final String? imagePath;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.alamat,
    this.imagePath,
  });

  // Convert from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      alamat: data['alamat'] ?? '',
      imagePath: data['imagePath'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'email': email,
      'alamat': alamat,
      'imagePath': imagePath ?? 'assets/images/profile1.png',
    };
  }

  // Convert to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'alamat': alamat,
      'imagePath': imagePath ?? 'assets/images/profile1.png',
    };
  }
}
