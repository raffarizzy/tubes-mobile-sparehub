import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_sparehub/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'users';

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(collectionName)
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Stream user by ID (real-time)
  Stream<UserModel?> streamUserById(String userId) {
    return _firestore.collection(collectionName).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Update user alamat (lokasi)
  Future<void> updateUserAlamat(String userId, String alamat) async {
    try {
      await _firestore.collection(collectionName).doc(userId).update({
        'alamat': alamat,
      });
    } catch (e) {
      print('Error updating user alamat: $e');
      rethrow;
    }
  }

  // Update entire user data
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).doc(userId).update(data);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Create new user
  Future<void> createUser(String userId, UserModel user) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(userId)
          .set(user.toFirestore());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Update foto profil user
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _firestore.collection(collectionName).doc(userId).update({
        'imagePath': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(), // opsional
      });
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    }
  }
}
