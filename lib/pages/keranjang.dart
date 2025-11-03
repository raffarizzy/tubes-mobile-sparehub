import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:tubes_sparehub/data/KeranjangData.dart';
import 'package:tubes_sparehub/data/ProductData.dart';
import 'package:tubes_sparehub/data/UserData.dart';

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

  // Format harga ke bentuk rupiah
  String _formatRupiah(int number) {
    int integerPart = number.toInt();
    String result = integerPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return result;
  }

  // Dapatkan produk berdasarkan ID
  Map<String, dynamic>? getProductById(int id) {
    try {
      return products.firstWhere((produk) => produk['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Hitung total harga keranjang
  int _calculateTotalPrice() {
    int total = 0;

    for (var item in keranjang) {
      var produk = getProductById(item['produkId']);
      if (produk != null) {
        int harga = produk['harga'];
        int jumlah = item['jumlah'];
        total += harga * jumlah;
      }
    }

    return total;
  }

  // Tambah jumlah item di keranjang
  void _incrementQuantity(int index) {
    setState(() {
      keranjang[index]['jumlah']++;
    });
  }

  // Kurangi jumlah item di keranjang
  void _decrementQuantity(int index) {
    setState(() {
      if (keranjang[index]['jumlah'] > 1) {
        keranjang[index]['jumlah']--;
      } else {
        final produk = getProductById(keranjang[index]['produkId']);
        keranjang.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${produk?['nama']} dihapus dari keranjang.'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  // Hapus item
  void _removeItem(int index) {
    setState(() {
      if (index >= 0 && index < keranjang.length) {
        final produk = getProductById(keranjang[index]['produkId']);
        keranjang.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${produk?['nama']} dihapus dari keranjang.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: keranjang.isEmpty
            ? _buildEmptyCart()
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: keranjang.length,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemBuilder: (context, index) {
                        return _buildCartItemCard(index);
                      },
                    ),
                  ),
                  _buildCheckoutFooter(),
                ],
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
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Kartu item di keranjang
  Widget _buildCartItemCard(int index) {
    final item = keranjang[index];
    final produk = getProductById(item['produkId']);

    if (produk == null) return const SizedBox();

    return Dismissible(
      key: ValueKey(produk['id']),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeItem(index),
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
                  produk['imagePath'],
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.motorcycle,
                          size: 75,
                          color: Colors.white70,
                        ),
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
                            produk['nama'],
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
                          'Rp ${_formatRupiah(produk['harga'] * item['jumlah'])}',
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
                      'Rp ${_formatRupiah(produk['harga'])}',
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
                            onPressed: () => _decrementQuantity(index),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item['jumlah']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () => _incrementQuantity(index),
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

  Widget _buildCheckoutFooter() {
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
                'Rp ${_formatRupiah(_calculateTotalPrice())}',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proses Checkout dimulai...')),
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