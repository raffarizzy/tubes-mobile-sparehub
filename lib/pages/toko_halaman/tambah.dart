import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:tubes_sparehub/data/ProductData.dart';
import 'package:tubes_sparehub/services/fix_upload_url.dart';

class Tambah extends StatefulWidget {
  @override
  _Tambah createState() => _Tambah();
}

class _Tambah extends State<Tambah> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _jumlahController = TextEditingController(text: '1');
  final _deskripsiController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isUploading = false;

  String? _selectedKategori;

  static const String imgbbApiKey = 'c691b5cbc2f340e04d70a6911e17d5e8';

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _jumlahController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  /// PICK IMAGE
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// UPLOAD TO IMGBB
  Future<String?> _uploadToImgbb(File image) async {
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');

    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final decoded = json.decode(responseData);

    if (response.statusCode == 200) {
      String rawURL = decoded['data']['url'];
      String fixedURL = FixUploadUrl().fixImgBBUrl(rawURL);
      return fixedURL;
    }
    return null;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2C54),
        title: const Text(
          'Tambah Produk',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Produk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B2C54),
                ),
              ),
              const SizedBox(height: 20),

              /// NAMA PRODUK
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration('Nama Produk'),
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan nama produk' : null,
              ),
              const SizedBox(height: 16),

              /// KATEGORI (DROPDOWN)
              DropdownButtonFormField<String>(
                value: _selectedKategori = null,
                decoration: _inputDecoration('Kategori'),
                items: const [
                  DropdownMenuItem(value: 'mesin', child: Text('Mesin')),
                  DropdownMenuItem(value: 'body', child: Text('Body')),
                  DropdownMenuItem(value: 'roda', child: Text('Roda')),
                  DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Pilih kategori produk' : null,
              ),
              const SizedBox(height: 16),

              /// HARGA
              TextFormField(
                controller: _hargaController,
                decoration: _inputDecoration('Harga (Rp)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Masukkan harga' : null,
              ),
              const SizedBox(height: 16),

              /// JUMLAH
              TextFormField(
                controller: _jumlahController,
                decoration: _inputDecoration('Jumlah'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Masukkan jumlah';
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka valid';
                  }
                  if (int.parse(value) < 1) return 'Jumlah minimal 1';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              /// DESKRIPSI
              TextFormField(
                controller: _deskripsiController,
                decoration: _inputDecoration('Deskripsi'),
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              /// GAMBAR
              const Text(
                'Gambar Produk',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B2C54),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text('Pilih Gambar'),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              /// SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B2C54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isUploading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_image == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pilih gambar produk terlebih dahulu',
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() => _isUploading = true);

                            final imageUrl = await _uploadToImgbb(_image!);

                            setState(() => _isUploading = false);

                            if (imageUrl == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Upload gambar gagal'),
                                ),
                              );
                              return;
                            }

                            Navigator.pop(context, {
                              'id': idIncrement + 1,
                              'nama': _namaController.text,
                              'kategori': _selectedKategori,
                              'deskripsi': _deskripsiController.text,
                              'harga': _hargaController.text,
                              'jumlah': int.parse(_jumlahController.text),
                              'gambar': imageUrl,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Produk berhasil ditambahkan'),
                              ),
                            );
                          }
                        },
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Produk',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
