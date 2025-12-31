# SpareHub

Platform e-commerce mobile untuk penjualan spare parts/onderdil kendaraan berbasis Flutter dan Firebase.

## Deskripsi Aplikasi

SpareHub adalah aplikasi mobile yang memungkinkan pengguna untuk membeli dan menjual spare parts kendaraan. Aplikasi ini menyediakan fitur lengkap untuk buyer (pembeli) dan seller (penjual) dengan sistem pembayaran terintegrasi menggunakan Xendit.

## Dokumentasi API
**[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)**

### Fitur Utama

#### Untuk Pembeli (Buyer)
- 🔐 **Autentikasi** - Register dan login menggunakan email & password
- 🛍️ **Browse Produk** - Lihat katalog produk dengan real-time updates
- 🔍 **Pencarian & Filter** - Cari produk berdasarkan nama, kategori, dan range harga
- 🛒 **Keranjang Belanja** - Kelola item di keranjang sebelum checkout
- 💳 **Pembayaran** - Integrasi payment gateway Xendit (QRIS)
- 📦 **Riwayat Pesanan** - Lacak status pesanan dan riwayat transaksi
- ⭐ **Review & Rating** - Berikan rating dan ulasan untuk produk
- 👤 **Manajemen Profil** - Edit profil, upload foto, kelola alamat pengiriman

#### Untuk Penjual (Seller)
- 🏪 **Manajemen Toko** - Buat dan kelola informasi toko
- 📦 **Manajemen Produk** - Tambah, edit, hapus produk dengan mudah
- 📊 **Kelola Stok** - Update stok produk secara real-time
- 🚚 **Lacak Pesanan** - Lihat pesanan masuk dan update status pengiriman
- 📍 **Info Pengiriman** - Tambahkan kurir dan nomor resi

## Tech Stack

### Frontend (Mobile)
- **Framework**: Flutter SDK ^3.9.2
- **Language**: Dart
- **State Management**: StatefulWidget
- **Database**: Cloud Firestore
- **Authentication**: Firebase Auth
- **Local Storage**: SharedPreferences
- **Image Handling**: Image Picker

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Payment Gateway**: Xendit

### Dependencies Utama
```yaml
# Firebase
firebase_core: ^4.2.1
cloud_firestore: ^6.1.0
firebase_auth: ^6.1.2

# Networking & Storage
http: ^1.6.0
shared_preferences: ^2.5.4

# UI & Utils
url_launcher: ^6.3.2
app_links: ^6.4.1
image_picker: ^1.2.1
intl: ^0.18.0
```

## Struktur Project

```
lib/
├── main.dart                    # Entry point aplikasi
├── deep_link_handler.dart      # Handler untuk payment redirect
├── pages/                       # UI Screens
│   ├── homepage.dart           # Halaman utama
│   ├── detail_produk.dart      # Detail produk
│   ├── keranjang.dart          # Shopping cart
│   ├── halaman_checkout.dart   # Checkout & payment
│   ├── halaman_toko.dart       # List toko
│   ├── halaman_LoginAndRegister/
│   ├── halaman_profil/
│   ├── halaman_riwayatpesanan/
│   └── toko_halaman/           # Seller features
├── models/                      # Data models
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── toko_model.dart
│   ├── pesanan_model.dart
│   ├── keranjang_model.dart
│   └── rating_model.dart
├── services/                    # Business logic & API
│   ├── auth_service.dart
│   ├── product_service.dart
│   ├── toko_service.dart
│   ├── keranjang_service.dart
│   ├── order_service.dart
│   ├── rating_service.dart
│   ├── address_service.dart
│   ├── user_service.dart
│   ├── xendit_service.dart
│   └── firestore_service.dart
├── widgets/                     # Reusable components
└── data/                        # Sample data
```

## Database Schema (Firestore)

### Collections

#### users
```
users/{uid}
├── nama: string
├── email: string
├── phone?: string
├── gender?: string
├── birthDate?: Timestamp
├── imagePath: string
├── orders/ (subcollection)
└── addresses/ (subcollection)
```

#### products
```
products/{productId}
├── nama: string
├── harga: int
├── deskripsi: string
├── imagePath: string
├── imageUrl: string
├── tokoId: string (FK)
├── stok: int
├── diskon?: double
└── kategori?: string
```

#### tokos
```
tokos/{tokoId}
├── namaToko: string
├── pemilikId: string (FK)
├── deskripsi: string
├── logoPath: string
└── lokasi: string
```

#### orders
```
orders/{orderId}
├── orderId: string
├── buyerId: string
├── buyerName: string
├── buyerPhone: string
├── address: object
├── items: array
├── tokoIds: array
├── totalAmount: int
├── invoiceUrl: string
├── status: string
├── courier?: string
├── trackingNumber?: string
└── createdAt: Timestamp
```

