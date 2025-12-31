# SpareHub API Documentation

Dokumentasi lengkap untuk semua service dan API endpoints yang digunakan dalam aplikasi SpareHub.

## Table of Contents

1. [Authentication Service](#authentication-service)
2. [Product Service](#product-service)
3. [Toko Service](#toko-service)
4. [Keranjang Service](#keranjang-service)
5. [Order Service](#order-service)
6. [Rating Service](#rating-service)
7. [Address Service](#address-service)
8. [User Service](#user-service)
9. [Xendit Service](#xendit-service)
10. [Backend API Endpoints](#backend-api-endpoints)

---

## Authentication Service

Service untuk mengelola autentikasi pengguna menggunakan Firebase Auth.

### Methods

#### `registerWithEmailPassword(String email, String password, String nama)`
Mendaftarkan user baru ke sistem.

**Parameters:**
- `email` (String): Email user
- `password` (String): Password user
- `nama` (String): Nama lengkap user

**Returns:** `Future<UserModel?>`

**Process:**
1. Create user di Firebase Auth
2. Generate UserModel dengan data default
3. Save user data ke Firestore `users/{uid}`
4. Return UserModel

**Example:**
```dart
final user = await AuthService().registerWithEmailPassword(
  'user@example.com',
  'password123',
  'John Doe'
);
```

---

#### `signInWithEmailPassword(String email, String password)`
Login user ke sistem.

**Parameters:**
- `email` (String): Email user
- `password` (String): Password user

**Returns:** `Future<UserModel?>`

**Process:**
1. Sign in via Firebase Auth
2. Fetch user data dari Firestore
3. Return UserModel

**Example:**
```dart
final user = await AuthService().signInWithEmailPassword(
  'user@example.com',
  'password123'
);
```

---

#### `signOut()`
Logout user dari sistem.

**Returns:** `Future<void>`

**Example:**
```dart
await AuthService().signOut();
```

---

#### `getUserData(String uid)`
Mendapatkan data user dari Firestore.

**Parameters:**
- `uid` (String): User ID

**Returns:** `Future<UserModel?>`

**Example:**
```dart
final user = await AuthService().getUserData('user_id_123');
```

---

#### `updateUserData(String uid, Map<String, dynamic> data)`
Update data user di Firestore.

**Parameters:**
- `uid` (String): User ID
- `data` (Map<String, dynamic>): Data yang akan diupdate

**Returns:** `Future<void>`

**Example:**
```dart
await AuthService().updateUserData('user_id_123', {
  'nama': 'John Updated',
  'phone': '081234567890'
});
```

---

## Product Service

Service untuk mengelola produk di sistem.

### Methods

#### `getAllProducts()`
Mendapatkan stream semua produk.

**Returns:** `Stream<List<ProductModel>>`

**Example:**
```dart
StreamBuilder<List<ProductModel>>(
  stream: ProductService().getAllProducts(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final products = snapshot.data!;
      // Display products
    }
  }
)
```

---

#### `getProductsByTokoId(String tokoId)`
Mendapatkan stream produk berdasarkan toko.

**Parameters:**
- `tokoId` (String): ID toko

**Returns:** `Stream<List<ProductModel>>`

**Example:**
```dart
stream: ProductService().getProductsByTokoId('toko_123')
```

---

#### `getProductById(String productId)`
Mendapatkan detail satu produk.

**Parameters:**
- `productId` (String): ID produk

**Returns:** `Future<ProductModel?>`

**Example:**
```dart
final product = await ProductService().getProductById('prod_123');
```

---

#### `addProduct(ProductModel product)`
Menambahkan produk baru.

**Parameters:**
- `product` (ProductModel): Model produk yang akan ditambahkan

**Returns:** `Future<void>`

**Example:**
```dart
final newProduct = ProductModel(
  id: 'prod_123',
  nama: 'Ban Motor',
  harga: 250000,
  deskripsi: 'Ban motor ukuran 17',
  tokoId: 'toko_123',
  stok: 10,
  kategori: 'Ban',
  imagePath: 'path/to/image.jpg',
  imageUrl: 'https://...',
);

await ProductService().addProduct(newProduct);
```

---

#### `updateProduct(ProductModel product)`
Update data produk.

**Parameters:**
- `product` (ProductModel): Model produk yang diupdate

**Returns:** `Future<void>`

**Example:**
```dart
product.harga = 300000;
product.stok = 5;
await ProductService().updateProduct(product);
```

---

#### `updateProductStock(String productId, int stok)`
Update stok produk.

**Parameters:**
- `productId` (String): ID produk
- `stok` (int): Jumlah stok baru

**Returns:** `Future<void>`

**Example:**
```dart
await ProductService().updateProductStock('prod_123', 15);
```

---

#### `deleteProduct(String productId)`
Menghapus produk.

**Parameters:**
- `productId` (String): ID produk

**Returns:** `Future<void>`

**Example:**
```dart
await ProductService().deleteProduct('prod_123');
```

---

#### `searchProducts(String query)`
Mencari produk berdasarkan nama.

**Parameters:**
- `query` (String): Kata kunci pencarian

**Returns:** `Future<List<ProductModel>>`

**Example:**
```dart
final results = await ProductService().searchProducts('ban motor');
```

---

#### `reduceStock(String productId, int quantity)`
Mengurangi stok produk (saat order dibuat).

**Parameters:**
- `productId` (String): ID produk
- `quantity` (int): Jumlah yang dikurangi

**Returns:** `Future<void>`

**Example:**
```dart
await ProductService().reduceStock('prod_123', 2);
```

---

## Toko Service

Service untuk mengelola toko/store.

### Methods

#### `getAllTokos()`
Mendapatkan stream semua toko.

**Returns:** `Stream<List<TokoModel>>`

**Example:**
```dart
stream: TokoService().getAllTokos()
```

---

#### `getTokoById(String tokoId)`
Mendapatkan detail satu toko.

**Parameters:**
- `tokoId` (String): ID toko

**Returns:** `Future<TokoModel?>`

**Example:**
```dart
final toko = await TokoService().getTokoById('toko_123');
```

---

#### `getTokosByPemilikId(String pemilikId)`
Mendapatkan stream toko milik penjual tertentu.

**Parameters:**
- `pemilikId` (String): ID pemilik toko (user ID)

**Returns:** `Stream<List<TokoModel>>`

**Example:**
```dart
stream: TokoService().getTokosByPemilikId('user_123')
```

---

#### `addToko(TokoModel toko)`
Menambahkan toko baru.

**Parameters:**
- `toko` (TokoModel): Model toko yang akan ditambahkan

**Returns:** `Future<void>`

**Example:**
```dart
final newToko = TokoModel(
  id: 'toko_123',
  namaToko: 'Toko Ban Motor',
  pemilikId: 'user_123',
  deskripsi: 'Jual ban motor berkualitas',
  logoPath: 'path/to/logo.jpg',
  lokasi: 'Jakarta Selatan',
);

await TokoService().addToko(newToko);
```

---

#### `updateToko(TokoModel toko)`
Update data toko.

**Parameters:**
- `toko` (TokoModel): Model toko yang diupdate

**Returns:** `Future<void>`

**Example:**
```dart
toko.namaToko = 'Toko Ban Motor Updated';
await TokoService().updateToko(toko);
```

---

#### `deleteToko(String tokoId)`
Menghapus toko.

**Parameters:**
- `tokoId` (String): ID toko

**Returns:** `Future<void>`

**Example:**
```dart
await TokoService().deleteToko('toko_123');
```

---

## Keranjang Service

Service untuk mengelola shopping cart.

### Methods

#### `getKeranjangByUserId(String userId)`
Mendapatkan stream item keranjang user.

**Parameters:**
- `userId` (String): ID user

**Returns:** `Stream<List<KeranjangModel>>`

**Example:**
```dart
stream: KeranjangService().getKeranjangByUserId('user_123')
```

---

#### `addToKeranjang(KeranjangModel keranjang)`
Menambahkan/update item di keranjang.

**Parameters:**
- `keranjang` (KeranjangModel): Model keranjang

**Returns:** `Future<void>`

**Process:**
1. Cek apakah produk sudah ada di keranjang user
2. Jika ada: update jumlah
3. Jika tidak: tambah item baru

**Example:**
```dart
final item = KeranjangModel(
  id: 'keranjang_123',
  userId: 'user_123',
  produkId: 'prod_123',
  jumlah: 2,
);

await KeranjangService().addToKeranjang(item);
```

---

#### `updateKeranjang(String keranjangId, int jumlah)`
Update jumlah item di keranjang.

**Parameters:**
- `keranjangId` (String): ID keranjang
- `jumlah` (int): Jumlah baru

**Returns:** `Future<void>`

**Example:**
```dart
await KeranjangService().updateKeranjang('keranjang_123', 5);
```

---

#### `deleteKeranjang(String keranjangId)`
Menghapus item dari keranjang.

**Parameters:**
- `keranjangId` (String): ID keranjang

**Returns:** `Future<void>`

**Example:**
```dart
await KeranjangService().deleteKeranjang('keranjang_123');
```

---

#### `clearKeranjang(String userId)`
Menghapus semua item di keranjang user.

**Parameters:**
- `userId` (String): ID user

**Returns:** `Future<void>`

**Example:**
```dart
await KeranjangService().clearKeranjang('user_123');
```

---

## Order Service

Service untuk mengelola pesanan.

### Methods

#### `createOrder(PesananModel order)`
Membuat pesanan baru.

**Parameters:**
- `order` (PesananModel): Model pesanan

**Returns:** `Future<void>`

**Process:**
1. Generate orderId dengan format `ORD + timestamp`
2. Enrich items dengan tokoId
3. Save ke `users/{uid}/orders/{orderId}` (subcollection)
4. Save ke `orders/{orderId}` (global collection)
5. Reduce stock produk

**Example:**
```dart
final order = PesananModel(
  id: 'ORD1234567890',
  userId: 'user_123',
  items: [...],
  totalHarga: 500000,
  status: 'menungguKonfirmasi',
  alamatPengiriman: {...},
);

await OrderService().createOrder(order);
```

---

#### `getUserOrders(String userId)`
Mendapatkan semua pesanan user.

**Parameters:**
- `userId` (String): ID user

**Returns:** `Future<List<PesananModel>>`

**Example:**
```dart
final orders = await OrderService().getUserOrders('user_123');
```

---

#### `getOrdersByToko(String tokoId)`
Mendapatkan stream pesanan untuk toko tertentu.

**Parameters:**
- `tokoId` (String): ID toko

**Returns:** `Stream<List<PesananModel>>`

**Process:**
1. Query orders where `tokoIds` array contains `tokoId`
2. Return stream of orders

**Example:**
```dart
stream: OrderService().getOrdersByToko('toko_123')
```

---

#### `streamUserOrders(String userId)`
Mendapatkan stream pesanan user (real-time).

**Parameters:**
- `userId` (String): ID user

**Returns:** `Stream<List<PesananModel>>`

**Example:**
```dart
stream: OrderService().streamUserOrders('user_123')
```

---

#### `updateOrderStatus(String orderId, String status, {String? courier, String? trackingNumber})`
Update status pesanan.

**Parameters:**
- `orderId` (String): ID pesanan
- `status` (String): Status baru ('menungguKonfirmasi', 'dikonfirmasi', 'dikirim', 'diterima')
- `courier` (String?, optional): Nama kurir
- `trackingNumber` (String?, optional): Nomor resi

**Returns:** `Future<void>`

**Example:**
```dart
await OrderService().updateOrderStatus(
  'ORD1234567890',
  'dikirim',
  courier: 'JNE',
  trackingNumber: 'JNE123456789'
);
```

---

## Rating Service

Service untuk mengelola review dan rating produk.

### Methods

#### `getRatingsByProductId(String productId)`
Mendapatkan semua rating untuk produk.

**Parameters:**
- `productId` (String): ID produk

**Returns:** `Future<List<RatingModel>>`

**Example:**
```dart
final ratings = await RatingService().getRatingsByProductId('prod_123');
```

---

#### `getRatingsByUserId(String userId)`
Mendapatkan semua rating yang dibuat user.

**Parameters:**
- `userId` (String): ID user

**Returns:** `Future<List<RatingModel>>`

**Example:**
```dart
final myRatings = await RatingService().getRatingsByUserId('user_123');
```

---

#### `addRating(RatingModel rating)`
Menambahkan rating baru.

**Parameters:**
- `rating` (RatingModel): Model rating

**Returns:** `Future<void>`

**Example:**
```dart
final rating = RatingModel(
  id: 'rating_123',
  produkId: 'prod_123',
  userId: 'user_123',
  userName: 'John Doe',
  rating: 5,
  komentar: 'Produk bagus!',
  tanggal: '2025-12-31',
);

await RatingService().addRating(rating);
```

---

#### `updateRating(String ratingId, int rating, String komentar)`
Update rating yang sudah ada.

**Parameters:**
- `ratingId` (String): ID rating
- `rating` (int): Rating baru (1-5)
- `komentar` (String): Komentar baru

**Returns:** `Future<void>`

**Example:**
```dart
await RatingService().updateRating('rating_123', 4, 'Updated comment');
```

---

#### `deleteRating(String ratingId)`
Menghapus rating.

**Parameters:**
- `ratingId` (String): ID rating

**Returns:** `Future<void>`

**Example:**
```dart
await RatingService().deleteRating('rating_123');
```

---

#### `getAverageRating(String productId)`
Menghitung rata-rata rating produk.

**Parameters:**
- `productId` (String): ID produk

**Returns:** `Future<double>`

**Example:**
```dart
final avgRating = await RatingService().getAverageRating('prod_123');
print('Average: $avgRating'); // Output: Average: 4.5
```

---

#### `hasUserReviewedProduct(String userId, String productId)`
Cek apakah user sudah mereview produk.

**Parameters:**
- `userId` (String): ID user
- `productId` (String): ID produk

**Returns:** `Future<bool>`

**Example:**
```dart
final hasReviewed = await RatingService().hasUserReviewedProduct(
  'user_123',
  'prod_123'
);
```

---

## Address Service

Service untuk mengelola alamat pengiriman user.

### Methods

#### `addAddress(String userId, Map<String, dynamic> addressData)`
Menambahkan alamat baru.

**Parameters:**
- `userId` (String): ID user
- `addressData` (Map): Data alamat

**Address Data Structure:**
```dart
{
  'name': String,
  'address': String,
  'phone': String,
  'isDefault': bool,
  'createdAt': Timestamp
}
```

**Returns:** `Future<String>` (ID alamat yang dibuat)

**Example:**
```dart
final addressId = await AddressService().addAddress('user_123', {
  'name': 'Rumah',
  'address': 'Jl. Merdeka No. 123, Jakarta',
  'phone': '081234567890',
  'isDefault': true,
});
```

---

#### `getAllAddresses(String userId)`
Mendapatkan semua alamat user.

**Parameters:**
- `userId` (String): ID user

**Returns:** `Future<List<Map<String, dynamic>>>`

**Example:**
```dart
final addresses = await AddressService().getAllAddresses('user_123');
```

---

#### `updateAddress(String userId, String addressId, Map<String, dynamic> addressData)`
Update alamat.

**Parameters:**
- `userId` (String): ID user
- `addressId` (String): ID alamat
- `addressData` (Map): Data alamat baru

**Returns:** `Future<void>`

**Example:**
```dart
await AddressService().updateAddress('user_123', 'addr_123', {
  'name': 'Kantor',
  'address': 'Jl. Sudirman No. 456, Jakarta',
  'phone': '081234567890',
  'isDefault': false,
});
```

---

#### `deleteAddress(String userId, String addressId)`
Menghapus alamat.

**Parameters:**
- `userId` (String): ID user
- `addressId` (String): ID alamat

**Returns:** `Future<void>`

**Example:**
```dart
await AddressService().deleteAddress('user_123', 'addr_123');
```

---

#### `setDefaultAddress(String userId, String addressId)`
Set alamat sebagai default.

**Parameters:**
- `userId` (String): ID user
- `addressId` (String): ID alamat

**Returns:** `Future<void>`

**Process:**
1. Set semua alamat user `isDefault = false`
2. Set alamat yang dipilih `isDefault = true`

**Example:**
```dart
await AddressService().setDefaultAddress('user_123', 'addr_123');
```

---

#### `getDefaultAddress(String userId)`
Mendapatkan alamat default.

**Parameters:**
- `userId` (String): ID user

**Returns:** `Future<Map<String, dynamic>?>`

**Example:**
```dart
final defaultAddr = await AddressService().getDefaultAddress('user_123');
```

---

#### `streamAddresses(String userId)`
Mendapatkan stream alamat user (real-time).

**Parameters:**
- `userId` (String): ID user

**Returns:** `Stream<List<Map<String, dynamic>>>`

**Example:**
```dart
stream: AddressService().streamAddresses('user_123')
```

---

## User Service

Service untuk mengelola data user.

### Methods

#### `updateUserProfile(String uid, Map<String, dynamic> data)`
Update profil user.

**Parameters:**
- `uid` (String): User ID
- `data` (Map): Data yang akan diupdate

**Updatable Fields:**
- `nama`: String
- `email`: String
- `phone`: String
- `gender`: String
- `birthDate`: Timestamp
- `imagePath`: String

**Returns:** `Future<void>`

**Example:**
```dart
await UserService().updateUserProfile('user_123', {
  'nama': 'John Updated',
  'phone': '081234567890',
  'gender': 'Laki-laki',
});
```

---

## Xendit Service

Service untuk integrasi payment gateway Xendit.

### Methods

#### `createInvoice({required int amount, required String name, required String email, String? successRedirectUrl, String? failureRedirectUrl})`
Membuat invoice Xendit untuk pembayaran.

**Parameters:**
- `amount` (int, required): Jumlah pembayaran (dalam Rupiah)
- `name` (String, required): Nama pembeli
- `email` (String, required): Email pembeli
- `successRedirectUrl` (String?, optional): URL redirect saat payment sukses
- `failureRedirectUrl` (String?, optional): URL redirect saat payment gagal

**Returns:** `Future<String?>` (Invoice URL)

**Process:**
1. POST request ke backend `/create-invoice`
2. Backend call Xendit API
3. Return invoice URL

**Example:**
```dart
final invoiceUrl = await XenditService().createInvoice(
  amount: 500000,
  name: 'John Doe',
  email: 'john@example.com',
  successRedirectUrl: 'sparehub://payment/success?order_id=ORD123',
  failureRedirectUrl: 'sparehub://payment/failed?order_id=ORD123',
);

// Launch invoice URL
if (invoiceUrl != null) {
  await launchUrl(Uri.parse(invoiceUrl));
}
```

---

## Backend API Endpoints

Backend berjalan pada Node.js + Express untuk handle payment gateway.

### Base URL
- **Development (Android Emulator):** `http://10.0.2.2:3000`
- **Development (iOS Simulator):** `http://localhost:3000`
- **Production:** Configure sesuai deployment

---

### 1. Health Check

**Endpoint:** `GET /`

**Description:** Check apakah server aktif

**Response:**
```
✅ Server Xendit aktif
```

**Example:**
```bash
curl http://10.0.2.2:3000/
```

---

### 2. Create Invoice

**Endpoint:** `POST /create-invoice`

**Description:** Membuat invoice Xendit untuk pembayaran QRIS

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "amount": 500000,
  "name": "John Doe",
  "email": "john@example.com",
  "successRedirectUrl": "sparehub://payment/success?order_id=ORD1234567890",
  "failureRedirectUrl": "sparehub://payment/failed?order_id=ORD1234567890"
}
```

**Response (Success):**
```json
{
  "invoice_url": "https://checkout.xendit.co/web/xyz123"
}
```

**Response (Error):**
```json
{
  "error": "Error message here"
}
```

**Example cURL:**
```bash
curl -X POST http://10.0.2.2:3000/create-invoice \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 500000,
    "name": "John Doe",
    "email": "john@example.com",
    "successRedirectUrl": "sparehub://payment/success?order_id=ORD123",
    "failureRedirectUrl": "sparehub://payment/failed?order_id=ORD123"
  }'
```

**Example Dart/Flutter:**
```dart
final response = await http.post(
  Uri.parse('http://10.0.2.2:3000/create-invoice'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'amount': 500000,
    'name': 'John Doe',
    'email': 'john@example.com',
    'successRedirectUrl': 'sparehub://payment/success?order_id=ORD123',
    'failureRedirectUrl': 'sparehub://payment/failed?order_id=ORD123',
  }),
);

final data = jsonDecode(response.body);
final invoiceUrl = data['invoice_url'];
```

---

## Deep Link Handling

Aplikasi menggunakan deep link untuk handle payment redirect dari Xendit.

### Deep Link Scheme

**App Links Configuration:**
```
sparehub://payment/success?order_id={orderId}
sparehub://payment/failed?order_id={orderId}
```

### Deep Link Handler

File: `lib/deep_link_handler.dart`

**Process:**
1. Listen untuk deep link events
2. Parse URL dan extract query parameters
3. Handle berdasarkan path:
   - `/payment/success` → Show success message, clear cart
   - `/payment/failed` → Show error message
4. Navigate ke halaman yang sesuai

**Example Implementation:**
```dart
void handleDeepLink(Uri uri) {
  if (uri.path == '/payment/success') {
    final orderId = uri.queryParameters['order_id'];
    // Clear cart
    KeranjangService().clearKeranjang(userId);
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment successful! Order: $orderId'))
    );
  } else if (uri.path == '/payment/failed') {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed'))
    );
  }
}
```

---

## Error Handling

### Common Errors

#### 1. Firebase Auth Errors
```dart
try {
  await AuthService().signInWithEmailPassword(email, password);
} catch (e) {
  if (e.code == 'user-not-found') {
    print('User tidak ditemukan');
  } else if (e.code == 'wrong-password') {
    print('Password salah');
  }
}
```

#### 2. Firestore Errors
```dart
try {
  await ProductService().addProduct(product);
} catch (e) {
  print('Error adding product: $e');
}
```

#### 3. Payment Errors
```dart
final invoiceUrl = await XenditService().createInvoice(...);
if (invoiceUrl == null) {
  print('Failed to create invoice');
  return;
}
```

---

## Data Models Reference

### UserModel
```dart
class UserModel {
  String id;
  String nama;
  String email;
  String? phone;
  String? gender;
  DateTime? birthDate;
  String imagePath;
}
```

### ProductModel
```dart
class ProductModel {
  String id;
  String nama;
  int harga;
  String deskripsi;
  String imagePath;
  String imageUrl;
  String tokoId;
  int stok;
  double? diskon;
  String? kategori;
}
```

### TokoModel
```dart
class TokoModel {
  String id;
  String namaToko;
  String pemilikId;
  String deskripsi;
  String logoPath;
  String lokasi;
}
```

### PesananModel
```dart
class PesananModel {
  String id;
  String userId;
  List<dynamic> items;
  int totalHarga;
  String status;
  Map<String, dynamic> alamatPengiriman;
  String? courier;
  String? trackingNumber;
  DateTime tanggal;
}
```

### KeranjangModel
```dart
class KeranjangModel {
  String id;
  String userId;
  String produkId;
  int jumlah;
}
```

### RatingModel
```dart
class RatingModel {
  String id;
  String produkId;
  String userId;
  String userName;
  int rating; // 1-5
  String komentar;
  String tanggal;
}
```

---

## Best Practices

### 1. Error Handling
Selalu wrap service calls dengan try-catch:
```dart
try {
  final result = await SomeService().someMethod();
} catch (e) {
  print('Error: $e');
  // Show error to user
}
```

### 2. Loading States
Gunakan loading indicator saat melakukan async operations:
```dart
setState(() => isLoading = true);
try {
  await service.method();
} finally {
  setState(() => isLoading = false);
}
```

### 3. Stream Management
Dispose stream subscriptions:
```dart
late StreamSubscription subscription;

@override
void initState() {
  subscription = stream.listen((data) {
    // Handle data
  });
}

@override
void dispose() {
  subscription.cancel();
  super.dispose();
}
```

### 4. Validation
Validate data sebelum mengirim ke service:
```dart
if (email.isEmpty || !email.contains('@')) {
  throw Exception('Invalid email');
}
await AuthService().registerWithEmailPassword(email, password, name);
```

---

## Testing API Endpoints

### Using Postman

1. **Health Check:**
   - Method: GET
   - URL: `http://localhost:3000/`

2. **Create Invoice:**
   - Method: POST
   - URL: `http://localhost:3000/create-invoice`
   - Headers: `Content-Type: application/json`
   - Body:
   ```json
   {
     "amount": 100000,
     "name": "Test User",
     "email": "test@example.com",
     "successRedirectUrl": "sparehub://payment/success",
     "failureRedirectUrl": "sparehub://payment/failed"
   }
   ```

### Using cURL

```bash
# Health check
curl http://localhost:3000/

# Create invoice
curl -X POST http://localhost:3000/create-invoice \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100000,
    "name": "Test User",
    "email": "test@example.com"
  }'
```

---

## Security Considerations

### 1. Environment Variables
Jangan commit sensitive data. Gunakan `.env`:
```env
XENDIT_API_KEY=your_api_key_here
```

### 2. Firebase Rules
Setup Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 3. Input Validation
Selalu validate user input sebelum processing.

### 4. HTTPS
Gunakan HTTPS untuk production backend.

---
