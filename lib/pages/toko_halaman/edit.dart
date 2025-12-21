import 'package:flutter/material.dart';
import 'package:tubes_sparehub/models/product_model.dart';
import 'package:tubes_sparehub/services/product_service.dart';

class EditProdukPage extends StatefulWidget {
  final ProductModel product;
  const EditProdukPage({super.key, required this.product});
  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  late TextEditingController namaController;
  late TextEditingController hargaController;
  late TextEditingController stokController;
  late TextEditingController deskripsiController;
  String? kategori;
  @override
  void initState() {
    super.initState();

    namaController = TextEditingController(text: widget.product.nama);
    hargaController = TextEditingController(
      text: widget.product.harga.toString(),
    );
    stokController = TextEditingController(
      text: widget.product.stok.toString(),
    );
    deskripsiController = TextEditingController(text: widget.product.deskripsi);

    const validKategori = ['mesin', 'body', 'roda', 'lainnya'];

    if (validKategori.contains(widget.product.kategori)) {
      kategori = widget.product.kategori;
    } else {
      kategori = null; // biar user pilih ulang
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    stokController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Produk'),
        backgroundColor: Color(0xFF0B2C54),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: kategori,
                decoration: InputDecoration(labelText: 'Kategori'),
                items: const [
                  DropdownMenuItem(value: 'mesin', child: Text('Mesin')),
                  DropdownMenuItem(value: 'body', child: Text('Body')),
                  DropdownMenuItem(value: 'roda', child: Text('Roda')),
                  DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
                ],
                onChanged: (value) => setState(() => kategori = value),
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Harga'),
                validator: (v) =>
                    v!.isEmpty ? 'Harga tidak boleh kosong' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: stokController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stok'),
                validator: (v) => v!.isEmpty ? 'Stok tidak boleh kosong' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: deskripsiController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Deskripsi'),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0B2C54),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ProductModel updated = widget.product.copyWith(
                      nama: namaController.text,
                      harga: int.parse(hargaController.text),
                      stok: int.parse(stokController.text),
                      deskripsi: deskripsiController.text,
                      kategori: kategori,
                    );
                    await _productService.updateProduct(updated);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Produk berhasil diperbarui')),
                    );
                  }
                },
                child: Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
