import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String nama;
  final int harga;
  final String deskripsi;
  final String imagePath;
  final String tokoId;
  final int stok;
  final double? diskon;
  final String? kategori;
   final String imageUrl;

  ProductModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    required this.imagePath,
    required this.tokoId,
    required this.stok,
    this.diskon,
    this.kategori,
    required this.imageUrl,
  });

  // Convert from Firestore document
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      harga: data['harga'] ?? 0,
      deskripsi: data['deskripsi'] ?? '',
      imagePath: data['imagePath'] ?? '',
      tokoId: data['tokoId'] ?? '',
      stok: data['stok'] ?? 0,
      diskon: data['diskon']?.toDouble(),
      kategori: data['kategori'],
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'harga': harga,
      'deskripsi': deskripsi,
      'imagePath': imagePath,
      'tokoId': tokoId,
      'stok': stok,
      'diskon': diskon,
      'kategori': kategori,
    };
  }

  // Convert to Map (for backward compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'deskripsi': deskripsi,
      'imagePath': imagePath,
      'tokoId': tokoId,
      'stok': stok,
      'diskon': diskon,
      'kategori': kategori,
    };
  }

  ProductModel copyWith({
    String? id,
    String? nama,
    int? harga,
    String? deskripsi,
    String? imagePath,
    String? tokoId,
    int? stok,
    double? diskon,
    String? kategori,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      deskripsi: deskripsi ?? this.deskripsi,
      imagePath: imagePath ?? this.imagePath,
      tokoId: tokoId ?? this.tokoId,
      stok: stok ?? this.stok,
      diskon: diskon ?? this.diskon,
      kategori: kategori ?? this.kategori,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
