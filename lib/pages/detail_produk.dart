import 'package:flutter/material.dart';
import 'package:tubes_sparehub/data/KeranjangData.dart';
import 'package:tubes_sparehub/pages/halaman_checkout.dart';
import 'package:tubes_sparehub/data/TokoData.dart';
import 'package:tubes_sparehub/data/RatingData.dart';
import 'package:tubes_sparehub/pages/keranjang.dart';

// Halaman Detail Produk - Menampilkan informasi lengkap produk
class DetailProduk extends StatefulWidget {
  // Parameter product yang diterima dari halaman sebelumnya (homepage)
  final Map<String, dynamic> product;

  const DetailProduk({super.key, required this.product});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  // Variable untuk menyimpan jumlah total item di keranjang
  int cartItemCount = 0;

  // Variable untuk menyimpan jumlah quantity produk yang akan dibeli
  int quantity = 1;

  // Fungsi untuk mencari data toko berdasarkan ID
  Map<String, dynamic>? getTokoById(int id) {
    try {
      // Cari toko di tokoList yang ID-nya cocok
      return tokoList.firstWhere((toko) => toko['id'] == id);
    } catch (e) {
      // Jika tidak ditemukan, return null
      return null;
    }
  }

  // Fungsi untuk mengambil semua rating berdasarkan ID produk
  List<Map<String, dynamic>> getRatingByProdukId(int produkId) {
    // Filter rating yang sesuai dengan produkId
    return ratingList
        .where((rating) => rating['produkId'] == produkId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data toko berdasarkan tokoId dari produk
    final toko = getTokoById(widget.product['tokoId']);

    // Ambil semua rating untuk produk ini
    final ratingProduk = getRatingByProdukId(widget.product['id']);

    // Hitung rata-rata rating
    double avgRating = ratingProduk.isNotEmpty
        ? ratingProduk.map((r) => r['rating']).reduce((a, b) => a + b) /
              ratingProduk.length
        : 0;

    return Scaffold(
      // Background biru gelap
      backgroundColor: const Color(0xFF122C4F),

      // AppBar dengan tombol back dan icon keranjang
      appBar: AppBar(
        backgroundColor: const Color(0xFF122C4F),
        elevation: 0,

        // Tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        // Judul AppBar
        title: const Text(
          'Kembali',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),

        // Icon keranjang dengan badge counter di kanan atas
        actions: [
          Stack(
            children: [
              // Icon keranjang - klik untuk ke halaman keranjang
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Navigate ke halaman keranjang
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KeranjangPage(),
                    ),
                  );
                },
              ),

              // Badge merah yang menampilkan jumlah item di keranjang
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Body yang bisa di-scroll
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container utama dengan background putih dan border radius
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //GAMBAR PRODUK
                  Center(
                    child: Container(
                      height: 200,
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        // Ambil path gambar dari data produk
                        widget.product['imagePath'] ??
                            'assets/images/oliMobil.png',
                        fit: BoxFit.contain,

                        // Error handler jika gambar tidak ditemukan
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.motorcycle,
                                size: 120,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //NAMA PRODUK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      // Ambil nama produk dari data
                      widget.product['nama'] ?? 'Nama Produk',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF122C4F),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // HARGA PRODUK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          // Harga produk
                          TextSpan(
                            text: 'Rp ${widget.product['harga'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF122C4F),
                            ),
                          ),
                          // Satuan
                          const TextSpan(
                            text: ' / pcs',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SECTION: QUANTITY SELECTOR (Tambah/Kurang)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Label "Jumlah:"
                            const Text(
                              'Jumlah:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF122C4F),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Tombol Kurang (-)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFF122C4F),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Color(0xFF122C4F),
                                ),
                                iconSize: 16,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () {
                                  // Kurangi quantity, minimal 1
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Display jumlah quantity
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F5FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF122C4F),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Tombol Tambah (+)
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF122C4F),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                iconSize: 16,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () {
                                  // Tambah quantity
                                  setState(() {
                                    quantity++;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Total harga (harga x quantity)
                        Text(
                          'Total: Rp ${(widget.product['harga'] ?? 0) * quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF122C4F),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  //INFO TOKO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Icon toko
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF122C4F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Nama toko dan lokasi
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama toko dari TokoData
                            Text(
                              toko?['namaToko'] ?? 'Nama Toko Tidak Ditemukan',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF122C4F),
                              ),
                            ),
                            // Lokasi toko
                            Text(
                              toko?['lokasi'] ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  //DESKRIPSI PRODUK
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF122C4F),
                      ),
                    ),
                  ),

                  // Isi deskripsi
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      // Ambil deskripsi dari data produk
                      widget.product['deskripsi'] ?? 'Tidak ada deskripsi',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  //RATING
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Icon bintang
                        Icon(Icons.star, color: Colors.amber[700], size: 24),
                        const SizedBox(width: 8),

                        // Rata-rata rating
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),

                        // Jumlah ulasan
                        Text(
                          ' (${ratingProduk.length} ulasan)',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  //ULASAN PENGGUNA
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Ulasan Pengguna',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF122C4F),
                      ),
                    ),
                  ),

                  // List semua ulasan dari RatingData
                  ListView.builder(
                    shrinkWrap: true, // Agar ListView tidak scroll sendiri
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable scroll
                    itemCount: ratingProduk.length,
                    itemBuilder: (context, index) {
                      final rating = ratingProduk[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.blueGrey,
                        ),
                        // Komentar user
                        title: Text(
                          rating['komentar'],
                          style: const TextStyle(fontSize: 14),
                        ),
                        // Rating dan tanggal
                        subtitle: Text(
                          '${rating['rating']} ★ - ${rating['tanggal']}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  //TOMBOL TAMBAH KE KERANJANG
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity, // Full width
                      child: ElevatedButton.icon(
                        onPressed: () {
                          keranjang.add({
                            'userId': 1,
                            'produkId': widget.product['id'],
                            'jumlah': 1,
                          });
                          // Tambah quantity ke cart counter
                          setState(() {
                            cartItemCount += quantity;
                          });

                          // Tampilkan SnackBar notifikasi
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$quantity produk ditambahkan ke keranjang! (Total: $cartItemCount item)',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF122C4F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Tambah ke Keranjang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // TOMBOL BELI SEKARANG
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity, // Full width
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate ke halaman checkout dengan data produk
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                cartItems: [
                                  {
                                    'nama': widget.product['nama'],
                                    'hargaAsli':
                                        widget.product['hargaAsli'] ??
                                        widget.product['harga'],
                                    'diskon': widget.product['diskon'] ?? 0,
                                    'jumlah': quantity,
                                    'imagePath': widget.product['imagePath'],
                                  },
                                ],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Hijau biar beda
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Beli Sekarang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
