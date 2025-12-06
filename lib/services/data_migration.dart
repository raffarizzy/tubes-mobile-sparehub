import 'package:cloud_firestore/cloud_firestore.dart';

class DataMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Migrate Products to Firestore
  Future<void> migrateProducts() async {
    List<Map<String, dynamic>> products = [
      {
        'nama': 'Oli Mobil',
        'harga': 125000,
        'deskripsi': 'Oli mobil berkualitas tinggi, dijamin original.',
        'imagePath': 'assets/images/oliMobil.png',
        'tokoId': 'toko1', // Ganti dengan ID toko yang sesuai
        'stok': 10,
        'diskon': 0.1,
        'kategori': 'Otomotif',
      },
      {
        'nama': 'Oli Motor',
        'harga': 100700,
        'deskripsi': 'Oli motor original dengan performa tinggi.',
        'imagePath': 'assets/images/oliMotor.png',
        'tokoId': 'toko1',
        'stok': 20,
        'kategori': 'Otomotif',
      },
      {
        'nama': 'Filter Udara Mobil',
        'harga': 75000,
        'deskripsi': 'Filter udara mobil kualitas OEM.',
        'imagePath': 'assets/images/filterUdara.png',
        'tokoId': 'toko2',
        'stok': 15,
        'kategori': 'Suku Cadang',
      },
    ];

    for (var product in products) {
      await _firestore.collection('products').add(product);
    }

    print('Products migrated successfully!');
  }

  // Migrate Tokos to Firestore
  Future<void> migrateTokos() async {
    // Note: Ganti pemilikId dengan UID user yang sebenarnya setelah user terdaftar
    List<Map<String, dynamic>> tokos = [
      {
        'namaToko': 'Bengkel Jaya Motor',
        'pemilikId': 'user1_uid', // Ganti dengan UID user setelah registrasi
        'deskripsi': 'Spesialis oli dan sparepart kendaraan.',
        'logoPath': 'assets/images/logoToko1.png',
        'lokasi': 'Jakarta Barat',
      },
      {
        'namaToko': 'Otomax Shop',
        'pemilikId': 'user2_uid', // Ganti dengan UID user setelah registrasi
        'deskripsi': 'Toko perlengkapan otomotif lengkap dan terpercaya.',
        'logoPath': 'assets/images/logoToko2.png',
        'lokasi': 'Bandung',
      },
    ];

    for (var toko in tokos) {
      DocumentReference ref = await _firestore.collection('tokos').add(toko);
      print('Toko added with ID: ${ref.id}');
    }

    print('Tokos migrated successfully!');
  }

  // Run all migrations
  Future<void> runAllMigrations() async {
    try {
      print('Starting data migration...');

      await migrateTokos();
      await migrateProducts();

      print('All data migrated successfully!');
    } catch (e) {
      print('Error during migration: $e');
    }
  }

  // Clear all collections (use with caution!)
  Future<void> clearAllData() async {
    try {
      // Clear products
      QuerySnapshot products = await _firestore.collection('products').get();
      for (var doc in products.docs) {
        await doc.reference.delete();
      }

      // Clear tokos
      QuerySnapshot tokos = await _firestore.collection('tokos').get();
      for (var doc in tokos.docs) {
        await doc.reference.delete();
      }

      // Clear keranjangs
      QuerySnapshot keranjangs = await _firestore.collection('keranjangs').get();
      for (var doc in keranjangs.docs) {
        await doc.reference.delete();
      }

      // Clear pesanans
      QuerySnapshot pesanans = await _firestore.collection('pesanans').get();
      for (var doc in pesanans.docs) {
        await doc.reference.delete();
      }

      // Clear ratings
      QuerySnapshot ratings = await _firestore.collection('ratings').get();
      for (var doc in ratings.docs) {
        await doc.reference.delete();
      }

      print('All data cleared successfully!');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}

// Cara menggunakan:
// 1. Import file ini di main.dart atau halaman admin
// 2. Panggil fungsi berikut untuk migrasi data:
//
// DataMigration migration = DataMigration();
// await migration.runAllMigrations();
//
// PENTING: Update tokoId di products sesuai dengan ID toko yang dibuat
// PENTING: Update pemilikId di tokos dengan UID user yang sebenarnya