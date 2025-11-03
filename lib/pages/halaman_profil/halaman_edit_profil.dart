import 'package:flutter/material.dart';
import '../../data/UserData.dart'; // pastikan ini mengandung List<Map<String, dynamic>> users

class EditProfil extends StatefulWidget {
  const EditProfil({super.key});

  @override
  State<EditProfil> createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  // Controller untuk setiap TextField
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Ambil data user pertama dari list users
    final user = users.firstWhere((u) => u['id'] == 1); // contoh: id=1

    // Isi controller dengan data user
    _namaController.text = user['nama'];
    _emailController.text = user['email'];
    _passwordController.text = user['password'];
    _alamatController.text = user['alamat'];
  }

  @override
  void dispose() {
    // Bersihkan controller agar tidak bocor memori
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Profil", 
            style: TextStyle(
              color: Colors.white
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color(0xFF122C4F),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Lengkap"),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              TextField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: "Alamat"),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Update data user di list
                      users[0]['nama'] = _namaController.text;
                      users[0]['email'] = _emailController.text;
                      users[0]['password'] = _passwordController.text;
                      users[0]['alamat'] = _alamatController.text;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profil berhasil diperbarui!")),
                    );
                  },
                  child: const Text("Simpan Perubahan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}