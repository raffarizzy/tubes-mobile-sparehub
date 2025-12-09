import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/toko_model.dart';

class TokoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all tokos (Stream - real-time)
  Stream<List<TokoModel>> getAllTokos() {
    return _firestore.collection('tokos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TokoModel.fromFirestore(doc)).toList();
    });
  }

  // Get toko by ID (Future - one-time fetch)
  Future<TokoModel?> getTokoById(String tokoId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('tokos')
          .doc(tokoId)
          .get();

      if (doc.exists) {
        return TokoModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting toko: $e');
      return null;
    }
  }

  // Get tokos by pemilik ID (Stream - real-time)
  Stream<List<TokoModel>> getTokosByPemilikId(String pemilikId) {
    return _firestore
        .collection('tokos')
        .where('pemilikId', isEqualTo: pemilikId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TokoModel.fromFirestore(doc))
              .toList();
        });
  }

  // Add new toko
  Future<String?> addToko(TokoModel toko) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('tokos')
          .add(toko.toFirestore());

      return docRef.id;
    } catch (e) {
      print('Error adding toko: $e');
      throw 'Gagal menambahkan toko. Silakan coba lagi.';
    }
  }

  // Update toko
  Future<void> updateToko(String tokoId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('tokos').doc(tokoId).update(data);
    } catch (e) {
      print('Error updating toko: $e');
      throw 'Gagal mengupdate toko. Silakan coba lagi.';
    }
  }

  // Delete toko
  Future<void> deleteToko(String tokoId) async {
    try {
      await _firestore.collection('tokos').doc(tokoId).delete();
    } catch (e) {
      print('Error deleting toko: $e');
      throw 'Gagal menghapus toko. Silakan coba lagi.';
    }
  }
}
