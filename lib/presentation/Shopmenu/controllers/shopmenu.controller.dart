import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_order/domain/Services/Productservices.dart';
import 'package:new_order/domain/core/Models/ShopMenu_model.dart';
import 'package:new_order/presentation/Cart/controllers/cart.controller.dart'; // Import the CartController

class ShopmenuController extends GetxController {
  // RxList to hold all products fetched from the service
  final RxList<Product> products = <Product>[].obs;

  // Observable for the search query input
  final RxString _searchQuery = ''.obs;

  // Loading state indicator for UI
  RxBool isLoading = true.obs;

  // Dependencies: ProductService for data fetching, CartController for cart operations
  final ProductService _productService = Get.find<ProductService>();
  final CartController _cartController =
      Get.find<CartController>(); // Get the instance of CartController

  // Form fields for adding/updating products
  RxString productName = ''.obs;
  RxDouble productPrice = 0.0.obs;
  RxString productDescription = ''.obs;
  Rx<File?> selectedImage = Rx<File?>(null); // For image picking from gallery

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in the 'products' collection from your ProductService
    _productService.getProducts().listen(
      (data) {
        products.assignAll(data); // Update the products list reactively
        isLoading.value = false; // Hide loading indicator
      },
      onError: (error) {
        Get.snackbar('Error', 'Failed to load products: $error');
        isLoading.value = false;
      },
    );
  }

  // --- Product Filtering Logic ---

  // Computed property to get products filtered by the search query
  List<Product> get filteredProducts {
    if (_searchQuery.isEmpty) {
      return products; // Return all products if no search query
    } else {
      return products
          .where(
            (product) => product.name.toLowerCase().contains(
              _searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }
  }

  // Updates the search query when the user types
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  // --- Cart Integration (Delegating to CartController) ---

  // Adds a product to the cart by calling the CartController's method
  void addToCart(Product product) {
    _cartController.addItem(product); // Delegate to CartController
  }

  // Increase the quantity of a product in the cart
  void increaseQuantityInCart(Product product) {
    _cartController.increaseQuantity(product); // Delegate to CartController
  }

  // Decrease the quantity of a product in the cart
  void decreaseQuantityInCart(Product product) {
    _cartController.decreaseQuantity(product); // Delegate to CartController
  }

  // Get the quantity of a product currently in the cart
  int getProductQuantityInCart(Product product) {
    return _cartController.getItemQuantity(
      product,
    ); // Delegate to CartController
  }

  // --- Product Management (CRUD Operations) ---

  // Adds a new product to Firestore
  Future<void> addProduct() async {
    if (productName.value.isEmpty || productPrice.value <= 0) {
      Get.snackbar('Validation Error', 'Name and Price are required.');
      return;
    }

    isLoading.value = true;
    try {
      final newProduct = Product(
        id: '', // Firestore will generate the ID, we'll get it back
        name: productName.value,
        price: productPrice.value,
        description: productDescription.value,
        imageUrl: '', // Will be updated after image upload
      );

      String? docId = await _productService.addProduct(
        newProduct,
        selectedImage.value,
      );
      if (docId != null) {
        Get.snackbar('Success', 'Product added successfully!');
        _clearForm();
        Get.back(); // Optional: Close the add product dialog/sheet
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Updates an existing product in Firestore
  Future<void> updateProduct(Product productToUpdate) async {
    isLoading.value = true;
    try {
      final updatedProduct = Product(
        id: productToUpdate.id,
        name: productName.value.isNotEmpty
            ? productName.value
            : productToUpdate.name,
        price: productPrice.value > 0
            ? productPrice.value
            : productToUpdate.price,
        description: productDescription.value.isNotEmpty
            ? productDescription.value
            : productToUpdate.description,
        imageUrl: productToUpdate.imageUrl, // Preserve existing image URL
      );
      await _productService.updateProduct(
        updatedProduct,
        newImageFile: selectedImage.value,
      );
      Get.snackbar('Success', 'Product updated successfully!');
      _clearForm();
      Get.back(); // Optional: Close the edit product dialog/sheet
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Deletes a product from Firestore
  Future<void> deleteProduct(String id) async {
    isLoading.value = true;
    try {
      await _productService.deleteProduct(id);
      Get.snackbar('Success', 'Product deleted successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Picks an image from the device gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // Clears the form fields after adding/updating a product
  void _clearForm() {
    productName.value = '';
    productPrice.value = 0.0;
    productDescription.value = '';
    selectedImage.value = null;
  }
}
