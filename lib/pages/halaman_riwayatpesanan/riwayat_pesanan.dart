import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tubes_sparehub/services/order_service.dart';
import 'package:tubes_sparehub/services/auth_service.dart';
import 'package:tubes_sparehub/services/rating_service.dart';
import 'package:tubes_sparehub/widgets/review_dialog.dart';

class RiwayatPesanan extends StatefulWidget {
  const RiwayatPesanan({super.key});

  @override
  State<RiwayatPesanan> createState() => _RiwayatPesananState();
}

class _RiwayatPesananState extends State<RiwayatPesanan> {
  // ======================
  // FORMATTER
  // ======================
  String _formatStatus(String status) {
    switch (status) {
      case 'menungguKonfirmasi':
        return 'Menunggu Konfirmasi';
      case 'diproses':
        return 'Sedang Diproses';
      case 'dikirim':
        return 'Sedang Dikirim';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'diproses':
        return Colors.orange;
      case 'menungguKonfirmasi':
        return Colors.redAccent;
      case 'dikirim':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
    } catch (_) {
      return '-';
    }
  }

  String _formatRupiah(int amount) {
    final s = amount.toString();
    final buffer = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      final left = s.length - i - 1;
      if (left > 0 && left % 3 == 0) buffer.write('.');
    }
    return buffer.toString();
  }

  // ======================
  // UI
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF122C4F),
      ),
      backgroundColor: const Color(0xFFF4F8FF),

      // REALTIME STREAM
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: OrderService.streamUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pesanan.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Container(
            color: const Color(0xFFF4F8FF),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final items = order['items'] as List<dynamic>;

                String productName = items.isNotEmpty
                    ? items.first['nama'] ?? 'Produk'
                    : 'Produk';

                if (items.length > 1) {
                  productName += ' +${items.length - 1} lainnya';
                }

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _formatDate(order['createdAt']),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatRupiah(order['totalAmount']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatStatus(order['status']),
                          style: TextStyle(
                            color: _getStatusColor(order['status']),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showOrderDetail(order),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ======================
  // DETAIL BOTTOM SHEET
  // ======================
  void _showOrderDetail(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              const Text(
                'Detail Pesanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 30),

              _detailRow('Order ID', order['orderId']),
              _detailRow('Tanggal', _formatDate(order['createdAt'])),
              _detailRow('Status', _formatStatus(order['status'])),
              _detailRow('Total', _formatRupiah(order['totalAmount'])),

              const SizedBox(height: 20),
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(order['address']['name'] ?? '-'),
              Text(order['address']['address'] ?? '-'),
              Text('No. HP: ${order['address']['phone'] ?? '-'}'),

              const SizedBox(height: 20),
              const Text(
                'Produk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...(order['items'] as List).map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          item['imagePath'] != null &&
                              item['imagePath'].toString().isNotEmpty
                          ? Image.network(
                              item['imagePath'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.broken_image),
                                );
                              },
                            )
                          : const SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.motorcycle),
                            ),
                    ),
                    title: Text(item['nama'] ?? 'Produk'),
                    subtitle: Text('Jumlah: ${item['jumlah']} pcs'),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // TERIMA PESANAN
              if (order['status'] == 'dikirim')
                ElevatedButton(
                  onPressed: () async {
                    await OrderService.updateOrderStatus(
                      orderId: order['orderId'],
                      buyerId: AuthService().currentUser!.uid,
                      status: 'selesai',
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text(
                    'Terima Pesanan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

              // REVIEW
              if (order['status'] == 'selesai') ...[
                const SizedBox(height: 24),
                const Text(
                  'Review Produk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ...(order['items'] as List).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: () async {
                        final produkId = item['id']?.toString();
                        if (produkId == null) return;

                        final user = AuthService().currentUser!;
                        final reviewed = await RatingService()
                            .hasUserReviewedProduct(user.uid, produkId);

                        if (reviewed) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produk sudah direview'),
                            ),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          builder: (_) => ReviewDialog(produkId: produkId),
                        );
                      },
                      child: Text(
                        'Review: ${item['nama']}',
                        style: const TextStyle(color: Color(0xFF122C4F)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
