import 'package:flutter/material.dart';
import 'package:tubes_sparehub/main.dart';
import 'package:tubes_sparehub/data/KeranjangData.dart';
import 'package:tubes_sparehub/pages/keranjang.dart';
import 'package:tubes_sparehub/services/xendit_service.dart'; // Sesuaikan path
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

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
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi untuk proses pembayaran dengan Xendit
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi email dengan benar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final totalPembayaran = getTotalSetelahDiskon();
      final email = _emailController.text.trim();
      final selectedAddress = _addresses[_selectedAddressIndex];

      // Panggil Xendit Service
      final invoiceUrl = await XenditService.createInvoice(
        amount: totalPembayaran,
        name: selectedAddress['name']!,
        email: email,
      );

      setState(() => _isProcessing = false);

      // Tampilkan dialog sukses
      if (mounted) {
        _showPaymentDialog(invoiceUrl);
      }
    } catch (e) {
      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Dialog setelah invoice berhasil dibuat
  void _showPaymentDialog(String invoiceUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Invoice Berhasil Dibuat!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice pembayaran telah dibuat dan dikirim ke email Anda.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: const [
                  Icon(Icons.qr_code_2, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anda bisa bayar menggunakan QRIS',
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Klik tombol di bawah untuk membuka halaman pembayaran:',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyHomePage(title: 'SpareHub'),
                ),
              );
            },
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              debugPrint("INVOICE URL = $invoiceUrl");

              try {
                final uri = Uri.parse(invoiceUrl);

                await launchUrl(uri, mode: LaunchMode.externalApplication);

                keranjang.clear();

                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyHomePage(title: 'SpareHub'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal membuka link: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Buka Pembayaran'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
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
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input Email untuk Invoice
        _sectionTitle("Email untuk Invoice"),
        const SizedBox(height: 12),
        Container(
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
              Row(
                children: const [
                  Icon(Icons.email_outlined, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Invoice akan dikirim ke email ini',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan email Anda',
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

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
        // Info bahwa pembayaran menggunakan Xendit QRIS
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: const [
              Icon(Icons.qr_code_scanner, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pembayaran menggunakan QRIS melalui Xendit',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
          _detailRow("Biaya Pengiriman", "Gratis", color: Colors.green),
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
              onPressed: _isProcessing ? null : _processPayment,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.payment, color: Colors.white),
              label: Text(
                _isProcessing ? "Memproses..." : "Bayar Sekarang",
                style: const TextStyle(
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
                  Icons.motorcycle,
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
                    if (diskon > 0)
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
}
