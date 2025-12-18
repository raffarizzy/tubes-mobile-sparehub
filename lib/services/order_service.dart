import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_sparehub/services/auth_service.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simpan order ke Firestore
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

      // Buat document baru di subcollection orders
      final orderRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(); // Auto-generate ID

      final orderData = {
        'orderId': orderRef.id,
        'items': items,
        'totalAmount': totalAmount,
        'address': address,
        'invoiceUrl': invoiceUrl,
        'status': 'Selesai', // Status langsung selesai
        'createdAt': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderData);

      return orderRef.id; // Return order ID
    } catch (e) {
      throw Exception("Gagal menyimpan order: $e");
    }
  }

  // Ambil semua order user
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) {
        return [];
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('createdAt', descending: true) // Terbaru dulu
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'orderId': doc.id,
          'items': data['items'] ?? [],
          'totalAmount': data['totalAmount'] ?? 0,
          'address': data['address'] ?? {},
          'invoiceUrl': data['invoiceUrl'] ?? '',
          'status': data['status'] ?? 'Selesai',
          'createdAt': data['createdAt'],
        };
      }).toList();
    } catch (e) {
      throw Exception("Gagal memuat riwayat pesanan: $e");
    }
  }

  // Update status order (opsional, untuk nanti kalau perlu update status)
  static Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) {
        throw Exception("User belum login");
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(orderId)
          .update({'status': status});
    } catch (e) {
      throw Exception("Gagal update status: $e");
    }
  }
}
