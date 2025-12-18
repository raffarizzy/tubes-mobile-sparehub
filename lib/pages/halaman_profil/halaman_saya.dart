import 'package:flutter/material.dart';
import 'package:tubes_sparehub/pages/halaman_profil/halaman_edit_profil.dart';
import 'package:tubes_sparehub/pages/halaman_riwayatpesanan/riwayat_pesanan.dart';
import 'package:tubes_sparehub/services/auth_service.dart';
import 'package:tubes_sparehub/pages/halaman_LoginAndRegister/login.dart';

class HalamanSaya extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const HalamanSaya({Key? key, this.userData}) : super(key: key);

  // Fungsi logout
  Future<void> _handleLogout(BuildContext context) async {
    final AuthService authService = AuthService();

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await authService.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = userData ?? {
      'nama': 'Pengguna',
      'email': 'Tidak diketahui',
      'alamat': 'Belum diisi',
      'imagePath': 'assets/images/default_profile.png',
    };

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF122C4F),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false, // Hilangkan tombol back otomatis
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
            ),
            const SizedBox(height: 12),
            Text(
              user['nama'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user['email'],
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text("Alamat"),
                subtitle: Text(user['alamat']),
              ),
            ),

            const SizedBox(height: 10),

            // TOMBOL AKSI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Color(0xFF122C4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white,),
                    label: const Text(
                      "Edit Profil",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfil(userData: user),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Color(0xFFE4A70D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.history, color: Colors.white),
                    label: const Text(
                      "Riwayat Pesanan",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiwayatPesanan(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }
}