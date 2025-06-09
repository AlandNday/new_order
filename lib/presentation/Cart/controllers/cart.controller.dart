import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:new_order/domain/core/Models/ShopMenu_model.dart';
import 'package:new_order/infrastructure/navigation/routes.dart';

// Ensure your Product model is correctly imported from ShopMenu_model.dart
Map<String, dynamic> finalOrderData = {
  'tableNumber': '23',
  'totalAmount': 80000.0,
  'items': [
    {'name': 'Burger', 'price': 50000.0, 'quantity': 1},
    {'name': 'Fries', 'price': 30000.0, 'quantity': 1},
    // ... more items
  ],
  // ... other fields
};

/// Represents a single item in the shopping cart.
/// Contains the product details and its quantity.
class CartItem {
  final Product product;
  RxInt quantity; // Make quantity observable for UI updates

  CartItem({required this.product, int quantity = 1})
    : quantity = quantity.obs; // Initialize RxInt with .obs
}

class CartController extends GetxController {
  // Use an RxList to store CartItem objects, making the cart reactive.
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final TextEditingController tableNumberController = TextEditingController();

  final TextEditingController orderNameController = TextEditingController();

  // Expose total amount reactively
  final RxDouble totalAmount = 0.0.obs;

  // Expose total quantity (sum of all product quantities) reactively
  final RxInt totalQuantity = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Whenever cartItems list changes (items added/removed)
    // or any CartItem's quantity within the list changes, recalculate totals.
    ever(cartItems, (_) {
      _calculateTotals();
    });
    // Also react to changes in the quantity of individual CartItems
    // This requires iterating through existing items and setting up listeners.
    // A more robust way is to re-calculate whenever cartItems list itself changes
    // or when any specific item's quantity changes (handled by the CartItem's RxInt).
    // The `ever(cartItems, ...)` already handles adding/removing items.
    // For quantity changes within an existing item, we need to ensure its RxInt triggers updates.
    // The `ever` on `cartItems` itself will not trigger when a quantity *inside* a `CartItem` changes.
    // We need to set up individual listeners for each item's quantity, or recalculate on every quantity change.
    // A simpler approach is to call _calculateTotals after every operation that modifies quantity.
    _calculateTotals(); // Calculate initial totals
  }

  /// Recalculates the total amount and total quantity of items in the cart.
  void _calculateTotals() {
    double tempTotalAmount = 0.0;
    int tempTotalQuantity = 0;
    for (var item in cartItems) {
      tempTotalAmount += item.product.price * item.quantity.value;
      tempTotalQuantity += item.quantity.value;
    }
    totalAmount.value = tempTotalAmount;
    totalQuantity.value = tempTotalQuantity;
  }

  /// Gets a [CartItem] from the cart based on a [Product].
  /// Returns null if the product is not found in the cart.
  CartItem? _getCartItem(Product product) {
    try {
      return cartItems.firstWhere((item) => item.product.id == product.id);
    } catch (e) {
      return null; // Not found
    }
  }

  /// Add a product to the cart or increase its quantity if it already exists.
  void addItem(Product product) {
    final existingCartItem = _getCartItem(product);
    if (existingCartItem != null) {
      existingCartItem.quantity.value++;
    } else {
      cartItems.add(CartItem(product: product, quantity: 1));
    }
    // No need to call cartItems.refresh() because RxList updates automatically
    // when elements are added/removed. Also, RxInt quantity updates itself.
    _calculateTotals(); // Recalculate totals immediately
    // Get.snackbar(
    //   'Cart Update',
    //   '${product.name} added to cart.',
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 1),
    // );
  }

  /// Increase the quantity of an existing item in the cart.
  void increaseQuantity(Product product) {
    final existingCartItem = _getCartItem(product);
    if (existingCartItem != null) {
      existingCartItem.quantity.value++;
      _calculateTotals(); // Recalculate totals immediately
    }
  }

  /// Decrease the quantity of an existing item in the cart.
  /// Removes the item from the cart if its quantity becomes 0 or less.
  void decreaseQuantity(Product product) {
    final existingCartItem = _getCartItem(product);
    if (existingCartItem != null) {
      if (existingCartItem.quantity.value > 1) {
        existingCartItem.quantity.value--;
      } else {
        // If quantity is 1 and decreased, remove from cart
        cartItems.removeWhere((item) => item.product.id == product.id);
        // Get.snackbar(
        //   'Cart Update',
        //   '${product.name} removed from cart.',
        //   snackPosition: SnackPosition.BOTTOM,
        //   duration: const Duration(seconds: 1),
        // );
      }
      _calculateTotals(); // Recalculate totals immediately
    }
  }

  /// Get the quantity of a specific product in the cart.
  int getItemQuantity(Product product) {
    final existingCartItem = _getCartItem(product);
    return existingCartItem?.quantity.value ?? 0;
  }

  /// Clear the entire cart.
  void clearCart() {
    cartItems.clear();
    _calculateTotals(); // Recalculate totals immediately
    Get.snackbar(
      'Cart',
      'Cart cleared successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // --- Methods for UI interaction (if you're using indices in a ListView.builder) ---

  /// Increment quantity of item at a specific index in the cartItems list.
  void incrementQuantityByIndex(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index].quantity.value++;
      _calculateTotals(); // Recalculate totals immediately
    }
  }

  /// Decrement quantity of item at a specific index in the cartItems list.
  /// Removes the item if its quantity becomes 0.
  void decrementQuantityByIndex(int index) {
    if (index >= 0 && index < cartItems.length) {
      if (cartItems[index].quantity.value > 1) {
        cartItems[index].quantity.value--;
      } else {
        // If quantity is 1 and decreased, remove from cart
        final productName = cartItems[index].product.name;
        cartItems.removeAt(index);
        // Get.snackbar(
        //   'Cart Update',
        //   '$productName removed from cart.',
        //   snackPosition: SnackPosition.BOTTOM,
        //   duration: const Duration(seconds: 1),
        // );
      }
      _calculateTotals(); // Recalculate totals immediately
    }
    // Add a TextEditingController for the table number input
  }

  Future<void> checkout() async {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Checkout Failed',
        'Your cart is empty. Please add items before checking out.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    final tableNumber = tableNumberController.text.trim();
    final OrderName = orderNameController.text.trim();
    if (tableNumber.isEmpty) {
      Get.snackbar(
        'Checkout Failed',
        'Please enter your table number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }
    if (OrderName.isEmpty) {
      Get.snackbar(
        'Checkout Failed',
        'Please enter your Order Name.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    try {
      print('  First item in list: ${(finalOrderData['items'] as List).first}');
      print(
        '  Name of first item: ${(finalOrderData['items'] as List).first['name']}',
      );
      print(
        '  Price of first item: ${(finalOrderData['items'] as List).first['price']}',
      );
      print(
        '  Quantity of first item: ${(finalOrderData['items'] as List).first['quantity']}',
      );
      // Prepare the items list for Firestore
      final List<Map<String, dynamic>> items = cartItems.map((item) {
        return {
          'productId': item.product.id, // Assuming your Product has an ID
          'productName': item.product.name,
          'quantity': item.quantity.value,
          'pricePerItem': item.product.price,
          'totalItemPrice': item.product.price * item.quantity.value,
        };
      }).toList();

      // Create the order data map (without FieldValue.serverTimestamp() yet)
      final Map<String, dynamic> orderData = {
        'items': items,
        'tableNumber': tableNumber,
        'totalAmount': totalAmount.value,
        'orderName': OrderName,

        // 'orderTime' and 'status' will be added in CheckoutScreen
      };

      // Navigate to CheckoutScreen, passing the orderData as arguments
      Get.toNamed(Routes.CHECKOUTPAYMENT, arguments: orderData);

      // Optional: Clear cart and table number here if you want to clear them
      // immediately after moving to the checkout screen.
      // clearCart();
      // tableNumberController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      print('Error preparing order data: $e'); // Log the error for debugging
    }
  }
  // Future<void> checkout() async {
  //   if (cartItems.isEmpty) {
  //     Get.snackbar(
  //       'Checkout Failed',
  //       'Your cart is empty. Please add items before checking out.',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Get.theme.colorScheme.error,
  //       colorText: Get.theme.colorScheme.onError,
  //     );
  //     return;
  //   }

  //   final tableNumber = tableNumberController.text.trim();
  //   if (tableNumber.isEmpty) {
  //     Get.snackbar(
  //       'Checkout Failed',
  //       'Please enter your table number.',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Get.theme.colorScheme.error,
  //       colorText: Get.theme.colorScheme.onError,
  //     );
  //     return;
  //   }

  //   try {
  //     final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //     // Prepare the items list for Firestore
  //     final List<Map<String, dynamic>> items = cartItems.map((item) {
  //       return {
  //         'productId': item.product.id, // Assuming your Product has an ID
  //         'productName': item.product.name,
  //         'quantity': item.quantity.value,
  //         'pricePerItem': item.product.price,
  //         'totalItemPrice': item.product.price * item.quantity.value,
  //       };
  //     }).toList();

  //     // Create the order data map
  //     final Map<String, dynamic> orderData = {
  //       'items': items,
  //       'tableNumber': tableNumber,
  //       'totalAmount': totalAmount.value,
  //       'orderTime':
  //           FieldValue.serverTimestamp(), // Timestamp when the order is placed
  //       'status': 'pending', // Initial status of the order
  //     };

  //     // Add the order to the 'orders' collection
  //     await firestore.collection('orders').add(orderData);

  //     // Clear the cart and table number after successful checkout
  //     clearCart();
  //     tableNumberController.clear();

  //     Get.snackbar(
  //       'Order Placed!',
  //       'Your order has been successfully placed for table $tableNumber.',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Get.theme.colorScheme.primary,
  //       colorText: Get.theme.colorScheme.onPrimary,
  //       duration: const Duration(seconds: 3),
  //     );
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to place order: $e',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Get.theme.colorScheme.error,
  //       colorText: Get.theme.colorScheme.onError,
  //     );
  //     print('Error placing order: $e'); // Log the error for debugging
  //   }
  // }
}
