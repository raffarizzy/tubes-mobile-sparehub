import 'package:flutter/material.dart';
import 'toko_halaman/hapus.dart';
import 'toko_halaman/lacak.dart';
import 'toko_halaman/tambah.dart';
import 'package:tubes_sparehub/services/product_service.dart';
import 'package:tubes_sparehub/services/toko_service.dart';
import 'package:tubes_sparehub/services/auth_service.dart';
import 'package:tubes_sparehub/models/product_model.dart';
import 'package:tubes_sparehub/models/toko_model.dart';

void main() {
  runApp(SpareShopApp());
}

class SpareShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpareShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0B2C54)),
        useMaterial3: true,
      ),
      home: toko_saya(),
    );
  }
}

// PAGE TOKO
class toko_saya extends StatefulWidget {
  @override
  _tokoSayaState createState() => _tokoSayaState();
}

class _tokoSayaState extends State<toko_saya> {
  final ProductService _productService = ProductService();
  final TokoService _tokoService = TokoService();
  final AuthService _authService = AuthService();

  String? tokoId;
  TokoModel? tokoInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokoData();
  }

  // Load toko data from authenticated user
  Future<void> _loadTokoData() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        // User not logged in, redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silakan login terlebih dahulu')),
        );
        Navigator.pop(context);
        return;
      }

      // Get user's toko
      final tokos = await _tokoService.getTokosByPemilikId(user.uid).first;

      if (tokos.isEmpty) {
        // User doesn't have a toko yet
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Use first toko (user can only have 1 toko)
      setState(() {
        tokoInfo = tokos.first;
        tokoId = tokos.first.id;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading toko: $e')),
      );
    }
  }

  // Show create toko dialog
  void _showCreateTokoDialog() {
    final TextEditingController namaTokoController = TextEditingController();
    final TextEditingController deskripsiController = TextEditingController();
    final TextEditingController lokasiController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buat Toko Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaTokoController,
                  decoration: InputDecoration(
                    labelText: 'Nama Toko',
                    hintText: 'Contoh: Toko Spare Part Jaya',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: deskripsiController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Deskripsi singkat tentang toko Anda',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: lokasiController,
                  decoration: InputDecoration(
                    labelText: 'Lokasi',
                    hintText: 'Contoh: Jakarta Selatan',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
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
                // Validate input
                if (namaTokoController.text.trim().isEmpty ||
                    deskripsiController.text.trim().isEmpty ||
                    lokasiController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Semua field harus diisi')),
                  );
                  return;
                }

                final user = _authService.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User tidak ditemukan')),
                  );
                  return;
                }

                // Check if user already has a toko (1 account = 1 toko)
                final existingTokos = await _tokoService.getTokosByPemilikId(user.uid).first;
                if (existingTokos.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Anda sudah memiliki toko. Satu akun hanya bisa memiliki satu toko.')),
                  );
                  Navigator.pop(context);
                  return;
                }

                // Create toko
                TokoModel newToko = TokoModel(
                  id: '', // Will be auto-generated
                  namaToko: namaTokoController.text.trim(),
                  pemilikId: user.uid,
                  deskripsi: deskripsiController.text.trim(),
                  logoPath: 'assets/images/default_toko_logo.png',
                  lokasi: lokasiController.text.trim(),
                );

                try {
                  await _tokoService.addToko(newToko);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Toko berhasil dibuat!')),
                  );
                  // Reload toko data
                  setState(() {
                    isLoading = true;
                  });
                  _loadTokoData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal membuat toko: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF122C4F),
                foregroundColor: Colors.white,
              ),
              child: Text('Buat Toko'),
            ),
          ],
        );
      },
    );
  }

  Future<void> tambahProduk(String nama, String deskripsi, String harga, int jumlah, int id) async {
    if (tokoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Toko ID tidak ditemukan')),
      );
      return;
    }
    try {
      ProductModel newProduct = ProductModel(
        id: '', // Will be auto-generated by Firestore
        nama: nama,
        harga: int.tryParse(harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        deskripsi: deskripsi,
        imagePath: 'assets/images/default_icon.png',
        tokoId: tokoId!,
        stok: jumlah,
        kategori: 'Otomotif',
      );

      await _productService.addProduct(newProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil ditambahkan')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan produk: $e')),
      );
    }
  }

  Future<void> hapusProduk(String productId) async {
    try {
      await _productService.deleteProduct(productId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while fetching toko data
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF4F8FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show message if no toko found
    if (tokoId == null || tokoInfo == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF4F8FF),
        appBar: AppBar(
          title: Text('Toko Saya'),
          backgroundColor: Color(0xFF122C4F),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Belum punya toko?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF122C4F)),
              ),
              SizedBox(height: 8),
              Text(
                'Buat toko Anda sekarang untuk mulai berjualan',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showCreateTokoDialog(),
                icon: Icon(Icons.add_business),
                label: Text('Buat Toko'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF122C4F),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF4F8FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFB3C9E9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bar atas
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Kembali",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Toko saya",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Nama toko + icon
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.store,
                          size: 35,
                          color: Color(0xFF0B2C54),
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tokoInfo?.namaToko ?? "Nama Toko",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              "Lihat Ulasan",
                              style: TextStyle(
                                color: Color(0xFF0B2C54),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Lokasi
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tokoInfo?.lokasi ?? "Lokasi tidak tersedia",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    tokoInfo?.deskripsi ?? "Tidak ada deskripsi",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Konten Produk
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _productService.getProductsByTokoId(tokoId!),
                builder: (context, snapshot) {
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Error state
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  // Get products list
                  List<ProductModel> products = snapshot.data ?? [];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Produk saya",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B2C54),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Card produk (dinamis)
                        if (products.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text(
                                'Belum ada produk',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                          )
                        else
                          ...products.map((produk) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: ProductCard(
                                title: produk.nama,
                                price: 'Rp ${produk.harga} / pcs',
                                shopName: tokoInfo?.namaToko ?? "Nama Toko",
                                location: tokoInfo?.lokasi ?? "Lokasi",
                                imagePath: produk.imagePath.isNotEmpty
                                    ? produk.imagePath
                                    : 'assets/images/default_icon.png',
                                jumlah: produk.stok,
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Color(0xFF0B2C54),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Tambah()),
                );
                if (result != null) {
                  await tambahProduk(
                    result['nama'],
                    result['deskripsi'],
                    result['harga'],
                    result['jumlah'],
                    result['id'],
                  );
                }
              },
              child: BottomButton(
                icon: Icons.add_circle_outline,
                label: "Tambah Produk",
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Lacak()),
                );
              },
              child: BottomButton(
                icon: Icons.local_shipping_outlined,
                label: "Lacak Produk",
              ),
            ),
            StreamBuilder<List<ProductModel>>(
              stream: _productService.getProductsByTokoId(tokoId!),
              builder: (context, snapshot) {
                List<ProductModel> products = snapshot.data ?? [];

                return GestureDetector(
                  onTap: () async {
                    // Convert ProductModel list to Map format for HapusProdukPage
                    List<Map<String, dynamic>> produkList = products.map((p) => p.toMap()).toList();

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HapusProdukPage(produkList: produkList),
                      ),
                    );

                    // Result should be the product ID (String)
                    if (result != null && result is String) {
                      await hapusProduk(result);
                    } else if (result != null && result is int) {
                      // Handle old format (index) by getting product ID
                      if (result >= 0 && result < products.length) {
                        await hapusProduk(products[result].id);
                      }
                    }
                  },
                  child: BottomButton(
                    icon: Icons.delete_outline,
                    label: "Hapus Produk",
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET
class ProductCard extends StatelessWidget {
  final String title, price, shopName, location;
  final String imagePath;
  final int jumlah;

  const ProductCard({
    required this.title,
    required this.price,
    required this.shopName,
    required this.location,
    required this.imagePath,
    this.jumlah = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Color(0xFFDDE8F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(imagePath),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  price,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                Row(
                  children: [
                    Icon(Icons.store, size: 14, color: Color(0xFF0B2C54)),
                    SizedBox(width: 4),
                    Text(shopName, style: TextStyle(fontSize: 12)),
                    SizedBox(width: 8),
                    Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                    Text(location, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Container(
            alignment: Alignment.center,
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: Color(0xFF0B2C54),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              jumlah.toString(),
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Tombol bawah
class BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const BottomButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 26),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}