import 'package:flutter/material.dart';
import 'package:tubes_sparehub/pages/halaman_checkout.dart';
import 'package:tubes_sparehub/pages/keranjang.dart';
import 'package:tubes_sparehub/services/toko_service.dart';
import 'package:tubes_sparehub/services/rating_service.dart';
import 'package:tubes_sparehub/services/product_service.dart';
import 'package:tubes_sparehub/services/keranjang_service.dart';
import 'package:tubes_sparehub/services/auth_service.dart';
import 'package:tubes_sparehub/models/toko_model.dart';
import 'package:tubes_sparehub/models/rating_model.dart';
import 'package:tubes_sparehub/models/product_model.dart';
import 'package:tubes_sparehub/models/keranjang_model.dart';
import 'package:tubes_sparehub/widgets/review_dialog.dart';
import 'package:tubes_sparehub/widgets/product_recommendations.dart';

// Halaman Detail Produk - Menampilkan informasi lengkap produk
class DetailProduk extends StatefulWidget {
  // Parameter product yang diterima dari halaman sebelumnya (homepage)
  final Map<String, dynamic> product;

  const DetailProduk({super.key, required this.product});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  final TokoService _tokoService = TokoService();
  final RatingService _ratingService = RatingService();
  final ProductService _productService = ProductService();
  final KeranjangService _keranjangService = KeranjangService();
  final AuthService _authService = AuthService();

  // Variable untuk menyimpan jumlah total item di keranjang
  int cartItemCount = 0;

  // Variable untuk menyimpan jumlah quantity produk yang akan dibeli
  int quantity = 1;

  // Stream untuk real-time stock - dibuat sekali agar tidak rebuild terus
  late final Stream<ProductModel?> _productStream;

  // Future untuk load toko - dibuat sekali saja
  late final Future<TokoModel?> _tokoFuture;

  // Stream untuk real-time ratings - dibuat sekali saja
  late final Stream<List<RatingModel>> _ratingsStream;

  @override
  void initState() {
    super.initState();
    _loadCartItemCount();

    // Initialize stream dan future SEKALI SAJA di initState
    _productStream = _productService
        .getProductById(widget.product['id'].toString())
        .asStream();

    _tokoFuture = getTokoById(widget.product['tokoId'].toString());

    _ratingsStream = _ratingService.getRatingsByProductId(
      widget.product['id'].toString(),
    );
  }

  // Load cart item count
  Future<void> _loadCartItemCount() async {
    final user = _authService.currentUser;
    if (user != null) {
      final count = await _keranjangService.getKeranjangItemCount(user.uid);
      setState(() {
        cartItemCount = count;
      });
    }
  }

  // Fungsi untuk fetch data toko dari Firestore
  Future<TokoModel?> getTokoById(String tokoId) async {
    return await _tokoService.getTokoById(tokoId);
  }

  // Fungsi untuk menambahkan produk ke keranjang dengan Firestore
  Future<void> tambahKeKeranjang(String produkId, int jumlahTambahan) async {
    try {
      final user = _authService.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silakan login terlebih dahulu')),
        );
        return;
      }

      // Create keranjang model
      KeranjangModel keranjangItem = KeranjangModel(
        id: '', // Will be auto-generated
        userId: user.uid,
        produkId: produkId,
        jumlah: jumlahTambahan,
      );

      // Add to Firestore
      await _keranjangService.addToKeranjang(keranjangItem);

      // Reload cart count
      await _loadCartItemCount();

      // Tampilkan SnackBar notifikasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$jumlahTambahan produk berhasil ditambahkan ke keranjang!',
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Lihat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KeranjangPage(),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan ke keranjang: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

