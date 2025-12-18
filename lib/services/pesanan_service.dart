import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pesanan_model.dart';

class PesananService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'pesanans';

  // Get all pesanans by user ID (Stream - real-time)
  Stream<List<PesananModel>> getPesanansByUserId(String userId) {
    return _firestore
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PesananModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get pesanan by ID
  Future<PesananModel?> getPesananById(String pesananId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(pesananId)
          .get();

      if (doc.exists) {
        return PesananModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting pesanan: $e');
      return null;
    }
  }

  // Add new pesanan
  Future<String?> addPesanan(PesananModel pesanan) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(collectionName)
          .add(pesanan.toFirestore());

      return docRef.id;
    } catch (e) {
      print('Error adding pesanan: $e');
      throw 'Gagal menambahkan pesanan. Silakan coba lagi.';
    }
  }

  // Update pesanan status
  Future<void> updatePesananStatus(String pesananId, String newStatus) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(pesananId)
          .update({'status': newStatus});
    } catch (e) {
      print('Error updating pesanan status: $e');
      throw 'Gagal mengupdate status pesanan. Silakan coba lagi.';
    }
  }

  // Delete pesanan
  Future<void> deletePesanan(String pesananId) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(pesananId)
          .delete();
    } catch (e) {
      print('Error deleting pesanan: $e');
      throw 'Gagal menghapus pesanan. Silakan coba lagi.';
    }
  }
}