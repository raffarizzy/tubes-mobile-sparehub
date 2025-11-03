import 'package:flutter/material.dart';
import '../../data/UserData.dart';

class EditProfil extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfil({Key? key, this.userData}) : super(key: key);

  @override
  State<EditProfil> createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _alamatController;

  late Map<String, dynamic> user; // simpan user aktif

  @override
  void initState() {
    super.initState();
    user = widget.userData ?? users.first;

    _namaController = TextEditingController(text: user['nama']);
    _emailController = TextEditingController(text: user['email']);
    _passwordController = TextEditingController(text: user['password']);
    _alamatController = TextEditingController(text: user['alamat']);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _simpanPerubahan(int id) {
    final index = users.indexWhere((u) => u['id'] == id);
    if (index != -1) {
      setState(() {
        users[index]['nama'] = _namaController.text;
        users[index]['email'] = _emailController.text;
        users[index]['password'] = _passwordController.text;
        users[index]['alamat'] = _alamatController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!")),
      );

      Navigator.pop(context, users[index]); // kirim data baru ke halaman sebelumnya
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _alamatController,
                decoration: const InputDecoration(
                  labelText: "Alamat",
                  prefixIcon: Icon(Icons.home),
                ),
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
                icon: const Icon(Icons.save),
                label: const Text("Simpan Perubahan"),
                onPressed: () => _simpanPerubahan(user['id']),
              ),
            ],
          ),
        ),
      ),
    );
  }
}