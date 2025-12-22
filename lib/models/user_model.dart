import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nama;
  final String email;
  final String? imagePath;

  // ===== FIELD BARU =====
  final String? phone;
  final String? gender;
  final DateTime? birthDate;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.imagePath,
    this.phone,
    this.gender,
    this.birthDate,
  });

  // ===== COPY WITH =====
  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? imagePath,
    String? phone,
    String? gender,
    DateTime? birthDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  // ===== FROM FIRESTORE =====
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      imagePath: data['imagePath'],
      phone: data['phone'],
      gender: data['gender'],
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
    );
  }

  // ===== TO FIRESTORE =====
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'email': email,
      'imagePath': imagePath ?? 'assets/images/profile1.png',
      'phone': phone,
      'gender': gender,
      'birthDate': birthDate != null
          ? Timestamp.fromDate(birthDate!)
          : null,
    };
  }

  // ===== TO MAP (OPTIONAL) =====
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'imagePath': imagePath ?? 'assets/images/profile1.png',
      'phone': phone,
      'gender': gender,
      'birthDate': birthDate?.toIso8601String(),
    };
  }
}