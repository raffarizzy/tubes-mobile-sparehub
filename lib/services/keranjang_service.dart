import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/keranjang_model.dart';

class KeranjangService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get keranjang by user ID (Stream - real-time)
  Stream<List<KeranjangModel>> getKeranjangByUserId(String userId) {
    return _firestore
        .collection('keranjangs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => KeranjangModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get single keranjang item by ID
  Future<KeranjangModel?> getKeranjangById(String keranjangId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('keranjangs')
          .doc(keranjangId)
          .get();

      if (doc.exists) {
        return KeranjangModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting keranjang: $e');
      return null;
    }
  }

  // Add item to keranjang
  Future<String?> addToKeranjang(KeranjangModel keranjang) async {
    try {
      // Check if item already exists
      QuerySnapshot existingItems = await _firestore
          .collection('keranjangs')
          .where('userId', isEqualTo: keranjang.userId)
          .where('produkId', isEqualTo: keranjang.produkId)
          .get();

      if (existingItems.docs.isNotEmpty) {
        // Update existing item quantity
        String docId = existingItems.docs.first.id;
        KeranjangModel existing = KeranjangModel.fromFirestore(existingItems.docs.first);

        await _firestore.collection('keranjangs').doc(docId).update({
          'jumlah': existing.jumlah + keranjang.jumlah,
        });

        return docId;
      } else {
        // Add new item
        DocumentReference docRef = await _firestore
            .collection('keranjangs')
            .add(keranjang.toFirestore());

        return docRef.id;
      }
    } catch (e) {
      print('Error adding to keranjang: $e');
      throw 'Gagal menambahkan ke keranjang. Silakan coba lagi.';
    }
  }

  // Update keranjang item
  Future<void> updateKeranjang(String keranjangId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('keranjangs')
          .doc(keranjangId)
          .update(data);
    } catch (e) {
      print('Error updating keranjang: $e');
      throw 'Gagal mengupdate keranjang. Silakan coba lagi.';
    }
  }

  // Delete keranjang item
  Future<void> deleteKeranjang(String keranjangId) async {
    try {
      await _firestore
          .collection('keranjangs')
          .doc(keranjangId)
          .delete();
    } catch (e) {
      print('Error deleting keranjang: $e');
      throw 'Gagal menghapus dari keranjang. Silakan coba lagi.';
    }
  }

  // Clear all keranjang for user
  Future<void> clearKeranjang(String userId) async {
    try {
      QuerySnapshot items = await _firestore
          .collection('keranjangs')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in items.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing keranjang: $e');
      throw 'Gagal mengosongkan keranjang. Silakan coba lagi.';
    }
  }

  // Get total items count in keranjang
  Future<int> getKeranjangItemCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('keranjangs')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting keranjang count: $e');
      return 0;
    }
  }
}