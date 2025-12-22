import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nama;
  final String email;
  final String? imagePath;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.imagePath,
  });

  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? alamat,
    String? imagePath,
  }) {
    return UserModel(
      id : id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
    );
  }


  // Convert from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      imagePath: data['imagePath'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'email': email,
      'imagePath': imagePath ?? 'assets/images/profile1.png',
    };
  }

  // Convert to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'imagePath': imagePath ?? 'assets/images/profile1.png',
    };
  }
}
