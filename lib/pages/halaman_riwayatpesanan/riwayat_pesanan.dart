import 'package:flutter/material.dart';
import 'package:tubes_sparehub/services/order_service.dart';
import 'package:intl/intl.dart';
import 'package:tubes_sparehub/widgets/review_dialog.dart';
import 'package:tubes_sparehub/services/rating_service.dart';
import 'package:tubes_sparehub/services/auth_service.dart';

class RiwayatPesanan extends StatefulWidget {
  const RiwayatPesanan({super.key});

  @override
  State<RiwayatPesanan> createState() => _RiwayatPesananState();
}

class _RiwayatPesananState extends State<RiwayatPesanan> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final orders = await OrderService.getUserOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat riwayat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
      final date = timestamp.toDate();
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return '-';
    }
  }

  String _formatRupiah(int amount) {
    String numStr = amount.toString();
    String result = '';
    int count = 0;

    for (int i = numStr.length - 1; i >= 0; i--) {
      result = numStr[i] + result;
      count++;
      if (count == 3 && i != 0) {
        result = '.$result';
        count = 0;
      }
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF122C4F),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(
              child: Text(
                "Belum ada pesanan.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final items = order['items'] as List<dynamic>;

                  // Ambil nama produk pertama, atau "Multiple Items" kalau lebih dari 1
                  String productName = items.isNotEmpty
                      ? items[0]['nama'] ?? 'Produk'
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
                      onTap: () {
                        // Tap untuk lihat detail
                        _showOrderDetail(order);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _showOrderDetail(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              const Text(
                'Detail Pesanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 30),

              // INFO ORDER
              _detailRow('Order ID', order['orderId']),
              _detailRow('Tanggal', _formatDate(order['createdAt'])),
              _detailRow('Status', order['status']),
              _detailRow('Total', _formatRupiah(order['totalAmount'])),

              const SizedBox(height: 20),

              // ALAMAT
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(order['address']['name'] ?? '-'),
              Text(order['address']['address'] ?? '-'),
              Text('No. HP: ${order['address']['phone'] ?? '-'}'),

              const SizedBox(height: 20),

              // PRODUK
              const Text(
                'Produk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...(order['items'] as List<dynamic>).map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: item['imagePath'] != null
                        ? Image.asset(
                            item['imagePath'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.motorcycle),
                    title: Text(item['nama'] ?? 'Produk'),
                    subtitle: Text('Jumlah: ${item['jumlah']} pcs'),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ===============================
              // TERIMA PESANAN (HANYA JIKA DIKIRIM)
              // ===============================
              if (order['status'] == 'dikirim') ...[
                ElevatedButton(
                  onPressed: () async {
                    await OrderService.updateOrderStatus(
                      orderId: order['orderId'],
                      buyerId: AuthService().currentUser!.uid,
                      status: 'selesai',
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      _loadOrders();
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pesanan berhasil diterima'),
                        backgroundColor: Colors.green,
                      ),
                    );
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
              ],

              // ===============================
              // REVIEW PRODUK (HANYA JIKA SELESAI)
              // ===============================
              if (order['status'] == 'selesai') ...[
                const SizedBox(height: 24),
                const Text(
                  'Review Produk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ...(order['items'] as List<dynamic>).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () async {
                        final produkId = item['id']?.toString();
                        if (produkId == null) return;

                        final user = AuthService().currentUser!;
                        final hasReviewed = await RatingService()
                            .hasUserReviewedProduct(user.uid, produkId);

                        if (hasReviewed) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produk ini sudah direview'),
                            ),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          builder: (_) => ReviewDialog(produkId: produkId),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: Text(
                        'Review: ${item['nama']}',
                        style: const TextStyle(color: Color(0xFF122C4F)),
                      ),
                    ),
                  );
                }),
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
