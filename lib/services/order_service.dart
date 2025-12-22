import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_sparehub/services/auth_service.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Map<String, dynamic>>> enrichItemsWithTokoId(
    List<Map<String, dynamic>> items,
  ) async {
    final List<Map<String, dynamic>> enrichedItems = [];

    for (final item in items) {
      final productId = item['id'];

      final productSnap = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (!productSnap.exists) {
        throw Exception('Produk $productId tidak ditemukan');
      }

      final productData = productSnap.data()!;

      enrichedItems.add({
        ...item,
        'tokoId': productData['tokoId'], // 🔥
        'tokoName': productData['tokoName'], // optional
      });
    }

    return enrichedItems;
  }

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

      for (var item in items) {
        print('ITEM: $item');
      }

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
        'address': {
          'name': address['name'],
          'phone': address['phone'],
          'address': address['address'],
        },
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

            // 🔥 Filter item milik toko ini
            final myItems = (data['items'] as List)
                .where((item) => item['tokoId'] == tokoId)
                .toList();

            return {
              'id': doc.id,
              'orderId': data['orderId'],
              'buyerId': data['buyerId'],

              // 🔥 AMBIL DARI ADDRESS OBJECT
              'buyerName': data['address']?['name'],
              'buyerPhone': data['address']?['phone'],
              'shippingAddress': data['address']?['address'],

              'myItems': myItems,
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
