import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_order/domain/core/Models/ShopMenu_model.dart';
import 'package:new_order/presentation/Cart/controllers/cart.controller.dart'; // Assuming this path is correct

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light gray background for the screen
      body: Column(
        children: [
          SizedBox(height: 40),
          Expanded(
            child: Obx(
              () => controller.cartItems.isEmpty
                  ? Center(
                      child: Text(
                        'Your cart is empty!',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: controller.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = controller.cartItems[index];
                        final product = cartItem.product;
                        final RxInt quantity = cartItem.quantity;

                        return _buildCartItemCard(
                          product,
                          quantity,
                        ); // Custom card for cart item
                      },
                    ),
            ),
          ),
          _buildBottomSection(), // Section for table number, total, and checkout/ Custom bottom navigation bar
        ],
      ),
    );
  }

  Widget _buildCartItemCard(Product product, RxInt quantity) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0, // No shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      color: Colors.grey[200], // White background for card
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Image Placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[600], // Light gray background
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ), // Rounded corners
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name, // Product name
                    style: const TextStyle(
                      fontSize: 16, // Adjusted font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Dark gray color
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${product.price.toStringAsFixed(0)} RP ,-', // Price format
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87, // Dark gray color
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[400], // Light gray background
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.black54,
                        ), // Minus icon
                        onPressed: () => controller.decreaseQuantity(product),
                        splashColor: Colors.transparent, // Remove splash effect
                        highlightColor:
                            Colors.transparent, // Remove highlight effect
                      ),
                      Obx(
                        () => Text(
                          quantity.value.toString(), // Quantity text
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ), // Dark gray color
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.black54,
                        ), // Plus icon
                        onPressed: () => controller.increaseQuantity(product),
                        splashColor: Colors.transparent, // Remove splash effect
                        highlightColor:
                            Colors.transparent, // Remove highlight effect
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white, // White background for this section
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 110, // Smaller width for table number input
            height: 30, // Smaller height
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[200], // Light gray background
              borderRadius: BorderRadius.circular(5), // Rounded corners
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Nomor Meja :', // "Nomor Meja" text
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey[600],
                  ), // Light gray color
                ),
                // Using a simple Text field instead of TextField for static display as per image
                Container(
                  width: 50, // Smaller width for table number input
                  height: 30, // Smaller height
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Light gray background
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  child: TextField(
                    // Placeholder for actual input
                    controller: controller.tableNumberController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          // Adding the "Order Name" text field as per the user's request.
          // Note: The image does not explicitly show an "Order Name" text field,
          // but the user's prompt specifically asked to include it.
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200], // Light gray background
              borderRadius: BorderRadius.circular(5), // Rounded corners
            ),
            child: TextField(
              controller: controller.orderNameController,
              decoration: const InputDecoration(
                border: InputBorder.none, // No border
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                hintText: 'Masukkan nama pemesan', // Placeholder text
                hintStyle: TextStyle(color: Colors.black54),
              ),
              style: const TextStyle(color: Colors.black87),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(
                () => Text(
                  'Total : ${controller.totalAmount.value.toString()} RP ,-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ), // Dark gray color
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 100, // Fixed width for the "Pesan" button
                height: 40, // Fixed height for the "Pesan" button
                child: ElevatedButton(
                  onPressed: () {
                    controller.checkout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700], // Dark green background
                    foregroundColor: Colors.white, // White text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    padding: EdgeInsets.zero, // Remove default padding
                  ),
                  child: const Text(
                    'Pesan',
                    style: TextStyle(fontSize: 16),
                  ), // "Pesan" text
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
