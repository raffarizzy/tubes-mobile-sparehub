import 'package:flutter/material.dart';
import 'package:tubes_sparehub/models/toko_model.dart';
import 'package:tubes_sparehub/services/toko_service.dart';

class EditTokoPage extends StatefulWidget {
  final TokoModel toko;

  const EditTokoPage({super.key, required this.toko});

  @override
  State<EditTokoPage> createState() => _EditTokoPageState();
}

class _EditTokoPageState extends State<EditTokoPage> {
  final _formKey = GlobalKey<FormState>();
  final TokoService _tokoService = TokoService();

  late TextEditingController namaController;
  late TextEditingController deskripsiController;
  late TextEditingController lokasiController;

  bool _isLoading = false;

  // Warna tema sesuai gambar
  final Color primaryNavy = const Color(0xFF122C4F);
  final Color secondaryBg = const Color(0xFFF4F7FA);

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.toko.namaToko);
    deskripsiController = TextEditingController(text: widget.toko.deskripsi);
    lokasiController = TextEditingController(text: widget.toko.lokasi);
  }

  @override
  void dispose() {
    namaController.dispose();
    deskripsiController.dispose();
    lokasiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updatedToko = widget.toko.copyWith(
      namaToko: namaController.text,
      deskripsi: deskripsiController.text,
      lokasi: lokasiController.text,
    );

    await _tokoService.updateToko(updatedToko);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBg, // Background terang seperti di gambar
      appBar: AppBar(
        title: const Text('Edit Profil Toko', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Biru melengkung (menyamakan style gambar 2)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryNavy,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.store, size: 40, color: Color(0xFF122C4F)),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.toko.namaToko,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            // Form dalam Card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: namaController,
                          label: 'Nama Toko',
                          icon: Icons.edit,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: lokasiController,
                          label: 'Lokasi (GBA, dsb)',
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: deskripsiController,
                          label: 'Deskripsi Toko',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryNavy),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryNavy, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (v) => v!.isEmpty ? '$label wajib diisi' : null,
    );
  }
}