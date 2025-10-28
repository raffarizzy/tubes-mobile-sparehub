import 'package:flutter/material.dart';

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
      home: ShopPage(),
    );
  }
}

class ShopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                      Text(
                        "Kembali",
                        style: TextStyle(color: Colors.white, fontSize: 14),
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
                        child: Icon(Icons.store, size: 35, color: Color(0xFF0B2C54)),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Toko Abah",
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
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      )
                    ],
                  ),

                  SizedBox(height: 16),

                  // Kontak & alamat
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.white),
                            SizedBox(width: 8),
                            Text("0812-3762-1829", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Jl. Telekomunikasi Terusan Buah Batu, Bandung - 40257, Indonesia",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    "Deskripsi",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Toko ini menjual berbagai macam sparepart dengan kualitas terbaik",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Konten Produk
            Expanded(
              child: SingleChildScrollView(
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

                    // Card produk
                    ProductCard(
                      title: "Cover Rack Black New Vario 125",
                      price: "Rp 180.000 / pcs",
                      shopName: "Toko Abah",
                      location: "Jakarta",
                      image: Icons.settings,
                    ),

                    SizedBox(height: 10),
                    ProductCard(
                      title: "Part Motor #1526",
                      price: "Rp 220.000 / pcs",
                      shopName: "Toko Abah",
                      location: "Jakarta",
                      image: Icons.build_circle,
                    ),
                  ],
                ),
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
            BottomButton(icon: Icons.add_circle_outline, label: "Tambah Produk"),
            BottomButton(icon: Icons.local_shipping_outlined, label: "Lacak Produk"),
            BottomButton(icon: Icons.delete_outline, label: "Hapus Produk"),
          ],
        ),
      ),
    );
  }
}

// Widget Card Produk
class ProductCard extends StatelessWidget {
  final String title, price, shopName, location;
  final IconData image;

  const ProductCard({
    required this.title,
    required this.price,
    required this.shopName,
    required this.location,
    required this.image,
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
            child: Icon(image, color: Color(0xFF0B2C54), size: 30),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(price, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
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
            child: Text("1", style: TextStyle(color: Colors.white)),
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
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12),
        )
      ],
    );
  }
}
