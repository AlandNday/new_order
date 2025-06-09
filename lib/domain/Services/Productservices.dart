import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:new_order/domain/core/Models/ShopMenu_model.dart'; // For File

class ProductService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference for products
  CollectionReference<Product> get _productsCollection => _firestore
      .collection('/Products')
      .withConverter<Product>(
        fromFirestore: (snapshot, _) => Product.fromFirestore(snapshot),
        toFirestore: (product, _) => product.toJson(),
      );

  // --- CRUD Operations ---

  // 1. Add a Product
  Future<String?> addProduct(Product product, File? imageFile) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, product.id);
      }

      final newProduct = Product(
        id: product.id,
        name: product.name,
        price: product.price,
        description: product.description,
        imageUrl: imageUrl ?? '', // Use uploaded URL or empty string
      );

      DocumentReference docRef = await _productsCollection.add(newProduct);
      // Update the product with the actual Firestore document ID
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
      print('Error adding product: $e');
      return null;
    }
  }

  // Helper to upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile, String productId) async {
    try {
      final ref = _storage
          .ref()
          .child('product_images')
          .child('$productId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
      print('Error uploading image: $e');
      rethrow; // Rethrow to handle in addProduct
    }
  }

  // 2. Get All Products (Stream for real-time updates)
  Stream<List<Product>> getProducts() {
    return _productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // 3. Get a Single Product by ID
  Future<Product?> getProductById(String id) async {
    try {
      DocumentSnapshot<Product> doc = await _productsCollection.doc(id).get();
      return doc.data();
    } catch (e) {
      Get.snackbar('Error', 'Failed to get product: $e');
      print('Error getting product by ID: $e');
      return null;
    }
  }

  // 4. Update a Product
  Future<void> updateProduct(Product product, {File? newImageFile}) async {
    try {
      String? imageUrl = product.imageUrl; // Default to existing URL
      if (newImageFile != null) {
        imageUrl = await _uploadImage(newImageFile, product.id);
      } else if (product.imageUrl.isEmpty) {
        // If the user wants to remove the image and there's no new file
        // You might want to delete the old image from storage here.
        // For simplicity, we'll just set imageUrl to empty.
      }

      await _productsCollection.doc(product.id).update({
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imageurl': imageUrl,
      });
      Get.snackbar('Success', 'Product updated successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: $e');
      print('Error updating product: $e');
    }
  }

  // 5. Delete a Product
  Future<void> deleteProduct(String id) async {
    try {
      // Optionally, delete the image from storage first
      if (id.isNotEmpty) {
        try {
          final ref = _storage.ref().child('product_images').child('$id.jpg');
          await ref.delete();
        } catch (e) {
          print(
            'Warning: Could not delete image for product $id. It might not exist. Error: $e',
          );
          // Continue with product deletion even if image deletion fails
        }
      }

      await _productsCollection.doc(id).delete();
      Get.snackbar('Success', 'Product deleted successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
      print('Error deleting product: $e');
    }
  }
}
