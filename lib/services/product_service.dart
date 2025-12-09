import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products (Stream - real-time)
  Stream<List<ProductModel>> getAllProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get products by toko ID (Stream - real-time)
  Stream<List<ProductModel>> getProductsByTokoId(String tokoId) {
    return _firestore
        .collection('products')
        .where('tokoId', isEqualTo: tokoId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get single product by ID (Future - one-time fetch)
  Future<ProductModel?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // Add new product
  Future<String?> addProduct(ProductModel product) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('products')
          .add(product.toFirestore());

      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      throw 'Gagal menambahkan produk. Silakan coba lagi.';
    }
  }

  // Update product
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('products').doc(productId).update(data);
    } catch (e) {
      print('Error updating product: $e');
      throw 'Gagal mengupdate produk. Silakan coba lagi.';
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      throw 'Gagal menghapus produk. Silakan coba lagi.';
    }
  }

  // Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();

      List<ProductModel> allProducts = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      // Filter locally (Firestore doesn't support case-insensitive search)
      return allProducts
          .where(
            (product) =>
                product.nama.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}
