import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get ratings by product ID (Stream - real-time)
  Stream<List<RatingModel>> getRatingsByProductId(String productId) {
    return _firestore
        .collection('ratings')
        .where('produkId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RatingModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get ratings by user ID (Stream - real-time)
  Stream<List<RatingModel>> getRatingsByUserId(String userId) {
    return _firestore
        .collection('ratings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RatingModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get single rating by ID
  Future<RatingModel?> getRatingById(String ratingId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('ratings')
          .doc(ratingId)
          .get();

      if (doc.exists) {
        return RatingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting rating: $e');
      return null;
    }
  }

  // Add new rating
  Future<String?> addRating(RatingModel rating) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('ratings')
          .add(rating.toFirestore());

      return docRef.id;
    } catch (e) {
      print('Error adding rating: $e');
      throw 'Gagal menambahkan rating. Silakan coba lagi.';
    }
  }

  // Update rating
  Future<void> updateRating(String ratingId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('ratings').doc(ratingId).update(data);
    } catch (e) {
      print('Error updating rating: $e');
      throw 'Gagal mengupdate rating. Silakan coba lagi.';
    }
  }

  // Delete rating
  Future<void> deleteRating(String ratingId) async {
    try {
      await _firestore.collection('ratings').doc(ratingId).delete();
    } catch (e) {
      print('Error deleting rating: $e');
      throw 'Gagal menghapus rating. Silakan coba lagi.';
    }
  }

  // Calculate average rating for a product
  Future<double> getAverageRating(String productId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ratings')
          .where('produkId', isEqualTo: productId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      List<RatingModel> ratings = snapshot.docs
          .map((doc) => RatingModel.fromFirestore(doc))
          .toList();

      double total = ratings.fold(0.0, (sum, rating) => sum + rating.rating);
      return total / ratings.length;
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0.0;
    }
  }

  // Check if user has already reviewed a product
  Future<bool> hasUserReviewedProduct(String userId, String productId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: userId)
          .where('produkId', isEqualTo: productId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user reviewed product: $e');
      return false;
    }
  }
}
