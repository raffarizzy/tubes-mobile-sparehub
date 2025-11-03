import 'package:flutter/material.dart';
import 'package:tubes_sparehub/data/KeranjangData.dart';
import 'package:tubes_sparehub/data/ProductData.dart';
import 'package:tubes_sparehub/data/UserData.dart';

void main() {
  runApp(const KeranjangApp());
}

class KeranjangApp extends StatefulWidget {
  const KeranjangApp({super.key});

  @override
  State<KeranjangApp> createState() => _KeranjangAppState();
}

class _KeranjangAppState extends State<KeranjangApp> {
  @override
  Widget build(BuildContext context) {
    // Definisi tema dan KeranjangPage sebagai halaman awal
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

// --- DUMMY DATA ---
class CartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });
}

List<CartItem> dummyCartItems = [
  CartItem(
    id: '1',
    name: 'Kampas Rem Depan Vario 125',
    imageUrl:
        'https://www.hondacengkareng.com/wp-content/uploads/2017/11/Pad-Set-FR-06455KVB401-600x600.jpg',
    price: 45000,
    quantity: 2,
  ),
  CartItem(
    id: '2',
    name: 'Filter Udara Beat FI',
    imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=FilterUdara',
    price: 28000,
    quantity: 1,
  ),
  CartItem(
    id: '3',
    name: 'Busi NGK C7HSA',
    imageUrl: 'https://via.placeholder.com/150/008000/FFFFFF?text=Busi',
    price: 15000,
    quantity: 5,
  ),
];

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({Key? key}) : super(key: key);

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<CartItem> _cartItems = List.from(dummyCartItems);
  List<Map<String, dynamic>> getQtyByProdukId(int produkId) {
    return keranjang
        .where((cart) => cart['produkId'] == produkId)
        .toList();
  }
  Map<String, dynamic>? getProductById(int id ) {
    try {
      final product = products.firstWhere((produk) => produk['id'] == id);
      return {
        'id': product['id'],
        'name': product['nama'],
        'imageUrl': product['imagePath'],
        'price': product['harga'],
        'quantity': getQtyByProdukId(id),
      };
    } catch (e) {
      return null;
    }
  }

  final Color primaryColor = const Color(0xFF122C4F);
  final Color accentColor = const Color(0xFFE4A70D);
  final Color lightBackgroundColor = const Color(0xFFF4F6F9);

  String _formatRupiah(double number) {
    int integerPart = number.toInt();
    String result = integerPart.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return result;
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  void _incrementQuantity(int index) {
    setState(() {
      _cartItems[index].quantity++;
      print(getProductById(int.parse(_cartItems[index].id)));
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        final removedItemName = _cartItems[index].name;
        _cartItems.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$removedItemName dihapus dari keranjang.'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      if (index >= 0 && index < _cartItems.length) {
        final removedItemName = _cartItems[index].name;
        _cartItems.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$removedItemName dihapus dari keranjang.'),
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
        title: Text(
          'Keranjang SpareHub',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _cartItems.isEmpty
            ? Center(
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
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cartItems.length,
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

  Widget _buildCartItemCard(int index) {
    final item = _cartItems[index];
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _removeItem(index);
      },
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
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  item.imageUrl,
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      Icons.two_wheeler,
                      color: primaryColor,
                      size: 35,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: primaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Rp ${_formatRupiah(item.price * item.quantity)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${_formatRupiah(item.price)}',
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
                        children: <Widget>[
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: () => _decrementQuantity(index),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Text(
                              '${item.quantity}',
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
            children: <Widget>[
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
                shadowColor: accentColor.withOpacity(0.5),
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
