import 'package:flutter/material.dart';
import 'package:tubes_sparehub/services/pesanan_service.dart';
import 'package:tubes_sparehub/services/product_service.dart';
import 'package:tubes_sparehub/services/rating_service.dart';
import 'package:tubes_sparehub/services/auth_service.dart';
import 'package:tubes_sparehub/models/pesanan_model.dart';
import 'package:tubes_sparehub/models/product_model.dart';
import 'package:tubes_sparehub/models/rating_model.dart';

class RiwayatPesanan extends StatefulWidget {
  const RiwayatPesanan({super.key});

  @override
  State<RiwayatPesanan> createState() => _RiwayatPesananState();
}

class _RiwayatPesananState extends State<RiwayatPesanan> {
  final PesananService _pesananService = PesananService();
  final ProductService _productService = ProductService();
  final RatingService _ratingService = RatingService();
  final AuthService _authService = AuthService();

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Dikirim':
        return Colors.orange;
      case 'Menunggu Pembayaran':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  // Show review dialog
  void _showReviewDialog(String produkId, String namaProduk) {
    final TextEditingController komentarController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Review $namaProduk'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Star rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: komentarController,
                      decoration: InputDecoration(
                        labelText: 'Komentar',
                        hintText: 'Tulis review Anda di sini...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = _authService.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User tidak ditemukan')),
                      );
                      return;
                    }

                    if (komentarController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Silakan isi komentar')),
                      );
                      return;
                    }

                    try {
                      RatingModel newRating = RatingModel(
                        id: '', // auto-generated
                        produkId: produkId,
                        userId: user.uid,
                        rating: rating,
                        komentar: komentarController.text.trim(),
                        tanggal: DateTime.now().toString().substring(0, 10),
                      );

                      await _ratingService.addRating(newRating);

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Review berhasil ditambahkan!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menambahkan review: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF122C4F),
                  ),
                  child: Text('Kirim Review', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTanggal(String isoDate) {
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return isoDate;
    }
  }

  String _formatRupiah(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Riwayat Pesanan",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF122C4F),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            "Silakan login terlebih dahulu",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF122C4F),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<PesananModel>>(
        stream: _pesananService.getPesanansByUserId(user.uid),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final pesanans = snapshot.data ?? [];

          // Empty state
          if (pesanans.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Belum ada pesanan.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pesanans.length,
            itemBuilder: (context, index) {
              final pesanan = pesanans[index];

              return FutureBuilder<ProductModel?>(
                future: _productService.getProductById(pesanan.produkId),
                builder: (context, productSnapshot) {
                  String namaProduk = 'Loading...';
                  if (productSnapshot.hasData && productSnapshot.data != null) {
                    namaProduk = productSnapshot.data!.nama;
                  }

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Product info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaProduk,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatTanggal(pesanan.tanggal),
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Jumlah: ${pesanan.jumlah}x',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Rp ${_formatRupiah(pesanan.totalHarga)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(pesanan.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _getStatusColor(pesanan.status),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        pesanan.status,
                                        style: TextStyle(
                                          color: _getStatusColor(pesanan.status),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Review button
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.rate_review,
                                  color: Color(0xFFE4A70D),
                                  size: 28,
                                ),
                                onPressed: () {
                                  _showReviewDialog(pesanan.produkId, namaProduk);
                                },
                                tooltip: 'Tulis Review',
                              ),
                              Text(
                                'Review',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFE4A70D),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}