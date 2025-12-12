import 'package:flutter/material.dart';
import 'package:tubes_sparehub/pages/detail_produk.dart'; // Import halaman detail produk
import 'package:tubes_sparehub/pages/keranjang.dart'; // TAMBAHAN IMPORT
import 'package:tubes_sparehub/services/product_service.dart';
import 'package:tubes_sparehub/models/product_model.dart';

class HomePage extends StatefulWidget {
  // Opsional: terima data user dari login (kalo mau dipake)
  final Map<String, dynamic>? userData;

  const HomePage({super.key, this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = "";
  String? selectedKategori;
  double? minHarga;
  double? maxHarga;
  bool showFilters = false;

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    return products.where((product) {
      // Filter by search query
      bool matchesSearch =
          searchQuery.isEmpty ||
          product.nama.toLowerCase().contains(searchQuery.toLowerCase());

      // Filter by kategori
      bool matchesKategori =
          selectedKategori == null ||
          selectedKategori == "Semua" ||
          product.kategori == selectedKategori;

      // Filter by price range
      bool matchesPrice = true;
      if (minHarga != null && product.harga < minHarga!) {
        matchesPrice = false;
      }
      if (maxHarga != null && product.harga > maxHarga!) {
        matchesPrice = false;
      }

      return matchesSearch && matchesKategori && matchesPrice;
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Filter Produk'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
                    // SizedBox(height: 8),
                    // Wrap(
                    //   spacing: 8,
                    //   children: [
                    //     FilterChip(
                    //       label: Text('Semua'),
                    //       selected: selectedKategori == null || selectedKategori == "Semua",
                    //       onSelected: (selected) {
                    //         setDialogState(() {
                    //           selectedKategori = "Semua";
                    //         });
                    //       },
                    //     ),
                    //     FilterChip(
                    //       label: Text('Oli'),
                    //       selected: selectedKategori == "Oli",
                    //       onSelected: (selected) {
                    //         setDialogState(() {
                    //           selectedKategori = selected ? "Oli" : null;
                    //         });
                    //       },
                    //     ),
                    //     FilterChip(
                    //       label: Text('Ban'),
                    //       selected: selectedKategori == "Ban",
                    //       onSelected: (selected) {
                    //         setDialogState(() {
                    //           selectedKategori = selected ? "Ban" : null;
                    //         });
                    //       },
                    //     ),
                    //     FilterChip(
                    //       label: Text('Aki'),
                    //       selected: selectedKategori == "Aki",
                    //       onSelected: (selected) {
                    //         setDialogState(() {
                    //           selectedKategori = selected ? "Aki" : null;
                    //         });
                    //       },
                    //     ),
                    //     FilterChip(
                    //       label: Text('Otomotif'),
                    //       selected: selectedKategori == "Otomotif",
                    //       onSelected: (selected) {
                    //         setDialogState(() {
                    //           selectedKategori = selected ? "Otomotif" : null;
                    //         });
                    //       },
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 16),
                    Text(
                      'Range Harga',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Min',
                              border: OutlineInputBorder(),
                              prefixText: 'Rp ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setDialogState(() {
                                minHarga = double.tryParse(value);
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('-'),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Max',
                              border: OutlineInputBorder(),
                              prefixText: 'Rp ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setDialogState(() {
                                maxHarga = double.tryParse(value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedKategori = null;
                      minHarga = null;
                      maxHarga = null;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Reset'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5FF),
        appBar: AppBar(
          title: const Text(
            "BERANDA",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF122C4F),
          // ACTIONS UNTUK TOMBOL KERANJANG
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
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
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari sparepart...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF122C4F),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  // Filter Button
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF122C4F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: Colors.white),
                      onPressed: _showFilterDialog,
                      tooltip: 'Filter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Filters Display
              if (selectedKategori != null ||
                  minHarga != null ||
                  maxHarga != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        size: 16,
                        color: Color(0xFF122C4F),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Filter: ${selectedKategori ?? ""} ${minHarga != null ? "Min: Rp $minHarga" : ""} ${maxHarga != null ? "Max: Rp $maxHarga" : ""}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF122C4F),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedKategori = null;
                            minHarga = null;
                            maxHarga = null;
                          });
                        },
                        child: Icon(Icons.close, size: 16, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              if (selectedKategori != null ||
                  minHarga != null ||
                  maxHarga != null)
                const SizedBox(height: 8),

              const Text(
                "Beli Cepat",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF122C4F),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<ProductModel>>(
                  stream: _productService.getAllProducts(),
                  builder: (context, snapshot) {
                    // Loading state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Error state
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }

                    // Empty state
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada produk',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Data loaded successfully
                    List<ProductModel> allProducts = snapshot.data!;
                    List<ProductModel> products = _filterProducts(allProducts);

                    // Empty state after filtering
                    if (products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada produk yang sesuai',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Coba ubah filter pencarian',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 kolom
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.7, // biar proporsi kayak contoh
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return GestureDetector(
                          // Tambahkan GestureDetector biar bisa diklik
                          onTap: () {
                            // Navigate ke halaman DetailProduk dan kirim data product
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailProduk(product: product.toMap()),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar produk
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        product.imagePath.isNotEmpty
                                            ? product.imagePath
                                            : 'assets/images/oliMobil.png',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          // Kalo gambar ga ada, tampilkan placeholder
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF122C4F),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rp ${product.harga}",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Rating
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow[700],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              '5',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Color(0xFF122C4F),
                                      ),
                                      const Text(
                                        "Jakarta",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
