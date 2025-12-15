import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  static String? get _currentUserId => _auth.currentUser?.uid;

  // Get collection reference untuk user tertentu
  static CollectionReference _getUserAddressCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('addresses');
  }

  // Model untuk Address
  static Map<String, dynamic> addressToMap(Map<String, String> address) {
    return {
      'name': address['name'],
      'address': address['address'],
      'phone': address['phone'],
      'isDefault': address['isDefault'] == 'true',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Tambah alamat baru untuk current user
  static Future<String> addAddress(Map<String, String> address) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User belum login');
    }

    try {
      final docRef = await _getUserAddressCollection(
        userId,
      ).add(addressToMap(address));
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah alamat: $e');
    }
  }

  // Ambil semua alamat current user
  static Future<List<Map<String, dynamic>>> getAllAddresses() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User belum login');
    }

    try {
      final snapshot = await _getUserAddressCollection(
        userId,
      ).orderBy('createdAt', descending: false).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'address': data['address'] ?? '',
          'phone': data['phone'] ?? '',
          'isDefault': data['isDefault'] ?? false,
        };
      }).toList();
    } catch (e) {
      // Jika belum ada alamat, return empty list
      return [];
    }
  }

  // Update alamat
  static Future<void> updateAddress(
    String id,
    Map<String, String> address,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User belum login');
    }

    try {
      await _getUserAddressCollection(userId).doc(id).update({
        'name': address['name'],
        'address': address['address'],
        'phone': address['phone'],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal update alamat: $e');
    }
  }

  // Hapus alamat
  static Future<void> deleteAddress(String id) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User belum login');
    }

    try {
      await _getUserAddressCollection(userId).doc(id).delete();
    } catch (e) {
      throw Exception('Gagal hapus alamat: $e');
    }
  }

  // Stream alamat (real-time) untuk current user
  static Stream<List<Map<String, dynamic>>> streamAddresses() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _getUserAddressCollection(
      userId,
    ).orderBy('createdAt', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'address': data['address'] ?? '',
          'phone': data['phone'] ?? '',
          'isDefault': data['isDefault'] ?? false,
        };
      }).toList();
    });
  }

  // Set alamat sebagai default
  static Future<void> setDefaultAddress(String addressId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User belum login');
    }

    try {
      // Remove default dari semua alamat
      final addresses = await _getUserAddressCollection(userId).get();
      for (var doc in addresses.docs) {
        await doc.reference.update({'isDefault': false});
      }

      // Set alamat ini sebagai default
      await _getUserAddressCollection(
        userId,
      ).doc(addressId).update({'isDefault': true});
    } catch (e) {
      throw Exception('Gagal set default address: $e');
    }
  }

  // Get default address
  static Future<Map<String, dynamic>?> getDefaultAddress() async {
    final userId = _currentUserId;
    if (userId == null) {
      return null;
    }

    try {
      final snapshot = await _getUserAddressCollection(
        userId,
      ).where('isDefault', isEqualTo: true).limit(1).get();

      if (snapshot.docs.isEmpty) {
        // Jika tidak ada default, ambil alamat pertama
        final allAddresses = await getAllAddresses();
        if (allAddresses.isNotEmpty) {
          return allAddresses.first;
        }
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'address': data['address'] ?? '',
        'phone': data['phone'] ?? '',
        'isDefault': data['isDefault'] ?? false,
      };
    } catch (e) {
      return null;
    }
  }
}
