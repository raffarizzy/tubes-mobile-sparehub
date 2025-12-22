import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream untuk auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register dengan email dan password
  Future<UserModel?> registerWithEmailPassword({
    required String email,
    required String password,
    required String nama,
  }) async {
    try {
      // Create user di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Buat user model
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        nama: nama,
        email: email,
        imagePath: 'assets/images/profile1.png',
      );

      // Simpan user data ke Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toFirestore());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // Login dengan email dan password
  Future<UserModel?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Login di Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data dari Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data dari Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar!';
      case 'invalid-email':
        return 'Format email tidak valid!';
      case 'weak-password':
        return 'Password terlalu lemah! Minimal 6 karakter.';
      case 'user-not-found':
        return 'Email tidak terdaftar!';
      case 'wrong-password':
        return 'Password salah!';
      case 'invalid-credential':
        return 'Email atau password salah!';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}