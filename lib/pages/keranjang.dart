import 'package:flutter/material.dart';
import 'package:tubes_sparehub/services/keranjang_service.dart';
import 'package:tubes_sparehub/services/product_service.dart';
import 'package:tubes_sparehub/services/auth_service.dart';
import 'package:tubes_sparehub/models/keranjang_model.dart';
import 'package:tubes_sparehub/models/product_model.dart';
import 'package:tubes_sparehub/pages/halaman_checkout.dart';

void main() {
  runApp(const KeranjangApp());
}

class KeranjangApp extends StatelessWidget {
  const KeranjangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpareHub Keranjang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF122C4F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF122C4F)),
        useMaterial3: true,
      ),
      home: const KeranjangPage(),
    );
  }
}

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final Color primaryColor = const Color(0xFF122C4F);
  final Color accentColor = const Color(0xFFE4A70D);
  final Color lightBackgroundColor = const Color(0xFFF4F6F9);

  final KeranjangService _keranjangService = KeranjangService();
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();

  // Cached streams to prevent rebuild flicker
  late final Stream<List<KeranjangModel>>? _keranjangStream;
  late final Stream<List<ProductModel>> _productsStream;

  @override
  void initState() {
    super.initState();

    // Initialize streams ONCE in initState
    final user = _authService.currentUser;
    if (user != null) {
      _keranjangStream = _keranjangService.getKeranjangByUserId(user.uid);
    } else {
      _keranjangStream = null;
    }

    _productsStream = _productService.getAllProducts();
  }

  // Format harga ke bentuk rupiah
  String _formatRupiah(int number) {
    int integerPart = number.toInt();
    String result = integerPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return result;
  }

  // Hitung total harga keranjang
  int _calculateTotalPrice(
    List<KeranjangModel> keranjangItems,
    Map<String, ProductModel> productsMap,
  ) {
    int total = 0;

    for (var item in keranjangItems) {
      final produk = productsMap[item.produkId];
      if (produk != null) {
        total += produk.harga * item.jumlah;
      }
    }

    return total;
  }

  // Tambah jumlah item di keranjang
  Future<void> _incrementQuantity(KeranjangModel item, int stokTersedia) async {
    try {
      // Cek apakah quantity + 1 melebihi stok
      if (item.jumlah + 1 > stokTersedia) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stok tidak mencukupi. Maksimal: $stokTersedia unit'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await _keranjangService.updateKeranjang(item.id, {
        'jumlah': item.jumlah + 1,
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengupdate jumlah: $e')));
    }
  }

  // Kurangi jumlah item di keranjang
  Future<void> _decrementQuantity(KeranjangModel item) async {
    try {
      if (item.jumlah > 1) {
        await _keranjangService.updateKeranjang(item.id, {
          'jumlah': item.jumlah - 1,
        });
      } else {
        await _removeItem(item);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengupdate jumlah: $e')));
    }
  }

  // Hapus item
  Future<void> _removeItem(KeranjangModel item) async {
    try {
      await _keranjangService.deleteKeranjang(item.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item dihapus dari keranjang'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: lightBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Keranjang SpareHub',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Silakan login terlebih dahulu',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Keranjang SpareHub',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<List<KeranjangModel>>(
          stream: _keranjangStream, // Use cached stream
          builder: (context, keranjangSnapshot) {
            // Loading state
            if (keranjangSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (keranjangSnapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${keranjangSnapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final keranjangItems = keranjangSnapshot.data ?? [];

            // Empty cart
            if (keranjangItems.isEmpty) {
              return _buildEmptyCart();
            }

            // Fetch all product details
            return StreamBuilder<List<ProductModel>>(
              stream: _productsStream, // Use cached stream
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allProducts = productSnapshot.data ?? [];

                // Create a map for quick lookup
                Map<String, ProductModel> productsMap = {};
                for (var product in allProducts) {
                  productsMap[product.id] = product;
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: keranjangItems.length,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemBuilder: (context, index) {
                          final keranjangItem = keranjangItems[index];
                          final produk = productsMap[keranjangItem.produkId];

                          if (produk == null) {
                            return const SizedBox();
                          }

                          return _buildCartItemCard(keranjangItem, produk);
                        },
                      ),
                    ),
                    _buildCheckoutFooter(keranjangItems, productsMap),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Tampilan jika keranjang kosong
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Keranjang Anda Kosong',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // Kartu item di keranjang
  Widget _buildCartItemCard(KeranjangModel item, ProductModel produk) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(item),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete_sweep_outlined,
          color: Colors.white,
          size: 30,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  produk.imagePath,
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.motorcycle,
                        size: 40,
                        color: Colors.white70,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            produk.nama,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: primaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Rp ${_formatRupiah(produk.harga * item.jumlah)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${_formatRupiah(produk.harga)}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: () => _decrementQuantity(item),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item.jumlah}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () =>
                                _incrementQuantity(item, produk.stok),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 18, color: primaryColor),
      ),
    );
  }

  Widget _buildCheckoutFooter(
    List<KeranjangModel> keranjangItems,
    Map<String, ProductModel> productsMap,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Harga:',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              Text(
                'Rp ${_formatRupiah(_calculateTotalPrice(keranjangItems, productsMap))}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Validasi keranjang kosong
                if (keranjangItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Keranjang masih kosong!')),
                  );
                  return;
                }

                // Konversi isi keranjang ke format untuk CheckoutPage
                List<Map<String, dynamic>> cartItems = [];

                for (var item in keranjangItems) {
                  final produk = productsMap[item.produkId];

                  // Skip jika produk tidak ditemukan
                  if (produk == null) continue;

                  // Tambah ke cartItems dengan format yang benar
                  cartItems.add({
                    'id': produk.id,
                    'nama': produk.nama,
                    'imagePath': produk.imagePath,
                    'hargaAsli': produk.harga, // Harga asli
                    'diskon': produk.diskon ?? 0.0, // Diskon (default 0)
                    'jumlah': item.jumlah, // Jumlah yang dibeli
                  });
                }

                // Navigate ke halaman Checkout
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(cartItems: cartItems),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Lanjut ke Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122C4F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
