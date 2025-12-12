import 'package:flutter/material.dart';
import 'package:tubes_sparehub/services/user_service.dart';
import 'package:tubes_sparehub/services/auth_service.dart';
import 'package:tubes_sparehub/models/user_model.dart';

class EditProfil extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfil({super.key, this.userData});

  @override
  State<EditProfil> createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _alamatController;

  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _emailController = TextEditingController();
    _alamatController = TextEditingController();

    _loadUserData();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _userService.getUserById(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _currentUser = userData;
          _namaController.text = userData.nama;
          _emailController.text = userData.email;
          _alamatController.text = userData.alamat;
        });
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  // Simpan perubahan ke Firestore
  Future<void> _simpanPerubahan() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User tidak ditemukan")),
      );
      return;
    }

    // Validasi input
    if (_namaController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _alamatController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        // Update data ke Firestore
        await _userService.updateUser(user.uid, {
          'nama': _namaController.text.trim(),
          'email': _emailController.text.trim(),
          'alamat': _alamatController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil berhasil diperbarui!"),
              backgroundColor: Colors.green,
            ),
          );

          // Kembali ke halaman sebelumnya
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memperbarui profil: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            "Edit Profil",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF122C4F),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Lengkap",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _alamatController,
                      decoration: const InputDecoration(
                        labelText: "Alamat",
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF122C4F),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        _isLoading ? "Menyimpan..." : "Simpan Perubahan",
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: _isLoading ? null : _simpanPerubahan,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}