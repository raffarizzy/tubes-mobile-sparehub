import 'package:flutter/material.dart';
import 'package:tubes_sparehub/pages/halaman_profil/halaman_edit_profil.dart';
import 'package:tubes_sparehub/pages/halaman_riwayatpesanan/riwayat_pesanan.dart';
import 'package:tubes_sparehub/services/auth_service.dart';
import 'package:tubes_sparehub/services/user_service.dart';
import 'package:tubes_sparehub/pages/halaman_LoginAndRegister/login.dart';
import 'package:tubes_sparehub/models/user_model.dart';

class HalamanSaya extends StatelessWidget {
  HalamanSaya({Key? key}) : super(key: key);

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // ================= LOGOUT =================
  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _authService.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User belum login")),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF4F8FF),
        appBar: AppBar(
          title: const Text(
            'Profil Saya',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF122C4F),
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),

        // ================= REAL-TIME LISTENER =================
        body: StreamBuilder<UserModel?>(
          stream: _userService.streamUserById(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Data user tidak ditemukan"));
            }

            final userData = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ================= FOTO PROFIL =================
                  ClipOval(
                    child: Image.network(
                      (userData.imagePath ?? '').isNotEmpty
                          ? userData.imagePath!
                          : '',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ================= INFO USER =================
                  Text(
                    userData.nama,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData.email,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  // ================= TOMBOL =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: const Color(0xFF122C4F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon:
                              const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            "Edit Profil",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfil(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: const Color(0xFFE4A70D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.history,
                              color: Colors.white),
                          label: const Text(
                            "Riwayat Pesanan",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RiwayatPesanan(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}