#### keranjangs
```
keranjangs/{keranjangId}
├── userId: string (FK)
├── produkId: string (FK)
└── jumlah: int
```

#### ratings
```
ratings/{ratingId}
├── produkId: string (FK)
├── userId: string (FK)
├── userName: string
├── rating: int (1-5)
├── komentar: string
└── tanggal: string
```

## Setup & Installation

### Prerequisites
- Flutter SDK ^3.9.2
- Dart SDK
- Android Studio / VS Code
- Firebase project
- Node.js (untuk backend)

### Langkah Instalasi

#### 1. Clone Repository
```bash
git clone <repository-url>
cd tubes-mobile-sparehub
```

#### 2. Install Dependencies Flutter
```bash
flutter pub get
```

#### 3. Setup Firebase
1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Tambahkan aplikasi Android/iOS
3. Download `google-services.json` (Android) atau `GoogleService-Info.plist` (iOS)
4. Letakkan file konfigurasi di folder yang sesuai
5. Enable Authentication (Email/Password) di Firebase Console
6. Enable Cloud Firestore

#### 4. Setup Backend (Payment Server)
```bash
cd backend
npm install
```

Buat file `.env` di folder backend:
```env
XENDIT_API_KEY=your_xendit_api_key_here
```

#### 5. Jalankan Backend Server
```bash
npm start
```
Server akan berjalan di `http://localhost:3000`

#### 6. Jalankan Aplikasi Flutter
```bash
flutter run
```

Untuk Android emulator, backend akan diakses via `http://10.0.2.2:3000`

## Cara Menggunakan Aplikasi

### Untuk Pembeli

1. **Register/Login**
   - Buka aplikasi dan pilih "Daftar" untuk membuat akun baru
   - Masukkan nama, email, dan password
   - Atau login jika sudah punya akun

2. **Browse Produk**
   - Lihat katalog produk di homepage
   - Gunakan search bar untuk mencari produk
   - Filter berdasarkan kategori atau harga

3. **Tambah ke Keranjang**
   - Klik produk untuk lihat detail
   - Klik "Tambah ke Keranjang"
   - Atur jumlah barang yang diinginkan

4. **Checkout**
   - Buka keranjang belanja
   - Pilih alamat pengiriman
   - Klik "Checkout"
   - Bayar menggunakan Xendit (QRIS)

5. **Lacak Pesanan**
   - Buka menu "Riwayat Pesanan"
   - Lihat status pesanan Anda
   - Berikan review setelah barang diterima

### Untuk Penjual

1. **Buat Toko**
   - Login ke aplikasi
   - Buka menu Toko
   - Buat toko baru dengan mengisi informasi toko

2. **Tambah Produk**
   - Di halaman toko, klik "Tambah Produk"
   - Upload foto produk
   - Isi detail: nama, harga, deskripsi, stok, kategori

3. **Kelola Pesanan**
   - Lihat pesanan masuk di menu "Lacak Pesanan"
   - Update status pesanan (dikonfirmasi → dikirim → diterima)
   - Tambahkan info kurir dan nomor resi

4. **Edit/Hapus Produk**
   - Buka halaman toko Anda
   - Klik produk yang ingin diedit
   - Pilih "Edit" atau "Hapus"

## Flow Utama

### Authentication Flow
```
Register → Create Firebase Auth User → Save to Firestore → Login
Login → Firebase Auth Sign In → Fetch User Data → Store Session → HomePage
```

### Order Flow
```
Browse Products → Add to Cart → Checkout → Select Address →
Create Order → Generate Xendit Invoice → Payment →
Payment Success → Clear Cart → Order Created → Track Order
```

### Order Status Flow
```
menungguKonfirmasi → dikonfirmasi → dikirim → diterima
```

## Payment Integration

Aplikasi menggunakan Xendit untuk payment gateway dengan flow:

1. User checkout dan sistem membuat invoice via backend
2. User diredirect ke Xendit payment page (QRIS)
3. Setelah payment success/failed, Xendit redirect ke deep link
4. Deep link handler memproses hasil payment
5. Cart di-clear dan order status diupdate

### Deep Link Scheme
```
sparehub://payment/success?order_id={orderId}
sparehub://payment/failed?order_id={orderId}
```

## Environment

### Development
- Backend API: `http://10.0.2.2:3000` (Android Emulator)
- Backend API: `http://localhost:3000` (iOS Simulator)

### Production
Ganti URL backend di `XenditService` dengan production URL.

## Troubleshooting

### Firebase Connection Error
- Pastikan `google-services.json` sudah di-setup dengan benar
- Check internet connection
- Verify Firebase project configuration

### Payment Error
- Pastikan backend server running
- Check Xendit API key di file `.env`
- Verify deep link configuration

### Build Error
```bash
flutter clean
flutter pub get
flutter run
```

## License

Project ini dibuat untuk keperluan tugas kuliah.
