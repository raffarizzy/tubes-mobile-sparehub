import 'package:flutter/material.dart';
import 'package:tubes_sparehub/main.dart';
import 'package:tubes_sparehub/pages/homepage.dart';
import 'homepage.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final List<Map<String, String>> _addresses = [
    {
      'name': 'Bagas',
      'address':
          'Jl. Kenanga No. 21, RT 05/RW 03, Kelurahan Sukamaju, Kecamatan Tebet, Jakarta Selatan',
      'phone': '081636472738',
    },
    {
      'name': 'Slamet',
      'address': 'Jl. Merpati No. 45, Perum Griya Asri, Blok B3, Bekasi Timur',
      'phone': '081311283830',
    },
  ];

  final List<String> _paymentImages = [
    'assets/images/visa.png',
    'assets/images/mastercard.png',
  ];

  int _selectedAddressIndex = 0;
  int _selectedPaymentIndex = 1;

  @override
  Widget build(BuildContext context) {
    int totalAsli = getTotalHargaAsli();
    int totalSetelahDiskon = getTotalSetelahDiskon();
    int totalDiskon = totalAsli - totalSetelahDiskon;
    int totalPembayaran = totalSetelahDiskon;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF122C4F),
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildLeftColumn()),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 340,
                        child: _buildRightColumn(
                          totalAsli,
                          totalDiskon,
                          totalPembayaran,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLeftColumn(),
                      const SizedBox(height: 24),
                      _buildRightColumn(
                        totalAsli,
                        totalDiskon,
                        totalPembayaran,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // =========================
  // LEFT COLUMN
  // =========================
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Pilih Alamat Pengiriman"),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < _addresses.length; i++) ...[
                _addressCard(
                  index: i,
                  name: _addresses[i]['name']!,
                  address: _addresses[i]['address']!,
                  phone: _addresses[i]['phone']!,
                  selected: _selectedAddressIndex == i,
                  onTap: () => setState(() => _selectedAddressIndex = i),
                ),
                const SizedBox(width: 12),
              ],
              _addAddressCard(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _sectionTitle("Detail Produk"),
        const SizedBox(height: 12),
        Column(
          children: widget.cartItems
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _itemCard(p),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        _sectionTitle("Metode Pembayaran"),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (int i = 0; i < _paymentImages.length; i++)
              _paymentCard(
                index: i,
                imagePath: _paymentImages[i],
                selected: _selectedPaymentIndex == i,
                onTap: () => setState(() => _selectedPaymentIndex = i),
              ),
            _addPaymentCard(),
          ],
        ),
      ],
    );
  }

  // =========================
  // RIGHT COLUMN
  // =========================
  Widget _buildRightColumn(
    int totalAsli,
    int totalDiskon,
    int totalPembayaran,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Rincian Pesanan"),
          const Divider(height: 20),
          _detailRow("Harga", formatRupiah(totalAsli)),
          _detailRow("Ongkir", "Gratis", color: Colors.green),
          _detailRow(
            "Diskon",
            "- ${formatRupiah(totalDiskon)}",
            color: Colors.red,
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                formatRupiah(totalPembayaran),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pembayaran Berhasil!')),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyHomePage(title: 'SpareHub'),
                  ),
                );
              },
              label: const Text(
                "Bayar Sekarang",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ITEM CARD
  // =========================
  Widget _itemCard(Map<String, dynamic> product) {
    double hargaAsli = (product['hargaAsli'] ?? 0).toDouble();
    double diskon = (product['diskon'] ?? 0).toDouble();
    int jumlah = product['jumlah'] ?? 1;
    int hargaDiskon = (hargaAsli * (1 - diskon)).round();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            product['imagePath'] ?? '',
            width: 90,
            height: 90,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.motorcycle, // ikon motor placeholder
                  color: Colors.grey,
                  size: 40,
                ),
              );
            },
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['nama'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      formatRupiah(hargaDiskon),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      formatRupiah(hargaAsli),
                      style: const TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Jumlah: $jumlah pcs",
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================
  String formatRupiah(dynamic number) {
    int numInt = (number is double)
        ? number.round()
        : int.tryParse(number.toString()) ?? 0;
    String numStr = numInt.toString();
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

  int getTotalHargaAsli() {
    int total = 0;
    for (var p in widget.cartItems) {
      double hargaAsli = (p['hargaAsli'] ?? 0).toDouble();
      int jumlah = (p['jumlah'] ?? 1).toInt();
      total += (hargaAsli * jumlah).round();
    }
    return total;
  }

  int getTotalSetelahDiskon() {
    int total = 0;
    for (var p in widget.cartItems) {
      double hargaAsli = (p['hargaAsli'] ?? 0).toDouble();
      double diskon = (p['diskon'] ?? 0).toDouble();
      int jumlah = (p['jumlah'] ?? 1).toInt();
      total += ((hargaAsli * (1 - diskon)) * jumlah).round();
    }
    return total;
  }

  // =========================
  // UI kecil (alamat & metode)
  // =========================
  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  Widget _detailRow(String title, String value, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15)),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );

  Widget _addressCard({
    required int index,
    required String name,
    required String address,
    required String phone,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            Text(address, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 6),
            Text(
              "No. HP: $phone",
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addAddressCard() => Container(
    width: 160,
    height: 120,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F3F4),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: const Text(
      "+ Tambah Alamat",
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
    ),
  );

  Widget _paymentCard({
    required int index,
    required String imagePath,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 100,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: 45,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _addPaymentCard() => Container(
    width: 100,
    height: 70,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F3F4),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: const Center(
      child: Text(
        "+ Tambah\nMetode",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    ),
  );
}
