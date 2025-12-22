import 'package:flutter/material.dart';
import 'package:tubes_sparehub/services/order_service.dart';

class Lacak extends StatelessWidget {
  final String tokoId;

  const Lacak({required this.tokoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F8FF),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B2C54),
        title: Text('Lacak Pesanan', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: OrderService.getOrdersByToko(tokoId),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada pesanan', 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final myItems = order['myItems'] as List;
              final status = order['status'] as String;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order['orderId'] ?? 'N/A',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF0B2C54),
                          ),
                        ),
                        _buildStatus(status),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Buyer
                    Text(
                      '${order['buyerName']} - ${order['buyerPhone']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),

                    // Items
                    Text(
                      '${myItems.length} produk',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 12),

                    // Action Buttons
                    if (status == 'menungguKonfirmasi')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _konfirmasi(order),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0B2C54),
                              ),
                              child: Text('Terima', 
                                style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _tolak(order),
                              child: Text('Tolak'),
                            ),
                          ),
                        ],
                      ),

                    if (status == 'diproses')
                      ElevatedButton(
                        onPressed: () => _kirim(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0B2C54),
                          minimumSize: Size(double.infinity, 40),
                        ),
                        child: Text('Kirim Pesanan',
                          style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatus(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case 'menungguKonfirmasi':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        text = 'Baru';
        break;
      case 'diproses':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        text = 'Diproses';
        break;
      case 'dikirim':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        text = 'Dikirim';
        break;
      case 'selesai':
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        text = 'Selesai';
        break;
      default:
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        text = 'Dibatalkan';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _konfirmasi(Map<String, dynamic> order) {
    OrderService.updateOrderStatus(
      orderId: order['id'],
      buyerId: order['buyerId'],
      status: 'diproses',
    );
  }

  void _tolak(Map<String, dynamic> order) {
    OrderService.updateOrderStatus(
      orderId: order['id'],
      buyerId: order['buyerId'],
      status: 'dibatalkan',
    );
  }

  void _kirim(BuildContext context, Map<String, dynamic> order) {
    final courierCtrl = TextEditingController();
    final resiCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kirim Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: courierCtrl,
              decoration: InputDecoration(
                labelText: 'Kurir',
                hintText: 'JNE, J&T, dll',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: resiCtrl,
              decoration: InputDecoration(
                labelText: 'No Resi',
                hintText: 'JP123456',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (courierCtrl.text.isNotEmpty && resiCtrl.text.isNotEmpty) {
                OrderService.updateOrderStatus(
                  orderId: order['id'],
                  buyerId: order['buyerId'],
                  status: 'dikirim',
                  courier: courierCtrl.text,
                  trackingNumber: resiCtrl.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0B2C54),
            ),
            child: Text('Kirim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}