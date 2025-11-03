import 'package:flutter/material.dart';
import 'package:tubes_sparehub/data/ProductData.dart';

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
  final _idController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _jumlahController.dispose();
    _deskripsiController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F8FF),
      appBar: AppBar(
        backgroundColor: Color(0xFF0B2C54),
        title: Text('Tambah Produk', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Produk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B2C54),
                ),
              ),
              SizedBox(height: 20),
              
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'Masukkan nama produk' : null,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _hargaController,
                decoration: InputDecoration(
                  labelText: 'Harga (Rp)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Masukkan harga' : null,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _jumlahController,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Masukkan jumlah';
                  if (int.tryParse(value) == null) return 'Masukkan angka valid';
                  if (int.parse(value) < 1) return 'Jumlah minimal 1';
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 4,
              ),
              SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0B2C54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context, {
                        'id' : idIncrement+1,
                        'nama': _namaController.text,
                        'harga': _hargaController.text,
                        'jumlah': int.parse(_jumlahController.text),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produk berhasil ditambahkan!')),
                      );
                    }
                  },
                  child: Text(
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
