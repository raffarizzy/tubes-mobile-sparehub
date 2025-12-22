import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tubes_sparehub/services/user_service.dart';
import 'package:tubes_sparehub/services/auth_service.dart';
import 'package:tubes_sparehub/services/address_service.dart';
import 'package:tubes_sparehub/models/user_model.dart';

class EditProfil extends StatefulWidget {
  const EditProfil({super.key});

  @override
  State<EditProfil> createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  late TextEditingController _namaController;
  late TextEditingController _emailController;

  UserModel? _currentUser;
  bool _isLoading = false;

  List<Map<String, dynamic>> _addresses = [];
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
    _loadAddresses();
  }

  // ================= USER =================
  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _userService.getUserById(user.uid);
      if (mounted && userData != null) {
        setState(() {
          _currentUser = userData;
          _namaController.text = userData.nama;
          _emailController.text = userData.email;
        });
      }
    }
  }

  // ================= ADDRESS =================
  Future<void> _loadAddresses() async {
    try {
      final addresses = await AddressService.getAllAddresses();
      setState(() {
        _addresses = addresses;
        _isLoadingAddress = false;
      });
    } catch (_) {
      setState(() => _isLoadingAddress = false);
    }
  }

  void _showAddAddressDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    bool isDefault = _addresses.isEmpty;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF4F8FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          // ===== TITLE =====
          title: const Text(
            "Tambah Alamat",
            style: TextStyle(
              color: Color(0xFF122C4F),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              children: [
                _dialogField(nameController, "Nama Penerima", Icons.person),
                const SizedBox(height: 12),
                _dialogField(
                  addressController,
                  "Alamat Lengkap",
                  Icons.home,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  phoneController,
                  "No. HP",
                  Icons.phone,
                  keyboard: TextInputType.phone,
                ),

                // ===== CHECKBOX =====
                CheckboxListTile(
                  value: isDefault,
                  onChanged: (val) =>
                      setDialogState(() => isDefault = val ?? false),
                  activeColor: const Color(0xFF122C4F),
                  title: const Text(
                    "Jadikan alamat utama",
                    style: TextStyle(color: Color(0xFF122C4F)),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),

          // ===== ACTIONS =====
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF122C4F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF122C4F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    addressController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semua field harus diisi")),
                  );
                  return;
                }

                await AddressService.addAddress({
                  'name': nameController.text.trim(),
                  'address': addressController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'isDefault': isDefault.toString(),
                });

                Navigator.pop(context);
                _loadAddresses();
              },
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAddressDialog(Map<String, dynamic> addr) {
    final nameController = TextEditingController(text: addr['name']);
    final addressController = TextEditingController(text: addr['address']);
    final phoneController = TextEditingController(text: addr['phone']);
    bool isDefault = addr['isDefault'] == true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFF4F8FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Edit Alamat",
            style: TextStyle(
              color: Color(0xFF122C4F),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _dialogField(nameController, "Nama Penerima", Icons.person),
                const SizedBox(height: 12),
                _dialogField(
                  addressController,
                  "Alamat Lengkap",
                  Icons.home,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  phoneController,
                  "No. HP",
                  Icons.phone,
                  keyboard: TextInputType.phone,
                ),
                CheckboxListTile(
                  value: isDefault,
                  activeColor: const Color(0xFF122C4F),
                  onChanged: (val) =>
                      setDialogState(() => isDefault = val ?? false),
                  title: const Text(
                    "Jadikan alamat utama",
                    style: TextStyle(color: Color(0xFF122C4F)),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF122C4F),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF122C4F),
              ),
              onPressed: () async {
                await AddressService.updateAddress(addr['id'], {
                  'name': nameController.text.trim(),
                  'address': addressController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'isDefault': isDefault.toString(),
                });

                Navigator.pop(context);
                _loadAddresses();
              },
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAddress(String addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Alamat"),
        content: const Text("Yakin ingin menghapus alamat ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await AddressService.deleteAddress(addressId);
              Navigator.pop(context);
              _loadAddresses();
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE =================
  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String?> _uploadToImgBB(File image) async {
    const apiKey = 'c691b5cbc2f340e04d70a6911e17d5e8';
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print("IMG URL: ${jsonDecode(responseData)['data']}");
      return jsonDecode(responseData)['data']['url'];
    }
    throw Exception("Upload gagal");
  }

  Future<void> _changeProfileImage() async {
    final file = await _pickImage();
    if (file == null) return;

    setState(() => _isLoading = true);

    try {
      final imageUrl = await _uploadToImgBB(file);
      final user = _authService.currentUser;
      if (user != null && imageUrl != null) {
        await _userService.updateProfileImage(user.uid, imageUrl);
        setState(() {
          _currentUser = _currentUser!.copyWith(imagePath: imageUrl);
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= SAVE =================
  Future<void> _simpanPerubahan() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);
    final user = _authService.currentUser;

    if (user != null) {
      await _userService.updateUser(user.uid, {
        'nama': _namaController.text.trim(),
        'email': _emailController.text.trim(),
      });

      if (mounted) Navigator.pop(context, true);
    }

    setState(() => _isLoading = false);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF4F8FF),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFFF4F8FF),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              "Edit Profil",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF122C4F),
          ),
          body: _currentUser == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    _headerProfile(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _field(_namaController, "Nama", Icons.person),
                          const SizedBox(height: 16),
                          _field(_emailController, "Email", Icons.email),
                          const SizedBox(height: 24),
                          _alamatSection(),
                          const SizedBox(height: 32),
                          _saveButton(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ================= WIDGET =================
  Widget _headerProfile() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Stack(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              backgroundImage: (_currentUser?.imagePath ?? '').isNotEmpty
                  ? NetworkImage(_currentUser!.imagePath!)
                  : null,
              child: (_currentUser?.imagePath ?? '').isEmpty
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: Color(0xFF122C4F),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: _changeProfileImage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alamatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Alamat Pengiriman",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddAddressDialog,
            ),
          ],
        ),
        _isLoadingAddress
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: _addresses.map((addr) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(addr['name']),
                      subtitle: Text(addr['address']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (addr['isDefault'] == true)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Chip(label: Text("Utama")),
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xFF122C4F),
                            ),
                            onPressed: () => _showEditAddressDialog(addr),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteAddress(addr['id']),
                          ),
                        ],
                      ),
                    ),
                    color: Colors.white,
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _simpanPerubahan,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF122C4F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size.fromHeight(52),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Simpan Perubahan",
              style: TextStyle(color: Colors.white),
            ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}