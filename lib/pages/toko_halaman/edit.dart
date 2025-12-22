import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:tubes_sparehub/models/product_model.dart';
import 'package:tubes_sparehub/services/product_service.dart';
import 'package:tubes_sparehub/services/fix_upload_url.dart';

class EditProdukPage extends StatefulWidget {
  final ProductModel product;
  const EditProdukPage({super.key, required this.product});

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  late TextEditingController namaCtrl;
  late TextEditingController hargaCtrl;
  late TextEditingController stokCtrl;
  late TextEditingController deskripsiCtrl;

  File? _image;
  bool _loading = false;
  String? kategori;

  @override
  void initState() {
    super.initState();
    namaCtrl = TextEditingController(text: widget.product.nama);
    hargaCtrl = TextEditingController(text: widget.product.harga.toString());
    stokCtrl = TextEditingController(text: widget.product.stok.toString());
    deskripsiCtrl = TextEditingController(text: widget.product.deskripsi);

    // Validasi kategori
    const validKategori = ['mesin', 'body', 'roda', 'lainnya'];
    kategori = validKategori.contains(widget.product.kategori)
        ? widget.product.kategori
        : null;
  }

  @override
  void dispose() {
    namaCtrl.dispose();
    hargaCtrl.dispose();
    stokCtrl.dispose();
    deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<String?> _uploadImage(File image) async {
    final uri = Uri.parse(
      'https://api.imgbb.com/1/upload?key=c691b5cbc2f340e04d70a6911e17d5e8',
    );

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final decoded = json.decode(responseBody);

    if (response.statusCode != 200) {
      return null;
    }

    final rawUrl = decoded['data']['url'] as String?;

    if (rawUrl == null) return null;

    final fixedUrl = FixUploadUrl().fixImgBBUrl(rawUrl);

    return fixedUrl;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      String imageUrl = widget.product.imageUrl;

      if (_image != null) {
        final uploaded = await _uploadImage(_image!);
        if (uploaded == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload gambar gagal')));
          setState(() => _loading = false);
          return;
        }
        imageUrl = uploaded;
      }

      final updated = widget.product.copyWith(
        nama: namaCtrl.text,
        harga: int.parse(hargaCtrl.text),
        stok: int.parse(stokCtrl.text),
        deskripsi: deskripsiCtrl.text,
        kategori: kategori,
        imageUrl: imageUrl,
        imagePath: imageUrl,
      );

      await _productService.updateProduct(updated);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Produk berhasil diperbarui')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih
      appBar: AppBar(
        title: Text('Edit Produk', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0B2C54),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            _buildField(namaCtrl, 'Nama Produk'),
            SizedBox(height: 16),
            _buildDropdown(),
            SizedBox(height: 16),
            _buildField(hargaCtrl, 'Harga (Rp)', isNumber: true),
            SizedBox(height: 16),
            _buildField(stokCtrl, 'Jumlah', isNumber: true),
            SizedBox(height: 16),
            _buildField(deskripsiCtrl, 'Deskripsi', maxLines: 5),
            SizedBox(height: 20),
            Text(
              'Gambar Produk',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ), // Text hitam
            SizedBox(height: 12),
            _buildImagePicker(),
            SizedBox(height: 30),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: TextStyle(color: Colors.black), // Text hitam
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100, // Background abu terang
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF0B2C54), width: 2),
        ),
        contentPadding: EdgeInsets.all(16),
      ),
      validator: (v) => v!.isEmpty ? '$hint tidak boleh kosong' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: kategori,
      dropdownColor: Colors.white, // Dropdown putih
      style: TextStyle(color: Colors.black), // Text hitam
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        hintText: 'Kategori',
        hintStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF0B2C54), width: 2),
        ),
        contentPadding: EdgeInsets.all(16),
      ),
      items: [
        DropdownMenuItem(value: 'mesin', child: Text('Mesin')),
        DropdownMenuItem(value: 'body', child: Text('Body')),
        DropdownMenuItem(value: 'roda', child: Text('Roda')),
        DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
      ],
      onChanged: (v) => setState(() => kategori = v),
      validator: (v) => v == null ? 'Pilih kategori' : null,
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
            : widget.product.imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 60,
                      color: Colors.grey.shade400,
                    ), // Icon abu
                    SizedBox(height: 8),
                    Text(
                      'Pilih Gambar',
                      style: TextStyle(color: Colors.grey.shade600),
                    ), // Text abu
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildButton() {
    return ElevatedButton(
      onPressed: _loading ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0B2C54),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _loading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              'Simpan Produk',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}