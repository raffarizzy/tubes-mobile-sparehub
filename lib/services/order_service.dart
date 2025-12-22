import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_sparehub/services/auth_service.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SIMPAN ORDER (Dual Write)
  static Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    required Map<String, dynamic> address,
    required String invoiceUrl,
  }) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) {
        throw Exception("User belum login");
      }

      // Generate order ID
      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      // Ambil semua tokoId dari items
      final tokoIds = items
          .map((item) => item['tokoId'] as String?)
          .where((id) => id != null)
          .toSet()
          .cast<String>()
          .toList();

      final orderData = {
        'orderId': orderId,
        'buyerId': user.uid,
        'buyerName': address['name'],
        'buyerPhone': address['phone'],
        'shippingAddress': address['address'],
        'items': items,
        'tokoIds': tokoIds, // Untuk seller query
        'totalAmount': totalAmount,
        'invoiceUrl': invoiceUrl,
        'status': 'menungguKonfirmasi',
        'courier': null,
        'trackingNumber': null,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Simpan ke 2 tempat sekaligus
      await Future.wait([
        // 1. Di users/{uid}/orders (untuk buyer)
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .doc(orderId)
            .set(orderData),
        
        // 2. Di orders (untuk seller)
        _firestore.collection('orders').doc(orderId).set(orderData),
      ]);

      return orderId;
    } catch (e) {
      throw Exception("Gagal menyimpan order: $e");
    }
  }

  // AMBIL ORDER USER (untuk buyer)
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception("Gagal memuat riwayat pesanan: $e");
    }
  }

  // ========================================
  // AMBIL ORDER TOKO (untuk seller)
  // ========================================
  static Stream<List<Map<String, dynamic>>> getOrdersByToko(String tokoId) {
    return _firestore
        .collection('orders')
        .where('tokoIds', arrayContains: tokoId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Filter items dari toko ini aja
        final myItems = (data['items'] as List)
            .where((item) => item['tokoId'] == tokoId)
            .toList();

        return {
          'id': doc.id,
          'orderId': data['orderId'],
          'buyerName': data['buyerName'],
          'buyerPhone': data['buyerPhone'],
          'shippingAddress': data['shippingAddress'],
          'myItems': myItems, // Items dari toko ini
          'status': data['status'],
          'courier': data['courier'],
          'trackingNumber': data['trackingNumber'],
          'createdAt': data['createdAt'],
        };
      }).toList();
    });
  }

  // ========================================
  // UPDATE STATUS
  // ========================================
  static Future<void> updateOrderStatus({
    required String orderId,
    required String buyerId,
    required String status,
    String? courier,
    String? trackingNumber,
  }) async {
    try {
      final updates = {
        'status': status,
        if (courier != null) 'courier': courier,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
      };

      // Update di 2 tempat
      await Future.wait([
        _firestore
            .collection('users')
            .doc(buyerId)
            .collection('orders')
            .doc(orderId)
            .update(updates),
        
        _firestore.collection('orders').doc(orderId).update(updates),
      ]);
    } catch (e) {
      throw Exception("Gagal update status: $e");
    }
  }
}