        // Icon keranjang dengan badge counter
        actions: [
          Stack(
            children: [
              // Icon keranjang
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
      body: StreamBuilder<ProductModel?>(
        stream:
            _productStream, // Gunakan cached stream, tidak create stream baru setiap rebuild
        builder: (context, productSnapshot) {
          // Get real-time stock
          int currentStok = widget.product['stok'] ?? 0;
          if (productSnapshot.hasData && productSnapshot.data != null) {
            currentStok = productSnapshot.data!.stok;
          }

          return FutureBuilder<TokoModel?>(
            future:
                _tokoFuture, // Gunakan cached future, tidak dipanggil ulang setiap rebuild
            builder: (context, tokoSnapshot) {
              // Loading toko
              if (tokoSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final toko = tokoSnapshot.data;

              return StreamBuilder<List<RatingModel>>(
                stream: _ratingsStream, // Gunakan cached stream untuk ratings
                builder: (context, ratingSnapshot) {
                  // Calculate average rating
                  double avgRating = 0.0;
                  List<RatingModel> ratingProduk = [];

                  if (ratingSnapshot.hasData &&
                      ratingSnapshot.data!.isNotEmpty) {
                    ratingProduk = ratingSnapshot.data!;
                    avgRating =
                        ratingProduk.fold(0.0, (sum, r) => sum + r.rating) /
                        ratingProduk.length;
                  }

                  return SingleChildScrollView(
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
                              // GAMBAR PRODUK
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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

                              // NAMA PRODUK
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      // Harga produk
                                      TextSpan(
                                        text:
                                            'Rp ${widget.product['harga'] ?? 0}',
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

                              // QUANTITY SELECTOR (Tambah/Kurang)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                            color: quantity < currentStok
                                                ? const Color(0xFF122C4F)
                                                : Colors.grey,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                            onPressed:
                                                currentStok == 0 ||
                                                    quantity >= currentStok
                                                ? null
                                                : () {
                                                    // Tambah quantity hanya jika belum melebihi stok
                                                    setState(() {
                                                      quantity++;
                                                    });
                                                  },
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Peringatan jika quantity mencapai stok maksimal
                                    if (quantity >= currentStok &&
                                        currentStok > 0)
                                      Text(
                                        'Jumlah maksimal: $currentStok unit',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),

                                    // Peringatan jika stok habis
                                    if (currentStok == 0)
                                      const Text(
                                        'Stok habis, tidak dapat menambah',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
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

                              // INFO TOKO
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Nama toko dari Firestore
                                        Text(
                                          toko?.namaToko ??
                                              'Nama Toko Tidak Ditemukan',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF122C4F),
                                          ),
                                        ),
                                        // Lokasi toko
                                        Text(
                                          toko?.lokasi ?? '-',
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

                              // DESKRIPSI PRODUK
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
                                  widget.product['deskripsi'] ??
                                      'Tidak ada deskripsi',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // STOK REAL-TIME
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_2,
                                      color: currentStok > 10
                                          ? Colors.green
                                          : (currentStok > 0
                                                ? Colors.orange
                                                : Colors.red),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '${currentStok > 10 ? 'Stok Tersedia' : (currentStok > 0 ? 'Stok Terbatas' : 'Stok Habis')} ($currentStok unit)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: currentStok > 10
                                            ? Colors.green
                                            : (currentStok > 0
                                                  ? Colors.orange
                                                  : Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // RATING (Rata-rata)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    // Icon bintang
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber[700],
                                      size: 24,
                                    ),
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
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ULASAN PENGGUNA
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Ulasan Pengguna',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF122C4F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // List semua ulasan dari Firestore
                              ratingProduk.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        'Belum ada ulasan',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap:
                                          true, // Agar ListView tidak scroll sendiri
                                      physics:
                                          const NeverScrollableScrollPhysics(), // Disable scroll
                                      itemCount: ratingProduk.length,
                                      itemBuilder: (context, index) {
                                        final rating = ratingProduk[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Color(0xFF122C4F),
                                            child: Text(
                                              rating.userName.isNotEmpty
                                                  ? rating.userName[0]
                                                        .toUpperCase()
                                                  : 'A',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // Username
                                          title: Text(
                                            rating.userName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          // Komentar user
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              Row(
                                                children: List.generate(
                                                  5,
                                                  (starIndex) => Icon(
                                                    starIndex < rating.rating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    size: 14,
                                                    color: Colors.amber[700],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                rating.komentar,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                rating.tanggal,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                              const SizedBox(height: 16),

                              // TOMBOL TAMBAH KE KERANJANG
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: SizedBox(
                                  width: double.infinity, // Full width
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        (currentStok == 0 ||
                                            quantity > currentStok)
                                        ? null
                                        : () async {
                                            // Cek stok sekali lagi sebelum menambahkan
                                            final currentProduct =
                                                await _productService
                                                    .getProductById(
                                                      widget.product['id']
                                                          .toString(),
                                                    );
                                            if (currentProduct == null ||
                                                currentProduct.stok <
                                                    quantity) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Stok tidak mencukupi',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                              return;
                                            }

                                            // Panggil fungsi tambahKeKeranjang dengan Firestore
                                            await tambahKeKeranjang(
                                              widget.product['id'].toString(),
                                              quantity,
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          (currentStok > 0 &&
                                              quantity <= currentStok)
                                          ? const Color(0xFF122C4F)
                                          : Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      currentStok == 0
                                          ? 'Stok Habis'
                                          : 'Tambah ke Keranjang',
                                      style: const TextStyle(
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
                                    onPressed:
                                        (currentStok == 0 ||
                                            quantity > currentStok)
                                        ? null
                                        : () async {
                                            // Cek stok sekali lagi sebelum checkout
                                            final currentProduct =
                                                await _productService
                                                    .getProductById(
                                                      widget.product['id']
                                                          .toString(),
                                                    );
                                            if (currentProduct == null ||
                                                currentProduct.stok <
                                                    quantity) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Stok tidak mencukupi',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                              return;
                                            }

                                            // Navigate ke halaman checkout dengan data produk
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CheckoutPage(
                                                  cartItems: [
                                                    {
                                                      'id': widget
                                                          .product['id'], // CRITICAL: ID produk untuk review
                                                      'nama': widget
                                                          .product['nama'],
                                                      'hargaAsli':
                                                          widget
                                                              .product['hargaAsli'] ??
                                                          widget
                                                              .product['harga'],
                                                      'diskon':
                                                          widget
                                                              .product['diskon'] ??
                                                          0,
                                                      'jumlah': quantity,
                                                      'imagePath': widget
                                                          .product['imagePath'],
                                                    },
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          (currentStok > 0 &&
                                              quantity <= currentStok)
                                          ? Colors.green
                                          : Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      currentStok == 0
                                          ? 'Stok Habis'
                                          : 'Beli Sekarang',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // REKOMENDASI PRODUK SERUPA
                              ProductRecommendations(
                                currentProductId: widget.product['id']
                                    .toString(),
                                kategori: widget.product['kategori']
                                    ?.toString(),
                              ),
                            ],
                          ),
                        ),
                      ],
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
