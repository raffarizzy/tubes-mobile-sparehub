import 'package:flutter/material.dart';

// Halaman Detail Produk untuk E-commerce App
// StatefulWidget karena ada state yang bisa berubah (tombol favorite)
class DetailProduk extends StatefulWidget {
  // Terima data produk dari halaman sebelumnya
  final Map<String, dynamic> product;

  const DetailProduk({super.key, required this.product});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  // Variable untuk nyimpen status favorite (true/false)
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF122C4F), // Background biru custom
      // AppBar di bagian atas
      appBar: AppBar(
        backgroundColor: const Color(0xFF122C4F), // Biru custom
        elevation: 0, // Hilangkan shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Tombol kembali
        ),
        title: const Text(
          'Kembali',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          // Icon keranjang di kanan atas
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implementasi ke halaman keranjang
            },
          ),
        ],
      ),

      // Body yang bisa di-scroll
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container card utama (warna abu-abu terang)
            Container(
              margin: const EdgeInsets.all(16), // Jarak dari tepi
              decoration: BoxDecoration(
                color: Colors.white, // Warna abu-abu terang
                borderRadius: BorderRadius.circular(20), // Sudut melengkung
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BAGIAN GAMBAR PRODUK
                  Center(
                    child: Container(
                      height: 200, // Tinggi container gambar
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        widget.product['imagePath'] ??
                            'assets/images/oliMobil.png', // Ambil path gambar dari data
                        fit: BoxFit
                            .contain, // Gambar menyesuaikan ukuran container
                        errorBuilder: (context, error, stackTrace) {
                          // Kalo gambar ga bisa dimuat, tampilkan placeholder
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons
                                    .motorcycle, // Icon motor sebagai placeholder
                                size: 120,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Jarak vertikal
                  // BAGIAN NAMA PRODUK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.product['nama'] ??
                          'Nama Produk', // Ambil nama dari data
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF122C4F), // Warna teks biru custom
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // BAGIAN HARGA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Rp ${widget.product['harga'] ?? 0}', // Ambil harga dari data
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF122C4F), // Biru custom
                            ),
                          ),
                          const TextSpan(
                            text: ' / pcs', // Satuan
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

                  // BAGIAN INFO TOKO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Icon toko
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF122C4F,
                            ), // Background icon biru custom
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nama toko & lokasi
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Toko Abah',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF122C4F), // Biru custom
                              ),
                            ),
                            Text(
                              'Jakarta',
                              style: TextStyle(
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

                  // BAGIAN DESKRIPSI
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF122C4F), // Biru custom
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Isi deskripsi produk
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.product['deskripsi'] ??
                          'Tidak ada deskripsi', // Ambil deskripsi dari data
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87, // Teks hitam
                        height: 1.5, // Line height
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // BAGIAN RATING
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF122C4F), // Biru custom
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bintang & nilai rating
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber[700], // Warna bintang kuning
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '4,1',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // BAGIAN ULASAN (REVIEW)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Ulasan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF122C4F), // Biru custom
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BAGIAN TOMBOL-TOMBOL ACTION
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // TOMBOL FAVORITE (LOVE)
                        Expanded(
                          flex: 1, // Lebar 1 bagian
                          child: OutlinedButton(
                            onPressed: () {
                              // Toggle status favorite (dari false jadi true atau sebaliknya)
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: Color(0xFF122C4F), // Border biru custom
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Icon(
                              // Icon berubah tergantung status favorite
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : const Color(0xFF122C4F), // Biru custom
                              size: 24,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12), // Jarak horizontal
                        // TOMBOL TAMBAH KE KERANJANG
                        Expanded(
                          flex:
                              3, // Lebar 3 bagian (lebih lebar dari tombol favorite)
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Tampilkan notifikasi (SnackBar) ketika tombol diklik
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Produk ditambahkan ke keranjang!',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF122C4F,
                              ), // Warna tombol biru custom
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
                      ],
                    ),
                  ),

                  // TOMBOL BELI SEKARANG (TAMBAHAN)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity, // Lebar penuh
                      child: ElevatedButton(
                        onPressed: () {
                          // Tampilkan dialog konfirmasi ketika tombol diklik
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Beli Sekarang'),
                                content: const Text(
                                  'Lanjut ke halaman pembayaran?',
                                ),
                                actions: [
                                  // Tombol Batal
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                  // Tombol Ya (konfirmasi)
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Tutup dialog
                                      // Tampilkan notifikasi
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Menuju halaman pembayaran...',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Ya'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // Warna hijau biar keliatan beda
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
